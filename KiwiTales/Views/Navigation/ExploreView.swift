//
//  ExploreView.swift
//  KiWi
//
//  Created by Takumi Otsuka on 8/10/24.
//

import SwiftUI

struct ExploreView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var exploreViewModel: ExploreViewModel

    @Binding var showSignInView: Bool
    @Binding var selectedTab: Tabs
    @Binding var showMenu: Bool

    let filters = ["All", "Fantasy", "Nature", "Family", "Adventure"]

    private var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var columns: [GridItem] {
        if isIPad {
            return [
                GridItem(.flexible(), spacing: 30),
                GridItem(.flexible(), spacing: 30),
                GridItem(.flexible(), spacing: 30)
            ]
        } else {
            return [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ]
        }
    }

    @State private var showStoryView = false
    @State private var selectedBook: UserBook?
    @State private var isLoadingBook = false

    var body: some View {
        VStack {
            CustomNavigationBar(showMenu: $showMenu, selectedTab: $selectedTab, headerTitle: "Explore", headerImage: "explore", headerColor: Color.theme.accent)

            if exploreViewModel.isLoading {
                ProgressView("Loading books...")
                    .frame(maxHeight: .infinity)
            } else if let error = exploreViewModel.errorMessage {
                VStack {
                    Text("Error loading books")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Button("Retry") {
                        exploreViewModel.fetchBooks()
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity)
            } else if exploreViewModel.books.isEmpty {
                Text("No books available")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    filterButtons
                        .padding(.horizontal, isIPad ? 40 : 12)

                    ForEach(exploreViewModel.booksByTheme.keys.sorted(), id: \.self) { theme in
                        VStack(alignment: .leading) {
                            Text(theme)
                                .foregroundStyle(Color.theme.text)
                                .font(.headline)
                                .padding(.horizontal, isIPad ? 50 : 34)

                            LazyVGrid(columns: columns, spacing: isIPad ? 40 : 20) {
                                ForEach(exploreViewModel.booksByTheme[theme] ?? []) { book in
                                    VStack {
                                        exploreBook(book)
                                            .onTapGesture {
                                                Task {
                                                    isLoadingBook = true
                                                    if let updatedBook = await exploreViewModel.getBookDetails(book.id ?? "") {
                                                        selectedBook = updatedBook
                                                        showStoryView = true
                                                    }
                                                    isLoadingBook = false
                                                }
                                            }
                                    }
                                    .frame(height: isIPad ? 400 : 310, alignment: .top)
                                }
                            }
                            .padding(.horizontal, isIPad ? 40 : 16)
                        }
                        .padding(.top)
                    }
                }
                .padding(.bottom, 120)
            }
        }
        .background(Color.theme.background)
        .ignoresSafeArea()
        .onAppear {
            exploreViewModel.fetchBooks()
        }
        .fullScreenCover(isPresented: $showStoryView, onDismiss: {
            selectedBook = nil
        }) {
            if let selectedBook = selectedBook {
                BookStoryView(book: selectedBook, showStoryView: $showStoryView)
            }
        }
        .overlay {
            if isLoadingBook {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay {
                        VStack {
                            ProgressView()
                                .tint(.white)
                            Text("Loading book...")
                                .foregroundColor(.white)
                                .padding(.top, 8)
                        }
                        .padding()
                        .background(Material.ultraThin)
                        .cornerRadius(10)
                    }
            }
        }
    }
    
    private func exploreBook(_ book: UserBook) -> some View {
        VStack {
            if let imageURL = book.image_urls.first {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: isIPad ? 220 : 165, height: isIPad ? 330 : 250)
                            .background(Color.gray)
                            .cornerRadius(15)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: isIPad ? 220 : 165, height: isIPad ? 330 : 250)
                            .cornerRadius(15)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: isIPad ? 220 : 165, height: isIPad ? 330 : 250)
                            .cornerRadius(15)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: isIPad ? 220 : 150, height: isIPad ? 330 : 250)
                    .cornerRadius(15)
            }

            Text(book.title)
                .nunito(.bold, isIPad ? 18 : 14)
                .foregroundStyle(Color.theme.text)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, isIPad ? 16 : 12)
                .padding(.bottom, isIPad ? 10 : 6)
        }
    }
    
    private var filterButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(filters, id: \.self) { filter in
                    Text(filter)
                        .nunito(.semiBold, isIPad ? 18 : 14)
                        .padding(.vertical, isIPad ? 14 : 10)
                        .padding(.horizontal, isIPad ? 30 : 20)
                        .background(exploreViewModel.selectedFilter == filter ? Color.accent : Color.theme.secondary)
                        .foregroundStyle(exploreViewModel.selectedFilter == filter ? .white : .black)
                        .cornerRadius(25)
                        .onTapGesture {
                            exploreViewModel.selectedFilter = filter
                            exploreViewModel.filterBooks()
                        }
                }
            }
            .padding(.horizontal, isIPad ? 40 : 16)
        }
        .padding(.top, isIPad ? 30 : 20)
    }
}

#Preview {
    @Previewable
    @State var selectedTab: Tabs = .explore
    
    ExploreView(profileViewModel: .init(), exploreViewModel: .init(), showSignInView: .constant(false), selectedTab: $selectedTab, showMenu: .constant(true))
}
