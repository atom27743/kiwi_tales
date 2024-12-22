//
//  BookStoryView.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 9/24/24.
//

import SwiftUI
import FirebaseFirestore

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
            
            HStack {
                Spacer()
                displayExitButton()
            }
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
                    ZStack {
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
                        Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    }
                } else {
                    Color.gray.opacity(0.9)
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
        VStack(spacing: 8) {
            Text(book.title)
                .nunito(.extraBold, 36)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
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
            
            VStack(spacing: 6) {
                Text("Theme: \(book.theme)")
                    .nunito(.semiBold, 18)
                Text("Reading Level: \(book.difficulty)")
                    .nunito(.semiBold, 18)
            }
            .foregroundColor(.white)
            
            Button(action: {
                withAnimation {
                    isStoryStarted = true
                }
            }) {
                HStack {
                    Text("Start Reading")
                    Image(systemName: "arrow.right")
                }
                .font(.nunito(.bold, 18))
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(20)
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
                        .frame(width: 14, height: 14)
                        .padding(12)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .font(.system(size: 18, weight: .bold))
                }
                .padding(.bottom, 160)
                .padding(.trailing, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .background(Color.clear)
        }

        PageIndicator(currentPage: $currentPage, totalPages: book.generated_texts.count)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 60)
            .padding(.top, 60)
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
                        .foregroundColor(Color.white.opacity(0.8))
                        .padding(.top, 20)
                        .padding(.leading, 20)
                }
                .scaleEffect(1.2)
                Spacer()
            }
            Spacer()
        }
    }
}
