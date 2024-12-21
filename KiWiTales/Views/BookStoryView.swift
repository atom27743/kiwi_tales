//
//  BookStoryView.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 9/24/24.
//

import SwiftUI
import FirebaseFirestore

//struct BookStoryView: View {
//    let book: UserBook
//    @Binding var showStoryView: Bool
//    
//    @State private var currentPage: Int = 0
//    @State private var dragOffset: CGFloat = .zero
//    @State private var currentOffset: CGFloat = .zero
//    @State private var isStoryStarted: Bool = false
//    
//    var body: some View {
//        ZStack {
//            if !isStoryStarted {
//                displayCoverPage()
//            } else {
//                displayStoryContent()
//            }
//            
//            // Exit button
//            VStack {
//                HStack {
//                    Button {
//                        showStoryView = false
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.title)
//                            .foregroundColor(.gray)
//                            .padding()
//                    }
//                    Spacer()
//                }
//                Spacer()
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private func displayCoverPage() -> some View {
//        VStack(spacing: 20) {
//            Text(book.title)
//                .font(.largeTitle)
//                .bold()
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//            
//            VStack(spacing: 10) {
//                Text("Theme: \(book.theme)")
//                    .font(.headline)
//                Text("Reading Level: \(book.difficulty)")
//                    .font(.subheadline)
//            }
//            .foregroundColor(.secondary)
//            
//            if let url = URL(string: book.image_urls[0]) {
//                AsyncImage(url: url) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView()
//                            .frame(width: 300, height: 300)
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxWidth: 300, maxHeight: 300)
//                            .cornerRadius(15)
//                            .shadow(radius: 5)
//                    case .failure:
//                        Image(systemName: "photo")
//                            .font(.system(size: 100))
//                            .foregroundColor(.gray)
//                            .frame(width: 300, height: 300)
//                    @unknown default:
//                        EmptyView()
//                    }
//                }
//                .padding()
//            }
//            
//            Button {
//                withAnimation {
//                    isStoryStarted = true
//                }
//            } label: {
//                HStack {
//                    Text("Start Reading")
//                    Image(systemName: "arrow.right")
//                }
//                .padding()
//                .background(Color.accentColor)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//            }
//            .padding(.top)
//        }
//        .padding()
//    }
//    
//    @ViewBuilder
//    private func displayStoryContent() -> some View {
//        GeometryReader { geometry in
//            VStack {
//                // Content
//                ScrollViewReader { scrollProxy in
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 0) {
//                            ForEach(0..<book.generated_texts.count, id: \.self) { index in
//                                VStack(spacing: 20) {
//                                    if index < book.image_urls.count,
//                                       let url = URL(string: book.image_urls[index]) {
//                                        AsyncImage(url: url) { phase in
//                                            switch phase {
//                                            case .empty:
//                                                ProgressView()
//                                                    .frame(maxWidth: geometry.size.width * 0.8,
//                                                           maxHeight: geometry.size.width * 0.8)
//                                            case .success(let image):
//                                                image
//                                                    .resizable()
//                                                    .scaledToFit()
//                                                    .frame(maxWidth: geometry.size.width * 0.8)
//                                                    .cornerRadius(15)
//                                                    .shadow(radius: 5)
//                                            case .failure:
//                                                Image(systemName: "photo")
//                                                    .font(.system(size: 100))
//                                                    .foregroundColor(.gray)
//                                                    .frame(maxWidth: geometry.size.width * 0.8,
//                                                           maxHeight: geometry.size.width * 0.8)
//                                            @unknown default:
//                                                EmptyView()
//                                            }
//                                        }
//                                        .padding()
//                                    }
//                                    
//                                    Text(book.generated_texts[index])
//                                        .font(.body)
//                                        .padding(.horizontal)
//                                        .multilineTextAlignment(.center)
//                                        .frame(maxWidth: geometry.size.width * 0.8)
//                                }
//                                .frame(width: geometry.size.width)
//                                .id(index)
//                            }
//                        }
//                    }
//                    .content.offset(x: currentOffset + dragOffset)
//                    .gesture(
//                        DragGesture()
//                            .onChanged { value in
//                                dragOffset = value.translation.width
//                            }
//                            .onEnded { value in
//                                let threshold = geometry.size.width * 0.5
//                                let newPage = value.translation.width > threshold ? currentPage - 1 :
//                                    value.translation.width < -threshold ? currentPage + 1 :
//                                    currentPage
//                                
//                                currentPage = max(0, min(newPage, book.generated_texts.count - 1))
//                                withAnimation(.spring()) {
//                                    dragOffset = 0
//                                    currentOffset = -geometry.size.width * CGFloat(currentPage)
//                                }
//                                
//                                // Ensure the current page is visible
//                                withAnimation {
//                                    scrollProxy.scrollTo(currentPage, anchor: .center)
//                                }
//                            }
//                    )
//                }
//                
//                // Navigation buttons
//                HStack(spacing: 30) {
//                    Button {
//                        withAnimation(.spring()) {
//                            currentPage = max(0, currentPage - 1)
//                            currentOffset = -geometry.size.width * CGFloat(currentPage)
//                        }
//                    } label: {
//                        Image(systemName: "chevron.left.circle.fill")
//                            .font(.title)
//                            .foregroundColor(currentPage > 0 ? .accentColor : .gray)
//                    }
//                    .disabled(currentPage == 0)
//                    
//                    // Page indicator
//                    HStack(spacing: 8) {
//                        ForEach(0..<book.generated_texts.count, id: \.self) { index in
//                            Circle()
//                                .fill(currentPage == index ? Color.accentColor : Color.gray.opacity(0.3))
//                                .frame(width: 8, height: 8)
//                        }
//                    }
//                    
//                    Button {
//                        withAnimation(.spring()) {
//                            currentPage = min(book.generated_texts.count - 1, currentPage + 1)
//                            currentOffset = -geometry.size.width * CGFloat(currentPage)
//                        }
//                    } label: {
//                        Image(systemName: "chevron.right.circle.fill")
//                            .font(.title)
//                            .foregroundColor(currentPage < book.generated_texts.count - 1 ? .accentColor : .gray)
//                    }
//                    .disabled(currentPage == book.generated_texts.count - 1)
//                }
//                .padding(.bottom)
//            }
//        }
//        .edgesIgnoringSafeArea(.horizontal)
//    }
//}

import SwiftUI

struct BookStoryView: View {
    let book: UserBook
    @Binding var showStoryView: Bool
    
    @State private var currentPage: Int = 0
    @State private var dragOffset: CGFloat = .zero
    @State private var currentOffset: CGFloat = .zero
    @State private var isStoryStarted: Bool = false
    @State private var showCustomAlert: Bool = false

    var body: some View {
        ZStack {
            if !isStoryStarted {
                displayCoverPage()
            } else {
                displaySavedStory()
            }
            
            // Exit button
            displayExitButton()

            // Custom Alert
            if showCustomAlert {
                CustomAlert(showCustomAlert: $showCustomAlert, onSaveAndExit: {
                    resetView()
                    showStoryView = false
                }, onExit: {
                    resetView()
                    showStoryView = false
                })
            }
        }
        .background(
            Group {
                if let imageURL = book.image_urls[safe: currentPage], let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .blur(radius: 10)
                                .ignoresSafeArea()
                        default:
                            Color.gray.opacity(0.2)
                                .ignoresSafeArea()
                        }
                    }
                } else {
                    Color.gray.opacity(0.2)
                        .ignoresSafeArea()
                }
            }
        )
    }
    
    private func resetView() {
        currentPage = 0
        dragOffset = .zero
        currentOffset = .zero
        isStoryStarted = false
    }

    @ViewBuilder
    private func displayCoverPage() -> some View {
        VStack(spacing: 20) {
            Text(book.title)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                Text("Theme: \(book.theme)")
                    .font(.headline)
                Text("Reading Level: \(book.difficulty)")
                    .font(.subheadline)
            }
            .foregroundColor(.secondary)
            
            if let imageURL = book.image_urls.first, !imageURL.isEmpty, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300, maxHeight: 300)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 100))
                            .foregroundColor(.gray)
                            .frame(width: 300, height: 300)
                    default:
                        ProgressView()
                            .frame(width: 300, height: 300)
                    }
                }
                .padding()
            }
            
            Button {
                withAnimation {
                    isStoryStarted = true
                }
            } label: {
                HStack {
                    Text("Start Reading")
                    Image(systemName: "arrow.right")
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
    }
    
    @ViewBuilder
    private func displaySavedStory() -> some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(0..<book.generated_texts.count, id: \.self) { index in
                    BookPageView(
                        imageURL: book.image_urls[safe: index],
                        text: book.generated_texts[index]
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .frame(width: geometry.size.width * CGFloat(book.generated_texts.count), height: geometry.size.height)
            .offset(x: currentOffset + dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width / 2
                        if value.predictedEndTranslation.width < -threshold && currentPage < book.generated_texts.count - 1 {
                            currentPage += 1
                        } else if value.predictedEndTranslation.width > threshold && currentPage > 0 {
                            currentPage -= 1
                        }
                        withAnimation {
                            dragOffset = 0
                            currentOffset = -geometry.size.width * CGFloat(currentPage)
                        }
                    }
            )
        }

        if currentPage >= book.generated_texts.count - 1 {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .padding(8)
                        .background(Color.green)
                        .clipShape(Circle())
                }
                .padding(.bottom, 134)
                .padding(.trailing, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .background(Color.clear)
        }

        PageIndicator(currentPage: $currentPage, totalPages: book.generated_texts.count)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 60)
            .padding(.top, 76)
    }
    
    @ViewBuilder
    private func displayExitButton() -> some View {
        VStack {
            HStack {
                Button(action: {
                    resetView()
                    showStoryView = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                }
                Spacer()
            }
            Spacer()
        }
    }
}

struct BookPageView: View {
    let imageURL: String?
    let text: String
    
    var body: some View {
        ZStack {
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                            .ignoresSafeArea()
                            .clipped()
                    default:
                        Color.gray.opacity(0.2)
                            .ignoresSafeArea()
                    }
                }
            } else {
                Color.gray.opacity(0.2)
                    .ignoresSafeArea()
            }

            VStack {
                Spacer()
                
                VStack {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        let textArray = Array(text)
                        let firstValidIndex = textArray.firstIndex { $0.isLetter || $0.isNumber }
                        
                        if let index = firstValidIndex {
                            Text(String(textArray.prefix(index)))
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.white)
                            
                            Text(String(textArray[index]))
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(String(textArray.dropFirst(index + 1)))
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        } else {
                            Text(text)
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding()
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 230)
                .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 20.0))
                .ignoresSafeArea(edges: .bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
        }
    }
}
