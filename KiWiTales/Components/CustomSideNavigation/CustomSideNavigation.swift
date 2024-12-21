//
//  CustomSideNavigation.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/7/24.
//

import SwiftUI
import FirebaseAuth

struct CustomSideNavigation: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @Binding var selectedTab: Tabs
    @Binding var showMenu: Bool
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack {
            if showMenu {
                Rectangle()
                    .opacity(0.05)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.5)) {
                            showMenu = false
                        }
                    }
                
                HStack {
                    VStack(alignment: .leading, spacing: 32) {
                        ZStack(alignment: .topTrailing) {
                            CustomSideNavigationHeader(profileViewModel: profileViewModel)
                                .padding(.top, 100)
                                .padding(.bottom, 40)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Button {
                                withAnimation(.easeIn(duration: 0.5)) {
                                    showMenu = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color(hex: "5E5E5E"))
                                    .frame(width: 32, height: 32)
                            }
                            .padding(.top, 50)
                            .padding(.trailing, 10)
                        }
                        
                        VStack {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(Tabs.allCases) { option in
                                    VStack(spacing: 0) {
                                        Button {
                                            selectedTab = option
                                            showMenu = false
                                        } label: {
                                            CustomSideNavigationRow(option: option)
                                        }
                                        
                                        if option != Tabs.allCases.last {
                                            Divider()
                                                .background(Color.gray.opacity(0.2))
                                                .padding(.horizontal, 24)
                                                .padding(.vertical, 10)
                                        }
                                    }
                                }
                            }
                            .foregroundStyle(Color.theme.text)
                            .padding(.top, 60)
                            
                            Spacer()
                            
                            if Auth.auth().currentUser == nil {
                                Button(action: {
                                    Task {
                                        do {
                                            showMenu = false
                                            try await viewModel.signInGoogle(profileViewModel: profileViewModel)
                                            print("User signed in and profile loaded")
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                }) {
                                    Text("Login")
                                        .nunito(.bold, 18)
                                        .padding()
                                }
                                .padding(.bottom, 40)
                            } else {
                                Button(action: {
                                    Task {
                                        do {
                                            showMenu = false
                                            try AuthenticationManager.shared.signOut()
                                            
                                            profileViewModel.resetUser()
                                            print("User signed out and profile reset")
                                        } catch {
                                            print("Error signing out: \(error)")
                                        }
                                    }
                                }) {
                                    Text("Sign out")
                                        .nunito(.bold,18)
                                        .padding()
                                }
                                .padding(.bottom, 40)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "FFFCF6") ?? .white)
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal, -16)
                        .padding(.bottom, -16)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(width: 250, alignment: .leading)
                    .background(Color(hex: "DAECED"))
                    .ignoresSafeArea()
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .transition(.move(edge: .leading))
        .animation(.easeInOut(duration: 0.5), value: showMenu)
    }
    
    @ViewBuilder
    var exitButton: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                showMenu = false
            } label: {
                Image(systemName: "xmark")
                    .font(.title3.weight(.black))
                    .padding(12)
            }
            .foregroundStyle(Color(hex: "5E5E5E", opacity: 1.0) ?? Color.gray)
            .padding(24)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}

#Preview {
    @Previewable
    @State var selectedTab: Tabs = .dashboard
    
    CustomSideNavigation(viewModel: .init(), profileViewModel: .init(), selectedTab: $selectedTab, showMenu: .constant(true), showSignInView: .constant(false))
}

