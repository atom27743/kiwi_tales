//
//  HomeView.swift
//  KiWi
//
//  Created by Takumi Otsuka on 8/10/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject var userBooksViewModel = UserBookViewModel()
    @StateObject var viewModel: GenerateStoryViewModel = .init()
    
    @ObservedObject var exploreViewModel: ExploreViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    
    @Binding var selectGenerate: Bool
    @Binding var selectedTab: Tabs
    @Binding var showMenu: Bool
    @Binding var showSignInView: Bool
    
    @State private var selectedBook: UserBook? = nil
    @State private var showStoryView = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                // MARK: - CustomNavigationBar
                CustomNavigationBarHome(selectedTab: $selectedTab, showMenu: $showMenu)
                
                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        Image("home_banner")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                        VStack(alignment: .leading, spacing: -8) {
                            Text("Write your own")
                                .nunito(.semiBold, 26)
                                .foregroundStyle(Color.white)
                            Text("Fairytale")
                                .nunito(.extraBold, 26)
                                .foregroundStyle(Color.white)
                        }
                        .padding([.top, .leading], 32)
                        
                        ZStack(alignment: .bottom) {
                            Button {
                                selectGenerate = true
                            } label: {
                                Text("Start")
                                    .nunito(.extraBold, 18)
                                    .frame(width: 130, height: 40)
                                    .padding(6)
                                    .background(Color.theme.accent)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                            }
                            .foregroundStyle(Color.white)
                            .shadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 24)
                    }
                    
                    // MARK: - Shows the last 5 updated books in user's repository
                    VStack(alignment: .leading) {
                        Button {
                            selectedTab = .dashboard
                        } label: {
                            HStack(spacing: 8) {
                                Text("My Books")
                                    .nunito(.extraBold, 16)
                                Image("family_star")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 22, height: 22)
                            }
                            .padding(.leading, 23)
                        }
                        .padding(.leading, 9)
                        .padding(.bottom, -8)
                        .tint(.theme.text)
                        
                        if profileViewModel.user != nil {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 22) {
                                    books(userBooksViewModel.books)
                                }
                                .frame(height: 170)
                                .padding([.leading, .trailing], 30)
                                .foregroundStyle(.black)
                            }
                        } else {
                            Text("Sign in to start creating stories.")
                                .frame(height: 170)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.leading, 23)
                        }
                    }
                    .padding(.top, 19)
                    
                    // MARK: - Shows the top 5 books from the public
                    VStack(alignment: .leading) {
                        Button {
                            selectedTab = .explore
                        } label: {
                            HStack(spacing: 8) {
                                Text("Explore")
                                    .nunito(.extraBold, 16)
                                Image("explore")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 22, height: 22)
                            }
                            .padding(.leading, 23)
                        }
                        .padding(.leading, 9)
                        .padding(.bottom, -8)
                        .tint(.theme.text)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 22) {
                                books(exploreViewModel.books)
                            }
                            .frame(height: 170)
                            .padding([.leading, .trailing], 30)
                            .foregroundStyle(.black)
                        }
                    }
                    .padding(.top, 12)
                }
                .onAppear {
                    userBooksViewModel.fetchUserBooks()
                    exploreViewModel.fetchBooks()
                }
            }
            .tint(.theme.secondary)
            .background(Color.theme.background)
            .ignoresSafeArea()
        }
    }
    
    private func books(_ books: [UserBook]) -> some View {
        ForEach(userBooksViewModel.books) { book in
            VStack {
                if let imageUrl = book.image_urls.first, let url = URL(
                    string: imageUrl
                ) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 125, height: 155)
                    .clipped()
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
                } else {
                    Color.gray
                        .frame(width: 125, height: 155)
                        .cornerRadius(8)
                        .overlay(
                            Text("No Image")
                                .foregroundColor(.white)
                        )
                }
            }
        }
    }
}

#Preview {
    @Previewable
    @State var selectedTab: Tabs = .home
    
    HomeView(viewModel: GenerateStoryViewModel.init(), exploreViewModel: .init(), profileViewModel: .init(), authenticationViewModel: .init(), selectGenerate: .constant(false), selectedTab: $selectedTab, showMenu: .constant(false), showSignInView: .constant(false))
}
