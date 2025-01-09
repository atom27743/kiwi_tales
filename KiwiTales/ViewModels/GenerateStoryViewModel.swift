//
//  GenerateStoryViewModel.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//

//functions for generating stories and images
import Foundation
import Combine
import UIKit
import GoogleGenerativeAI
import FirebaseFirestore
import FirebaseAuth

class GenerateStoryViewModel: ObservableObject {
    @Published var keywords: [String] = []
    @Published var selectedTheme: String = ""
    @Published var selectedDifficulty: String = ""
    @Published var numSentences: Int = 0
    
    @Published var storySegment: StorySegment?
    @Published var generatedImages: [UIImage?] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var loadingMessage: String = "Generating your story..."
    @Published var loadingProgress: Double = 0.0
    
    @Published var isCoverImageGenerated: Bool = false
    @Published var imagesLoadingProgress: Double = 0.0
    
    @Published var isSaving: Bool = false
    @Published var isSaved: Bool = false
    @Published var saveProgress: Double = 0.0
    
    private let db = Firestore.firestore()
    
    var isFullyGenerated: Bool {
        guard let storySegment = storySegment else { return false }
        return generatedImages.filter { $0 != nil }.count == storySegment.contents.count + 1
    }
    
    private var totalSteps: Int = 0
    private var completedSteps: Int = 0
    
    func updateProgress(message: String? = nil, step: Int = 0) {
        DispatchQueue.main.async {
            if let message = message {
                self.loadingMessage = message
            }
            if step > 0 {
                self.completedSteps += step
                self.loadingProgress = Double(self.completedSteps) / Double(self.totalSteps)
            }
        }
    }
    
    private let model = GenerativeModel(name: "gemini-1.5-pro", apiKey: Bundle.main.infoDictionary?["GOOGLE_GEMINI_API_KEY"] as? String ?? "")
    private var cancellables = Set<AnyCancellable>()
    
    private var imageGenerationQueue: [(prompt: String, index: Int)] = []
    private var isProcessingQueue = false
    
    private let maxConcurrentRequests = 2
    private let requestsPerMinute = 50
    private var requestTimestamps: [Date] = []
    private var imageGenerationTimer: Timer?
    
    init() {
        setupBindings()
        configureFirestore()
    }
    
    private func configureFirestore() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        settings.isSSLEnabled = true
        
        // Increase timeout for slow connections
        let db = Firestore.firestore()
        db.settings = settings
    }
    
    func saveKeywords(_ newKeywords: [String]) {
        keywords = newKeywords
    }
    
    func saveTheme(_ theme: String) {
        selectedTheme = theme
    }
    
    func saveDifficulty(_ difficulty: String, sentences: Int) {
        selectedDifficulty = difficulty
        numSentences = sentences
    }
    
    private func setupBindings() {
        $keywords
            .sink { newKeywords in
                print("Keywords updated: \(newKeywords)")
            }
            .store(in: &cancellables)
        
        $selectedTheme
            .sink { newTheme in
                print("Theme updated: \(newTheme)")
            }
            .store(in: &cancellables)
        
        $selectedDifficulty
            .sink { newDifficulty in
                print("Difficulty updated: \(newDifficulty)")
            }
            .store(in: &cancellables)
    }
    
    private func updateProgress() {
        let totalImages = Double(generatedImages.count)
        let loadedImages = Double(generatedImages.compactMap { $0 }.count)
        imagesLoadingProgress = loadedImages / totalImages
        
        // Only set isLoading to false when all images are loaded and we're fully generated
        if imagesLoadingProgress >= 1.0 && isFullyGenerated {
            isLoading = false
        }
    }
    
    private func processImageQueue() {
        guard !isProcessingQueue, !imageGenerationQueue.isEmpty else {
            if imageGenerationQueue.isEmpty {
                Task { @MainActor in
                    // Only set isLoading to false if all images are generated
                    if isFullyGenerated {
                        self.isLoading = false
                    }
                }
            }
            return
        }
        
        isProcessingQueue = true
        
        Task {
            var activeRequests = 0
            
            while !imageGenerationQueue.isEmpty {
                // Check if we can make more requests
                guard canMakeRequest() else {
                    // Wait for 5 seconds before trying again
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    continue
                }
                
                // Process up to maxConcurrentRequests at a time
                while activeRequests < maxConcurrentRequests && !imageGenerationQueue.isEmpty {
                    let (prompt, index) = imageGenerationQueue.removeFirst()
                    activeRequests += 1
                    
                    // Start image generation for this request
                    Task {
                        defer { activeRequests -= 1 }
                        trackRequest()
                        await fetchImage(for: prompt, at: index)
                    }
                    
                    // Add small delay between concurrent requests
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
                
                // Wait for active requests to complete
                while activeRequests > 0 {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                }
            }
            
            await MainActor.run {
                self.isProcessingQueue = false
                // Double check if we're fully generated before setting isLoading to false
                if self.isFullyGenerated {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func fetchImage(for prompt: String, at index: Int) async {
        let maxRetries = 3
        var currentRetry = 0
        
        while currentRetry < maxRetries {
            do {
                let image = try await fetchImageWithRetry(prompt: prompt)
                
                await MainActor.run {
                    print("Successfully generated image for index: \(index)")
                    self.generatedImages[index] = image
                    self.updateProgress()
                    if index == 0 {
                        self.isCoverImageGenerated = true
                    }
                }
                return
                
            } catch APIError.rateLimited {
                print("Rate limit hit, implementing exponential backoff...")
                let backoffSeconds = Int(pow(2.0, Double(currentRetry + 2)))
                try? await Task.sleep(nanoseconds: UInt64(backoffSeconds) * 1_000_000_000)
                currentRetry += 1
                
            } catch APIError.invalidImageData {
                print("Invalid image data received, retrying...")
                currentRetry += 1
                try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(currentRetry))) * 1_000_000_000)
                
            } catch {
                print("Error generating image: \(error.localizedDescription)")
                if currentRetry == maxRetries - 1 {
                    await MainActor.run {
                        self.generatedImages[index] = nil
                        self.updateProgress()
                        self.errorMessage = "Failed to generate image after \(maxRetries) attempts: \(error.localizedDescription)"
                    }
                    return
                }
                currentRetry += 1
                try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(currentRetry))) * 1_000_000_000)
            }
        }
    }
    
    func generateStory() {
        isLoading = true
        errorMessage = nil
        loadingProgress = 0.0
        completedSteps = 0
        generatedImages.removeAll()
        
        // Calculate total steps (story + images)
        totalSteps = numSentences + numSentences + 2 // Story generation + images + cover image
        
        Task {
            do {
                updateProgress(message: "Creating your story...")
                let story = try await generateStoryContent()
                
                DispatchQueue.main.async {
                    self.storySegment = story
                    self.completedSteps += self.numSentences
                    self.loadingProgress = Double(self.completedSteps) / Double(self.totalSteps)
                    // Initialize the images array with the correct size
                    self.generatedImages = Array(repeating: nil, count: story.contents.count + 1)
                }
                
                updateProgress(message: "Bringing your story to life with images...")
                
                // Generate cover image first
//                let coverPrompt = "Create a children's picture book cover for '\(story.title)' in a 2d cute cartoon style."
//                let coverPrompt = "\(story.coverImagePrompt)"
                try await generateImage(from: story.coverImagePrompt, forIndex: 0)
                
                // Generate images for each story segment
                for (index, content) in story.contents.enumerated() {
                    let prompt = "\(content.imagePrompt)"
                    try await generateImage(from: prompt, forIndex: index + 1)
                }
                
                // Set loading to false after all images are generated
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Image Generation
    
    private func generateImage(from prompt: String, forIndex index: Int) async throws {
        let maxRetries = 3
        var currentRetry = 0
        
        while currentRetry < maxRetries {
            do {
                let image = try await fetchImageWithRetry(prompt: prompt)
                
                DispatchQueue.main.async {
                    print("Successfully generated image for index: \(index)")
                    self.generatedImages[index] = image
                    self.updateProgress(step: 1)
                    if index == 0 {
                        self.isCoverImageGenerated = true
                    }
                }
                return
                
            } catch APIError.rateLimited {
                print("Rate limit hit, implementing exponential backoff...")
                let backoffSeconds = Int(pow(2.0, Double(currentRetry + 2)))
                try? await Task.sleep(nanoseconds: UInt64(backoffSeconds) * 1_000_000_000)
                currentRetry += 1
            } catch {
                print("Error generating image: \(error.localizedDescription)")
                if currentRetry == maxRetries - 1 {
                    throw error
                }
                currentRetry += 1
            }
        }
    }
    
    //    private func fetchImageWithRetry(prompt: String) async throws -> UIImage {
    //        let apiUrl = Bundle.main.infoDictionary?["STABILITY_AI_BASE_URL"] as? String ?? ""
    //
    //        let urlString = apiUrl.hasPrefix("https://") ? apiUrl : "https://\(apiUrl)"
    //
    //        guard let url = URL(string: urlString) else {
    //            throw APIError.invalidURL
    //        }
    //
    //        var request = URLRequest(url: url)
    //            request.httpMethod = "POST"
    //            request.setValue("multipart/form-data; boundary=Boundary-\(UUID().uuidString)", forHTTPHeaderField: "Content-Type")
    //            request.setValue("Bearer \(Bundle.main.infoDictionary?["STABILITY_AI_API_KEY"] as? String ?? "")", forHTTPHeaderField: "Authorization")
    //            request.setValue("image/*", forHTTPHeaderField: "Accept") // Expect an image response
    //
    //            // Prepare multipart form data
    //            var body = Data()
    //            let boundary = "Boundary-\(UUID().uuidString)"
    //            let addField: (String, String) -> Void = { name, value in
    //                body.append("--\(boundary)\r\n".data(using: .utf8)!)
    //                body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
    //                body.append("\(value)\r\n".data(using: .utf8)!)
    //            }
    //
    //            // Add form fields
    //            addField("text_prompts", "[{\"text\":\"children's book illustration, \(prompt)\",\"weight\":1}]")
    //            addField("cfg_scale", "7")
    //            addField("height", "576")
    //            addField("width", "1024")
    //            addField("samples", "1")
    //            addField("steps", "40")
    //            addField("style_preset", "enhance")
    //
    //            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    //            request.httpBody = body
    //
    //            do {
    //                let (data, response) = try await URLSession.shared.data(for: request)
    //
    //                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
    //                    throw APIError.invalidResponse
    //                }
    //
    //                // Parse response data to extract the image
    //                guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
    //                      let artifacts = jsonResponse["artifacts"] as? [[String: Any]],
    //                      let firstImage = artifacts.first?["base64"] as? String,
    //                      let imageData = Data(base64Encoded: firstImage),
    //                      let image = UIImage(data: imageData) else {
    //                    throw APIError.invalidImageData
    //                }
    //
    //                return image
    //            } catch {
    //                throw APIError.networkError(error)
    //            }
    //        }
    
    
    private func fetchImageWithRetry(prompt: String) async throws -> UIImage {
        print("Final prompt sent to API: \(prompt)")
        //to check what prompt is being sent out
        
        let apiUrl = Bundle.main.infoDictionary?["STABILITY_AI_BASE_URL"] as? String ?? ""
        print("Debug - API URL: \(apiUrl)")
                
                // Ensure URL has proper scheme
        let urlString = apiUrl.hasPrefix("https://") ? apiUrl : "https://\(apiUrl)"
        print("Debug - Formatted URL: \(urlString)")

        guard let url = URL(string: urlString) else {
        print("Debug - Failed to create URL from: \(urlString)")
        throw APIError.invalidURL
        }

        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Bundle.main.infoDictionary?["STABILITY_AI_API_KEY"] as? String ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("image/*", forHTTPHeaderField: "Accept")
        
        let requestBody: [String: Any] = [
            "prompt": prompt,
            "aspect_ratio": "9:16",
            "model": "sd3-large",
            "negative_prompt": "Realistic image, Photorealistic, Hyper-realistic, Cinematic, 3D render,  HDR, Fine details, Sharp focus, Glossy, Low res, Blurry, Bad anatomy, Bad proportions, Disfigured, Deformed, High realism",
            "output_format": "jpeg"
        ]
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let bodyData = createMultipartFormData(boundary: boundary, parameters: requestBody)
        request.httpBody = bodyData
        
        do {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 300
            let session = URLSession(configuration: config)
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                guard let image = UIImage(data: data) else {
                    print("Failed to create UIImage from data")
                    throw APIError.invalidImageData
                }
                return image
            } else {
                if let errorResponse = String(data: data, encoding: .utf8) {
                    print("Error Response: \(errorResponse)")
                }
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch {
            print("Network error: \(error)")
            throw APIError.networkError(error)
        }
    }
    
    private func createMultipartFormData(boundary: String, parameters: [String: Any]) -> Data {
        var body = ""
        for (key, value) in parameters {
            body += "--\(boundary)\r\n"
            body += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
            body += "\(value)\r\n"
        }
        body += "--\(boundary)--\r\n"
        return body.data(using: .utf8) ?? Data()
    }
    
    
    // Add a custom URLSession configuration
    private lazy var imageSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        config.httpMaximumConnectionsPerHost = 5
        return URLSession(configuration: config)
    }()
    
    private func canMakeRequest() -> Bool {
        let now = Date()
        // Remove timestamps older than 1 minute
        requestTimestamps = requestTimestamps.filter { now.timeIntervalSince($0) < 60 }
        return requestTimestamps.count < requestsPerMinute
    }
    
    private func trackRequest() {
        requestTimestamps.append(Date())
    }
    
    func loadSavedStory(from userBook: UserBook) {
        isLoading = true
        errorMessage = nil
        
        // Create contents from book data
        let contents = zip(userBook.generated_texts, userBook.image_prompts).map { text, prompt in
            Contents(sentence: text, imagePrompt: prompt)
        }
        
        // Create and set story segment immediately
        let segment = StorySegment(
            title: userBook.title,
            coverImagePrompt: userBook.cover_image_prompt,
            contents: contents
        )
        
        // Set the story segment on the main thread immediately
        Task { @MainActor in
            self.storySegment = segment
            self.generatedImages = Array(repeating: nil, count: userBook.image_urls.count)
            self.isCoverImageGenerated = false
        }
        
        // Create an actor to safely track failed loads
        actor FailureTracker {
            private var count: Int = 0
            
            func increment() {
                count += 1
            }
            
            func getCount() -> Int {
                return count
            }
        }
        
        // Load images asynchronously
        Task {
            let failureTracker = FailureTracker()
            
            // Load cover image first
            if let firstImageURL = userBook.image_urls.first {
                do {
                    let coverImage = try await StorageManager.shared.downloadImage(from: firstImageURL)
                    await MainActor.run {
                        self.generatedImages[0] = coverImage
                        self.isCoverImageGenerated = true
                    }
                } catch {
                    print("Error loading cover image: \(error)")
                    await failureTracker.increment()
                }
            }
            
            // Load remaining images in parallel with a limit
            let remainingURLs = Array(userBook.image_urls.dropFirst())
            let chunkSize = 3 // Process 3 images at a time
            
            for chunk in stride(from: 0, to: remainingURLs.count, by: chunkSize) {
                let end = min(chunk + chunkSize, remainingURLs.count)
                let urlChunk = Array(remainingURLs[chunk..<end])
                
                await withTaskGroup(of: (Int, UIImage?).self) { group in
                    for (index, urlString) in urlChunk.enumerated() {
                        group.addTask {
                            let actualIndex = chunk + index + 1
                            if let image = try? await StorageManager.shared.downloadImage(from: urlString) {
                                return (actualIndex, image)
                            }
                            await failureTracker.increment()
                            return (actualIndex, nil)
                        }
                    }
                    
                    for await (index, image) in group {
                        await MainActor.run {
                            self.generatedImages[index] = image
                            self.updateProgress()
                        }
                    }
                }
            }
            
            // Final update on main actor
            let failedCount = await failureTracker.getCount()
            await MainActor.run {
                self.isLoading = false
                if failedCount > 0 {
                    self.errorMessage = "Some images (\(failedCount)) failed to load. The story may not display correctly."
                }
            }
        }
    }
    
    func saveBookToFirestore() {
        guard let storySegment = storySegment else {
            print("Error: Story segment is nil.")
            return
        }

        let bookData: [String: Any] = [
            "title": storySegment.title,
            "author": "Generated Author",
            "coverImagePrompt": storySegment.coverImagePrompt,
            "contents": storySegment.contents.map { [
                "sentence": $0.sentence,
                "imagePrompt": $0.imagePrompt
            ]}
        ]

        db.collection("books").addDocument(data: bookData) { error in
            if let error = error {
                print("Error saving book to Firestore: \(error.localizedDescription)")
            } else {
                print("Book successfully saved!")
            }
        }
    }
    
    func saveStory() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        }

        guard let storySegment = self.storySegment else {
            print("Error: No story segment available.")
            return
        }

        let bookID = UUID().uuidString
        self.isSaving = true
        self.saveProgress = 0.0

        Task {
            do {
                // Upload images and generate URLs
                var imageURLs: [String] = []
                let totalImages = Double(self.generatedImages.count)

                for (index, image) in self.generatedImages.enumerated() {
                    if let image = image {
                        let imagePath = "books/\(userID)/\(bookID)/images/\(index).jpg"

                        let url = try await StorageManager.shared.uploadImage(image: image, path: imagePath)
                        imageURLs.append(url.absoluteString)
                        
                        // Update progress after each image upload
                        await MainActor.run {
                            // Images are 90% of the progress, saving data is the last 10%
                            self.saveProgress = (Double(index + 1) / totalImages) * 0.9
                        }
                    } else {
                        imageURLs.append("")
                        await MainActor.run {
                            self.saveProgress = (Double(index + 1) / totalImages) * 0.9
                        }
                    }
                }

                // Save all data to Firestore
                let storyData: [String: Any] = [
                    "book_id": bookID,
                    "user_id": userID,
                    "title": storySegment.title,
                    "cover_image_prompt": storySegment.coverImagePrompt,
                    "generated_texts": storySegment.contents.map { $0.sentence },
                    "image_prompts": storySegment.contents.map { $0.imagePrompt },
                    "image_urls": imageURLs,
                    "theme": self.selectedTheme,
                    "keywords": self.keywords,
                    "difficulty": self.selectedDifficulty,
                    "num_sentences": self.numSentences,
                    "date_created": FieldValue.serverTimestamp()
                ]

                // Save story data to Firestore
                let db = Firestore.firestore()
                try await db.collection("books").document(bookID).setData(storyData)

                print("Story saved successfully.")
                await MainActor.run {
                    self.saveProgress = 1.0
                    self.isSaving = false
                    self.isSaved = true
                }
            } catch {
                print("Error saving story: \(error.localizedDescription)")
                await MainActor.run {
                    self.saveProgress = 0.0
                    self.isSaving = false
                }
            }
        }
    }

    private func generateStoryContent() async throws -> StorySegment {
        let prompt = """
        You are a professional children's story writer. Create a fun and appropriate children's story using the three key words \(keywords.joined(separator: ", ")) and theme of \(selectedTheme). The story's difficulty is \(selectedDifficulty) years old, where it should contain \(numSentences) sentences. For each sentence, create a  descriptive and easy to understand natural language prompts ensuring consistency in illustration style, color palette, and character design across all images. Output the results in the following JSON format:
        {
          "title": "<Title>",
          "cover_image_prompt": "Children's book illustration, Watercolor illustration style, <Cover_Image_Prompt>",
          "contents": [
            {
              "sentence": "<Sentence 1>",
              "image_prompt": "Children's book illustration, Watercolor illustration style, <Image_Prompt 1>"
            }
          ]
        }
        """
        
        let result = try await model.generateContent(prompt)
        
        if let responseText = result.text {
            print("Raw Response: \(responseText)")
            
            let cleanedResponse = responseText
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
            
            print("Cleaned Response: \(cleanedResponse)")
            
            if let data = cleanedResponse.data(using: .utf8) {
                do {
                    let segment = try JSONDecoder().decode(StorySegment.self, from: data)
                    return segment
                } catch {
                    print("JSON Decoding Error: \(error)")
                    throw APIError.invalidImageData
                }
            }
        }
        
        throw APIError.invalidImageData
    }
}

// Add custom error enum
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case invalidImageData
    case invalidRequest(message: String)
    case rateLimited
    case serverError(statusCode: Int)
    case modelLoading
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .invalidImageData:
            return "Invalid image data received"
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .rateLimited:
            return "Rate limit exceeded"
        case .serverError(let code):
            return "Server error (Status: \(code))"
        case .modelLoading:
            return "Model is still loading"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
