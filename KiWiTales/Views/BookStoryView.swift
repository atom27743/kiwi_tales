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
    
    var body: some View {
        ZStack {
            if !isStoryStarted {
                displayCoverPage()
            } else {
                displayStoryContent()
            }
            
            // Exit button
            VStack {
                HStack {
                    Button {
                        showStoryView = false
                    } label: {
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
            
            if let url = URL(string: book.image_urls[0]) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 300, height: 300)
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
                    @unknown default:
                        EmptyView()
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
    private func displayStoryContent() -> some View {
        GeometryReader { geometry in
            VStack {
                // Content
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(0..<book.generated_texts.count, id: \.self) { index in
                                VStack(spacing: 20) {
                                    if index + 1 < book.image_urls.count,
                                       let url = URL(string: book.image_urls[index + 1]) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(maxWidth: geometry.size.width * 0.8,
                                                           maxHeight: geometry.size.width * 0.8)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(maxWidth: geometry.size.width * 0.8)
                                                    .cornerRadius(15)
                                                    .shadow(radius: 5)
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .font(.system(size: 100))
                                                    .foregroundColor(.gray)
                                                    .frame(maxWidth: geometry.size.width * 0.8,
                                                           maxHeight: geometry.size.width * 0.8)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .padding()
                                    }
                                    
                                    Text(book.generated_texts[index])
                                        .font(.body)
                                        .padding(.horizontal)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: geometry.size.width * 0.8)
                                }
                                .frame(width: geometry.size.width)
                                .id(index)
                            }
                        }
                    }
                    .content.offset(x: currentOffset + dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                let threshold = geometry.size.width * 0.5
                                let newPage = value.translation.width > threshold ? currentPage - 1 :
                                    value.translation.width < -threshold ? currentPage + 1 :
                                    currentPage
                                
                                currentPage = max(0, min(newPage, book.generated_texts.count - 1))
                                withAnimation(.spring()) {
                                    dragOffset = 0
                                    currentOffset = -geometry.size.width * CGFloat(currentPage)
                                }
                                
                                // Ensure the current page is visible
                                withAnimation {
                                    scrollProxy.scrollTo(currentPage, anchor: .center)
                                }
                            }
                    )
                }
                
                // Navigation buttons
                HStack(spacing: 30) {
                    Button {
                        withAnimation(.spring()) {
                            currentPage = max(0, currentPage - 1)
                            currentOffset = -geometry.size.width * CGFloat(currentPage)
                        }
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title)
                            .foregroundColor(currentPage > 0 ? .accentColor : .gray)
                    }
                    .disabled(currentPage == 0)
                    
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<book.generated_texts.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.accentColor : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Button {
                        withAnimation(.spring()) {
                            currentPage = min(book.generated_texts.count - 1, currentPage + 1)
                            currentOffset = -geometry.size.width * CGFloat(currentPage)
                        }
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title)
                            .foregroundColor(currentPage < book.generated_texts.count - 1 ? .accentColor : .gray)
                    }
                    .disabled(currentPage == book.generated_texts.count - 1)
                }
                .padding(.bottom)
            }
        }
        .edgesIgnoringSafeArea(.horizontal)
    }
}
