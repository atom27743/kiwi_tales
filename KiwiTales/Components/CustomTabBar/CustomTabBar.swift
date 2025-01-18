//
//  CustomTabBar.swift
//  KiWi
//
//  Created by Takumi Otsuka on 8/10/24.
//

import SwiftUI

enum Tabs: Int, CaseIterable {
    case home = 0
    case dashboard = 1
    case explore = 2
//    case settings = 3
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .dashboard:
            return "My Books"
        case .explore:
            return "Explore"
//        case .settings:
//            return "Settings"
        }
    }
    
    var imageName: String {
        switch self {
        case .home:
            return "family_home"
        case .dashboard:
            return "family_star"
        case .explore:
            return "explore"
//        case .settings:
//            return "settings"
        }
    }
}

extension Tabs: Identifiable {
    var id: Int { return self.rawValue }
}

struct CustomTabBar: View {
    @StateObject var viewModel: GenerateStoryViewModel = .init()
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @Binding var selectGenerate: Bool
    @Binding var selectedTab: Tabs
    @Binding var showSignInView: Bool
    
    @State private var isPressed = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Main Tab Bar
                HStack(alignment: .center, spacing: 0) {
                    Button {
                        selectedTab = .dashboard
                    } label: {
                        CustomTabBarButton(buttonText: "Dashboard", imageName: "family_star", isActive: selectedTab == .dashboard)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Middle generate button with circle background
                    ZStack {
                        Circle()
                            .fill(.white)
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "8ABABD") ?? .white, lineWidth: 5)
                            )
                            .frame(width: 100, height: 100)
                            .offset(y: -25)
                        
                        Button {
                            isPressed = true
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isPressed = false
                            }
                            selectGenerate = true
                        } label: {
                            Image("design_services")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .foregroundColor(Color.accentColor)
                                .scaleEffect(isPressed ? 0.8 : 1.0)
                        }
                        .offset(y: -25)
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(width: 70)
                    
                    Button {
                        selectedTab = .explore
                    } label: {
                        CustomTabBarButton(buttonText: "Explore", imageName: "explore", isActive: selectedTab == .explore)
                    }
                    .frame(maxWidth: .infinity)
                }
                .tint(Color.theme.secondary)
                .frame(height: geometry.size.height)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, geometry.size.width * 0.02)
                .background(
                    ZStack {
                        // Custom background with kiwi
                        RoundedRectangle(cornerRadius: 40.0)
                            .fill(Color.white)
                        
                        // Border
                        RoundedRectangle(cornerRadius: 40.0)
                            .strokeBorder(Color(hex: "8ABABD") ?? .white, lineWidth: 5)
                        
                        // Kiwi mascot in background
                        Image("kiwi")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.4)
                            .opacity(selectedTab == .home ? 1 : 0)
                            .shadow(color: .black.opacity(0.2), radius: 4)
                            .offset(x: geometry.size.width * 0.24, y: -geometry.size.height * 0.5)
                            .scaleEffect(1.3)
                            .zIndex(-1)
                    }
                )
                .zIndex(1)
                .fullScreenCover(isPresented: $selectGenerate) {
                    GenerateStoryView(authenticationViewModel: authenticationViewModel,
                                    generateStoryViewModel: viewModel,
                                    profileViewModel: profileViewModel,
                                    showSignInView: $showSignInView,
                                    selectGenerate: $selectGenerate)
                }
            }
        }
        .frame(height: 106)
    }
}
