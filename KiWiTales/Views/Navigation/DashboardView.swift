//
//  DashboardView.swift
//  KiWi
//
//  Created by Takumi Otsuka on 8/10/24.
//

import SwiftUI

struct DashboardView: View {
    @State var selectedIndex: Int = 0
    @Binding var selectedTab: Tabs
    @Binding var showMenu: Bool

    @StateObject var userBooksViewModel = UserBookViewModel()
    @StateObject private var storyViewModel = GenerateStoryViewModel()
    @State private var isBookOpen = false
    @State private var showStoryView = false
    @Namespace private var animation

    var body: some View {
        ZStack {
            VStack {
                CustomNavigationBar(
                    showMenu: $showMenu,
                    selectedTab: $selectedTab,
                    headerTitle: "My Books",
                    headerImage: "family_star",
                    headerColor: Color.theme.primary
                )

                GeometryReader { geo in
                    ZStack {
                        // Background Circles
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: geo.size.width * 1.3, height: geo.size.width * 1.3)
                            .position(x: geo.size.width / 2, y: geo.size.height * 0.8)

                        Circle()
                            .fill(Color.orange)
                            .frame(width: geo.size.width * 1.2, height: geo.size.width * 1.2)
                            .position(x: geo.size.width / 2, y: geo.size.height * 0.8)

                        // Content
                        VStack {
                            if !userBooksViewModel.books.isEmpty {
                                // Book Carousel
                                BookCarousel(
                                    selectedIndex: $selectedIndex,
                                    books: userBooksViewModel.books
                                )
                                .frame(width: UIScreen.main.bounds.width, height: 400)
                                .offset(x: 0)
                                .onTapGesture {
                                    if selectedIndex < userBooksViewModel.books.count {
                                        showStoryView = true
                                    }
                                }
                            } else {
                                Text("No books available")
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .background(Color.theme.background)
            .ignoresSafeArea()

            // Full screen story view
            if showStoryView && selectedIndex < userBooksViewModel.books.count {
                StoryView(
                    viewModel: storyViewModel,
                    userBook: userBooksViewModel.books[selectedIndex],
                    selectGenerate: .constant(false)
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .onAppear {
            userBooksViewModel.fetchUserBooks()
        }
    }
}


#Preview {
    @Previewable @State var selectedTab: Tabs = .dashboard
    @Previewable @State var showMenu: Bool = false

    return DashboardView(selectedTab: $selectedTab, showMenu: $showMenu)
}
