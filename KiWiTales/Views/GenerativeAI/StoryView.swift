//
//  StoryView.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 9/22/24.
//

import SwiftUI
import UIKit
import FirebaseAuth

struct LoadingView: View {
    let message: String

    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text(message)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Material.ultraThinMaterial)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Material.ultraThinMaterial)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct StoryView: View {
    @ObservedObject var viewModel: GenerateStoryViewModel
    var userBook: UserBook?
    @State private var currentPage: Int = 0
    @State private var dragOffset: CGFloat = .zero
    @State private var currentOffset: CGFloat = .zero
    @State private var isStoryStarted: Bool = false
    @State private var showCustomAlert = false
    @Binding var selectGenerate: Bool

    // Computed property to check if the story is fully ready
    var isReadyToDisplay: Bool {
        return !viewModel.isLoading &&
               viewModel.storySegment != nil &&
               viewModel.generatedImages.count == viewModel.storySegment?.contents.count
    }

    var body: some View {
        ZStack {
            if !isReadyToDisplay {
                LoadingView(message: "Loading story...")
            } else if !isStoryStarted && viewModel.isCoverImageGenerated {
                displayCoverPage()
            } else if isStoryStarted && viewModel.storySegment != nil {
                displayStoryContent()
            }

            displayExitButton()

            if showCustomAlert {
                CustomAlert(showCustomAlert: $showCustomAlert) {
                    viewModel.saveStory()
                    resetView()
                } onExit: {
                    resetView()
                    selectGenerate = false
                    showCustomAlert = false
                }
            }
        }
        .background(
            Group {
                if let uiImage = viewModel.generatedImages.safeElement(at: currentPage),
                   let validImage = uiImage {
                    Image(uiImage: validImage)
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 10)
                        .ignoresSafeArea()
                } else {
                    Color.theme.background
                        .ignoresSafeArea()
                }
            }
        )
    }

    @ViewBuilder
    private func displayCoverPage() -> some View {
        if let coverImage = viewModel.generatedImages.first,
           let validImage = coverImage {
            VStack {
                Image(uiImage: validImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                Text(viewModel.storySegment?.title ?? "Loading Title...")
                    .font(.title.bold())
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()

                Button(action: {
                    isStoryStarted = true
                }) {
                    Text("Start Story")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.theme.accent)
                        .cornerRadius(18)
                }
                .padding(.bottom, 40)
            }
        }
    }

    @ViewBuilder
    private func displayStoryContent() -> some View {
        if let segment = viewModel.storySegment {
            GeometryReader { geometry in
                VStack {
                    HStack(spacing: 0) {
                        ForEach(0..<segment.contents.count, id: \.self) { index in
                            VStack {
                                if let image = viewModel.generatedImages.safeElement(at: index + 1),
                                   let uiImage = image {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: geometry.size.width * 0.8)
                                        .cornerRadius(10)
                                        .padding()
                                } else {
                                    ProgressView("Generating image...")
                                        .frame(width: geometry.size.width * 0.8, height: 200)
                                }

                                Text(segment.contents[index].sentence)
                                    .padding()
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: geometry.size.width)
                            .offset(x: geometry.size.width * CGFloat(index) + dragOffset + currentOffset)
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if isReadyToDisplay {
                                    dragOffset = value.translation.width
                                }
                            }
                            .onEnded { value in
                                if isReadyToDisplay {
                                    let threshold = geometry.size.width * 0.5
                                    let newPage = value.translation.width > threshold ? currentPage - 1 :
                                        value.translation.width < -threshold ? currentPage + 1 :
                                        currentPage

                                    currentPage = max(0, min(newPage, segment.contents.count - 1))
                                    withAnimation {
                                        dragOffset = 0
                                        currentOffset = -geometry.size.width * CGFloat(currentPage)
                                    }
                                }
                            }
                    )

                    // Add save button at the bottom when on the last page
                    if currentPage == segment.contents.count - 1 {
                        VStack {
                            if viewModel.isSaving {
                                ProgressView("Saving story...")
                                    .foregroundColor(.primary)
                                    .padding()
                            } else if !viewModel.isSaved {
                                Button(action: {
                                    viewModel.saveStory()
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.down")
                                        Text("Save Story")
                                    }
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .padding(.bottom)
                            } else {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Story Saved!")
                                }
                                .foregroundColor(.green)
                                .padding()
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func displayExitButton() -> some View {
        VStack {
            HStack {
                Button {
                    if !viewModel.isSaved {
                        showCustomAlert = true
                    } else {
                        showCustomAlert = false
                        resetView()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 36))
                }
                .padding()

                Spacer()
            }

            Spacer()
        }
    }

    private func resetView() {
        viewModel.keywords.removeAll()
        viewModel.selectedTheme.removeAll()
        viewModel.selectedDifficulty.removeAll()

        viewModel.isCoverImageGenerated = false
        viewModel.generatedImages.removeAll()
        isStoryStarted = false

        selectGenerate = false
    }
}

#Preview {
    StoryView(viewModel: .init(), selectGenerate: .constant(true))
}

//import SwiftUI
//import FirebaseAuth
//
//struct StoryView: View {
//    @ObservedObject var viewModel: GenerateStoryViewModel
//    @State private var currentPage: Int = 0
//    @State private var isStoryStarted: Bool = false
//    var userBook: UserBook?
//    @Binding var selectGenerate: Bool
//
//    var body: some View {
//        VStack {
//            if !isStoryStarted {
//                Button("Start Story") {
//                    isStoryStarted = true
//                }
//                .padding()
//            } else {
//                if let story = viewModel.storySegment {
//                    ScrollView {
//                        VStack {
//                            Text(story.title)
//                                .font(.largeTitle)
//                                .padding()
//
//                            ForEach(0..<story.contents.count, id: \.self) { index in
//                                if let image = viewModel.generatedImages[index] {
//                                    Image(uiImage: image)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(height: 200)
//                                }
//                                Text(story.contents[index].sentence)
//                                    .padding()
//                            }
//
//                            if viewModel.isSaving {
//                                ProgressView("Saving...")
//                            } else if viewModel.isSaved {
//                                Text("Story Saved!")
//                                    .foregroundColor(.green)
//                            } else {
//                                Button("Save Story") {
//                                    viewModel.saveStory()
//                                }
//                                .padding()
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .padding()
//    }
//}
