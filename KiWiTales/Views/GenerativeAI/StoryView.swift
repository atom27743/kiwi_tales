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
    let progress: Double

    var body: some View {
        VStack {
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(.linear)
                .frame(width: 200)
                .padding(.bottom, 8)
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

struct CoverView: View {
    let title: String
    let coverImage: UIImage?
    let onStart: () -> Void
    
    var body: some View {
        ZStack {
            if let image = coverImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            
            VStack {
                Spacer()
                
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Material.ultraThinMaterial)
                    .cornerRadius(15)
                    .padding(.bottom, 30)
                
                Button(action: onStart) {
                    Text("Start Reading")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color.theme.accent)
                        .cornerRadius(25)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct StoryView: View {
    @ObservedObject var viewModel: GenerateStoryViewModel
    @State private var currentPage: Int = -1 // -1 represents cover page
    @State private var dragOffset: CGFloat = .zero
    @State private var currentOffset: CGFloat = .zero
    @State private var showCustomAlert: Bool = false
    @State private var showCover: Bool = true

    @Binding var selectGenerate: Bool

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Generating your story...")
                    .padding()
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error) {
                    viewModel.generateStory()
                }
            } else if let segment = viewModel.storySegment, viewModel.isFullyGenerated {
                if showCover {
                    CoverView(
                        title: segment.title,
                        coverImage: viewModel.generatedImages.first ?? nil,
                        onStart: { withAnimation { showCover = false } }
                    )
                } else {
                    displayGeneratedStory(segment: segment)
                }
            }

            // Exit Button
            displayExitButton()
                .padding(.top, 32)
                .padding()

            // Custom Alert
            if showCustomAlert {
                CustomAlert(showCustomAlert: $showCustomAlert, onSaveAndExit: {
                    viewModel.saveStory()
                    resetView()
                    selectGenerate = false
                }, onExit: {
                    resetView()
                    selectGenerate = false
                })
            }
        }
        .background(
            Group {
                if let image = viewModel.generatedImages[safe: currentPage], let validImage = image {
                    Image(uiImage: validImage)
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 10)
                        .ignoresSafeArea()
                } else {
                    Color.gray.opacity(0.2)
                        .ignoresSafeArea()
                }
            }
        )
        .onAppear {
            viewModel.generateStory()
        }
        .ignoresSafeArea()
    }

    private func resetView() {
        viewModel.keywords.removeAll()
        viewModel.selectedTheme.removeAll()
        viewModel.selectedDifficulty.removeAll()
        viewModel.isCoverImageGenerated = false
        viewModel.generatedImages.removeAll()
        selectGenerate = false
    }

    @ViewBuilder
    private func displayGeneratedStory(segment: StorySegment) -> some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(segment.contents.indices, id: \.self) { index in
                    PageView(imageURL: nil, imageName: viewModel.generatedImages[safe: index] ?? nil, text: segment.contents[index].sentence)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .frame(width: geometry.size.width * CGFloat(segment.contents.count), height: geometry.size.height)
            .offset(x: self.currentOffset + self.dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width / 2
                        if value.predictedEndTranslation.width < -threshold && currentPage < segment.contents.count - 1 {
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

        if currentPage >= segment.contents.count - 1 {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if viewModel.isSaved {
                        Image(systemName: "checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .background(Color.green)
                            .clipShape(Circle())
                    } else {
                        Button(action: {
                            viewModel.saveStory()
                        }) {
                            if viewModel.isSaving {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            } else {
                                Image(systemName: "square.and.arrow.down")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.white)
                                    .frame(width: 24, height: 24)
                                    .padding(8)
                                    .background(Color.accent)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                .padding(.bottom, 134)
                .padding(.trailing, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .background(Color.clear)
        }

        PageIndicator(currentPage: $currentPage, totalPages: segment.contents.count)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 60)
            .padding(.top, 76)
    }

    @ViewBuilder
    private func displayExitButton() -> some View {
        VStack {
            HStack {
                Button(action: {
                    if !viewModel.isSaved {
                        showCustomAlert = true
                    } else {
                        resetView()
                        selectGenerate = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 36))
                }
                .padding()

                Spacer()
            }
            Spacer()
        }
    }
}

#Preview {
    StoryView(viewModel: .init(), selectGenerate: .constant(true))
}
