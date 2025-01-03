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
    
    private var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
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
                .offset(y: isIPad ? -120 : -80) // Shift the entire carousel upwards by 80 points. Adjust this value as needed.
                
                if selectedIndex < books.count {
                    Text(books[selectedIndex].title)
                        .nunito(.extraBold, isIPad ? 36 : 28)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, isIPad ? 32 : 16)
                        .offset(y: isIPad ? -50 : -35)
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
            .frame(
                width: isIPad ? geometry.size.width * 0.4 : geometry.size.width * 0.5,
                height: isIPad ? geometry.size.height * 0.8 : geometry.size.height * 0.7
            )
            .cornerRadius(isIPad ? 20 : 15)
            .shadow(radius: isIPad ? 8 : 5)
            .opacity(selectedIndex == index ? 1.0 : 0.6)
            .blur(radius: selectedIndex == index ? 0 : 1)
            .scaleEffect(selectedIndex == index ? 1.2 : 0.9)
            .rotationEffect(.degrees(Double(index - selectedIndex) * (isIPad ? 12 : 15)))
            .offset(
                x: CGFloat(index - selectedIndex) * (geometry.size.width * (isIPad ? 0.5 : 0.6) + (isIPad ? 30 : 20)) + dragOffset,
                y: selectedIndex == index ? (isIPad ? -40 : -20) : (isIPad ? 70 : 50)
            )
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
