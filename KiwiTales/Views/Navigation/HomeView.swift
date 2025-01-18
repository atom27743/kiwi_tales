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
    
    private var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .leading) {
                    // MARK: - CustomNavigationBar
                    CustomNavigationBarHome(selectedTab: $selectedTab, showMenu: $showMenu)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: isIPad ? 40 : 20) {
                            // MARK: - Banner Section
                            ZStack(alignment: .topLeading) {
                                Image("home_banner")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width)
                                    .frame(height: isIPad ? 250 : 200)
                                
                                VStack(alignment: .leading, spacing: isIPad ? 0 : -8) {
                                    Text("Write your own")
                                        .nunito(.semiBold, isIPad ? 36 : 26)
                                        .foregroundStyle(Color.white)
                                    Text("Fairytale")
                                        .nunito(.extraBold, isIPad ? 36 : 26)
                                        .foregroundStyle(Color.white)
                                }
                                .padding([.top, .leading], isIPad ? 48 : 32)
                                
                                ZStack(alignment: .bottom) {
                                    Button {
                                        selectGenerate = true
                                    } label: {
                                        Text("Start")
                                            .nunito(.extraBold, isIPad ? 22 : 18)
                                            .frame(width: isIPad ? 160 : 130, height: isIPad ? 48 : 40)
                                            .padding(6)
                                            .background(Color.theme.accent)
                                            .clipShape(RoundedRectangle(cornerRadius: 24))
                                    }
                                    .foregroundStyle(Color.white)
                                    .shadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                .padding(.bottom, isIPad ? 36 : 24)
                            }
                            .padding(.bottom, isIPad ? 20 : 20)
                            
                            // MARK: - My Books Section
                            VStack(alignment: .leading, spacing: isIPad ? 20 : 8) {
                                Button {
                                    selectedTab = .dashboard
                                } label: {
                                    HStack(spacing: 8) {
                                        Text("My Books")
                                            .nunito(.extraBold, isIPad ? 24 : 16)
                                        Image("family_star")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: isIPad ? 32 : 22, height: isIPad ? 32 : 22)
                                    }
                                    .padding(.leading, isIPad ? 40 : 23)
                                }
                                .tint(.theme.text)
                                .padding(.top, isIPad ? 112 : 0)
                                
                                if profileViewModel.user != nil {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: isIPad ? 24 : 22) {
                                            userBooks(userBooksViewModel.books)
                                        }
                                        .frame(height: isIPad ? 200 : 170)
                                        .padding(.horizontal, isIPad ? 40 : 30)
                                        .foregroundStyle(.black)
                                    }
                                } else {
                                    Text("Sign in to view your stories")
                                        .nunito(.regular, isIPad ? 20 : 16)
                                        .frame(height: isIPad ? 200 : 170)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                            
                            // MARK: - Explore Section
                            VStack(alignment: .leading, spacing: isIPad ? 20 : 8) {
                                Button {
                                    selectedTab = .explore
                                } label: {
                                    HStack(spacing: 8) {
                                        Text("Explore")
                                            .nunito(.extraBold, isIPad ? 24 : 16)
                                        Image("family_star")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: isIPad ? 32 : 22, height: isIPad ? 32 : 22)
                                    }
                                    .padding(.leading, isIPad ? 40 : 23)
                                }
                                .tint(.theme.text)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: isIPad ? 24 : 22) {
                                        exploreBooks(exploreViewModel.books)
                                    }
                                    .frame(height: isIPad ? 200 : 170)
                                    .padding(.horizontal, isIPad ? 40 : 30)
                                }
                            }
                        }
                        .padding(.bottom, isIPad ? 40 : 20)
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
    }
    
    private func userBooks(_ books: [UserBook]) -> some View {
        ForEach(userBooksViewModel.books) { book in
            VStack {
                if let imageUrl = book.image_urls.first, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: isIPad ? 150 : 125, height: isIPad ? 180 : 155)
                    .clipped()
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                } else {
                    Color.gray
                        .frame(width: isIPad ? 150 : 125, height: isIPad ? 180 : 155)
                        .cornerRadius(12)
                        .overlay(
                            Text("No Image")
                                .nunito(.regular, isIPad ? 18 : 14)
                                .foregroundColor(.white)
                        )
                }
            }
        }
    }
    
    private func exploreBooks(_ books: [UserBook]) -> some View {
        ForEach(exploreViewModel.books.prefix(5)) { book in
            VStack {
                if let imageUrl = book.image_urls.first, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: isIPad ? 150 : 125, height: isIPad ? 180 : 155)
                    .clipped()
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                } else {
                    Color.gray
                        .frame(width: isIPad ? 150 : 125, height: isIPad ? 180 : 155)
                        .cornerRadius(12)
                        .overlay(
                            Text("No Image")
                                .nunito(.regular, isIPad ? 18 : 14)
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
