//
//  RootView.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @StateObject var exploreViewModel: ExploreViewModel = .init()
    
    @State var currentIndex: Int = 0
    @State var selectedTab: Tabs = .home
    
    @State private var selectGenerate = false
    @State private var showMenu: Bool = false
    @State private var isLoading = true
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
            } else {
                mainContent
            }
        }
        .onAppear {
            handleAnonymousSignIn()
        }
    }
    
    private var mainContent: some View {
        ZStack {
            if selectedTab == .home {
                HomeView(exploreViewModel: exploreViewModel, 
                        profileViewModel: profileViewModel, 
                        authenticationViewModel: viewModel, 
                        selectGenerate: $selectGenerate, 
                        selectedTab: $selectedTab, 
                        showMenu: $showMenu, 
                        showSignInView: $showSignInView)
            }

            if selectedTab == .dashboard {
                DashboardView(selectedTab: $selectedTab, showMenu: $showMenu)
            }

            if selectedTab == .explore {
                ExploreView(profileViewModel: profileViewModel, 
                          exploreViewModel: exploreViewModel, 
                          showSignInView: $showSignInView, 
                          selectedTab: $selectedTab, 
                          showMenu: $showMenu)
            }

            VStack {
                Spacer()
                CustomTabBar(authenticationViewModel: viewModel, 
                           profileViewModel: profileViewModel, 
                           selectGenerate: $selectGenerate, 
                           selectedTab: $selectedTab, 
                           showSignInView: $showSignInView)
                    .offset(y: 4)
            }
            .edgesIgnoringSafeArea(.bottom)
            
            if showMenu {
                CustomSideNavigation(viewModel: viewModel, 
                                   profileViewModel: profileViewModel, 
                                   selectedTab: $selectedTab, 
                                   showMenu: $showMenu, 
                                   showSignInView: $showSignInView)
            }
        }
    }
    
    private func handleAnonymousSignIn() {
        if Auth.auth().currentUser == nil {
            // Check if we have a stored anonymous user ID
            if let storedAnonymousId = UserDefaults.standard.string(forKey: "anonymousUserId") {
                // Try to restore the anonymous session
                Auth.auth().signIn(withCustomToken: storedAnonymousId) { [self] (_, error) in
                    if error != nil {
                        // If restoration fails, create new anonymous user
                        createNewAnonymousUser()
                    } else {
                        isLoading = false
                    }
                }
            } else {
                // No stored ID, create new anonymous user
                createNewAnonymousUser()
            }
        } else {
            isLoading = false
        }
    }
    
    private func createNewAnonymousUser() {
        Task {
            do {
                try await viewModel.signInAnonymously()
                // Store the anonymous user ID
                if let anonymousId = Auth.auth().currentUser?.uid {
                    UserDefaults.standard.set(anonymousId, forKey: "anonymousUserId")
                }
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                print("Error signing in anonymously: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    RootView(viewModel: AuthenticationViewModel.init(), 
             profileViewModel: .init(), 
             showSignInView: .constant(false))
}
