//
//  BookCarousel.swift
//  KiWi
//
//  Created by Takumi Otsuka on 8/10/24.

import SwiftUI
import Combine

struct BookCarousel: View {
    @Binding var selectedIndex: Int
    var books: [UserBook]
    @State private var dragOffset: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.05) // Placeholder to force the selected book into the center
                        Spacer()
                    }
                    
                    ForEach(books.indices, id: \.self) { index in
                        coverImage(book: books[index], index: index, geometry: geometry)
                    }
                }
                .offset(y: -80) // Shift the entire carousel upwards by 80 points. Adjust this value as needed.
                
                if selectedIndex < books.count {
                    Text(books[selectedIndex].title)
                        .nunito(.extraBold, 28)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                        .offset(y: -35)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width / 2 // Reduce drag offset for smoother visual transition
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width * 0.3
                        if value.translation.width > threshold {
                            selectedIndex = max(selectedIndex - 1, 0)
                        } else if value.translation.width < -threshold {
                            selectedIndex = min(selectedIndex + 1, books.count - 1)
                        }
                        withAnimation {
                            dragOffset = 0
                        }
                    }
            )
        }
    }
    
    private func coverImage(book: UserBook, index: Int, geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()

            AsyncImage(url: URL(string: books.safeElement(at: index)?.image_urls.first ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } placeholder: {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.7)
            .cornerRadius(15)
            .shadow(radius: 5)
            .opacity(selectedIndex == index ? 1.0 : 0.6)
            .blur(radius: selectedIndex == index ? 0 : 1)
            .scaleEffect(selectedIndex == index ? 1.2 : 0.9)
            .rotationEffect(.degrees(Double(index - selectedIndex) * 15))
            .offset(x: CGFloat(index - selectedIndex) * (geometry.size.width * 0.6 + 20) + dragOffset, y: selectedIndex == index ? -20 : 50)
            .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.5), value: selectedIndex)
            
            Spacer()
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: Tabs = .dashboard
    @Previewable @State var showMenu: Bool = false

    return DashboardView(selectedTab: $selectedTab, showMenu: $showMenu)
}
