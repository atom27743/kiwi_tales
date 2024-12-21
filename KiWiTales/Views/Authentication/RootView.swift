//
//  RootView.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @StateObject var exploreViewModel: ExploreViewModel = .init()
    
    @State var currentIndex: Int = 0
    @State var selectedTab: Tabs = .home
    
    @State private var selectGenerate = false
    @State private var showMenu: Bool = false
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack {
            if selectedTab == .home {
                HomeView(exploreViewModel: exploreViewModel, profileViewModel: profileViewModel, authenticationViewModel: viewModel, selectGenerate: $selectGenerate, selectedTab: $selectedTab, showMenu: $showMenu, showSignInView: $showSignInView)
            }

            if selectedTab == .dashboard {
                DashboardView(selectedTab: $selectedTab, showMenu: $showMenu)
            }

            if selectedTab == .explore {
                ExploreView(profileViewModel: profileViewModel, exploreViewModel: exploreViewModel, showSignInView: $showSignInView, selectedTab: $selectedTab, showMenu: $showMenu)
            }

            VStack {
                Spacer()
                CustomTabBar(authenticationViewModel: viewModel, profileViewModel: profileViewModel, selectGenerate: $selectGenerate, selectedTab: $selectedTab, showSignInView: $showSignInView)
                    .offset(y: 4)
            }
            .edgesIgnoringSafeArea(.bottom)
            
            if showMenu {
                CustomSideNavigation(viewModel: viewModel, profileViewModel: profileViewModel, selectedTab: $selectedTab, showMenu: $showMenu, showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    RootView(viewModel: AuthenticationViewModel.init(), profileViewModel: .init(), showSignInView: .constant(false))
}
