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
    @StateObject private var parentalGateVM = ParentalGateViewModel.shared
    
    @Binding var selectedTab: Tabs
    @Binding var showMenu: Bool
    @Binding var showSignInView: Bool
    @State private var showDeleteAlert = false
    @State private var showSettings = false
    @State private var showDeleteConfirmation = false
    
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
                            
                            if let user = Auth.auth().currentUser {
                                if user.isAnonymous {
                                    Button {
                                        showSignInView = true
                                    } label: {
                                        Text("Sign In")
                                            .nunito(.bold, 18)
                                            .foregroundStyle(Color.theme.accent)
                                            .frame(height: 45)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 40)
                                } else {
                                    Button {
                                        parentalGateVM.requireParentalGate {
                                            Task {
                                                do {
                                                    showMenu = false
                                                    try AuthenticationManager.shared.signOut()
                                                    try await viewModel.signInAnonymously()
                                                } catch {
                                                    print("Error: \(error)")
                                                }
                                            }
                                        }
                                    } label: {
                                        Text("Sign Out")
                                            .nunito(.bold, 18)
                                            .foregroundStyle(Color.theme.accent)
                                            .frame(height: 45)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .padding(.horizontal)
                                    
                                    Button {
                                        parentalGateVM.requireParentalGate {
                                            showDeleteConfirmation = true
                                        }
                                    } label: {
                                        Text("Delete Account")
                                            .nunito(.bold, 18)
                                            .foregroundStyle(Color.red)
                                            .frame(height: 45)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 40)
                                    .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                                        Button("Cancel", role: .cancel) { }
                                        Button("Delete", role: .destructive) {
                                            Task {
                                                do {
                                                    showMenu = false
                                                    // Delete user data from Firestore
                                                    try await UserManager.shared.deleteUser(userId: user.uid)
                                                    // Delete user authentication
                                                    try await AuthenticationManager.shared.delete()
                                                    // Sign in anonymously after deletion
                                                    try await viewModel.signInAnonymously()
                                                } catch {
                                                    print("Error deleting account: \(error)")
                                                }
                                            }
                                        }
                                    } message: {
                                        Text("Are you sure you want to delete your account? This action cannot be undone.")
                                    }
                                }
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
        .sheet(isPresented: $parentalGateVM.showParentalGate) {
            ParentalGateView(onSuccess: {
                parentalGateVM.parentalGateSucceeded()
            })
        }
        .transition(.move(edge: .leading))
        .animation(.easeInOut(duration: 0.5), value: showMenu)
        .sheet(isPresented: $showSignInView) {
            AuthenticationView(showSignInView: $showSignInView)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
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
