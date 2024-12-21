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

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

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
                        .padding(.horizontal, 12)

                    ForEach(exploreViewModel.booksByTheme.keys.sorted(), id: \.self) { theme in
                        VStack(alignment: .leading) {
                            Text(theme)
                                .font(.headline)
                                .padding(.horizontal, 34)

                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(exploreViewModel.booksByTheme[theme] ?? []) { book in
                                    VStack {
                                        exploreBook(book)
                                            .onTapGesture {
                                                Task {
                                                    isLoadingBook = true
                                                    // Ensure the book data is fully loaded before showing the sheet
                                                    if let updatedBook = await exploreViewModel.getBookDetails(book.id ?? "") {
                                                        selectedBook = updatedBook
                                                        showStoryView = true
                                                    }
                                                    isLoadingBook = false
                                                }
                                            }
                                    }
                                    .frame(height: 310, alignment: .top)
                                }
                            }
                            .padding(.horizontal)
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
                            .frame(width: 165, height: 250)
                            .background(Color.gray)
                            .cornerRadius(10)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 165, height: 250)
                            .cornerRadius(10)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 165, height: 250)
                            .cornerRadius(10)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 150, height: 250)
                    .cornerRadius(10)
            }

            Text(book.title)
                .nunito(.bold, 14.0)
                .foregroundStyle(Color.theme.text)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
        }
    }
    
    private var filterButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(filters, id: \.self) { filter in
                    Text(filter)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(exploreViewModel.selectedFilter == filter ? Color.accent : Color.theme.secondary)
                        .foregroundStyle(exploreViewModel.selectedFilter == filter ? .white : .black)
                        .cornerRadius(20)
                        .onTapGesture {
                            exploreViewModel.selectedFilter = filter
                            exploreViewModel.filterBooks()
                        }
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}

#Preview {
    @Previewable
    @State var selectedTab: Tabs = .explore
    
    ExploreView(profileViewModel: .init(), exploreViewModel: .init(), showSignInView: .constant(false), selectedTab: $selectedTab, showMenu: .constant(true))
}
