//
//  SettingsView.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 12/22/24.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel = SettingsViewModel()
    @StateObject private var parentalGateVM = ParentalGateViewModel.shared
    @Environment(\.dismiss) private var dismiss
    @Binding var showSignInView: Bool
    let user: AuthDataResultModel
    
    var body: some View {
        List {
            // Debug section to show current auth state
            Section {
                if let user = viewModel.authUser {
                    Text("User Type: \(user.isAnonymous ? "Anonymous" : "Signed In")")
                } else {
                    Text("No user detected")
                }
            } header: {
                Text("Debug Info")
            }
            
            if let user = viewModel.authUser, !user.isAnonymous {
                Button {
                    Task {
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Sign Out")
                }
                
                Button(role: .destructive) {
                    parentalGateVM.requireParentalGate {
                        Task {
                            do {
                                try await viewModel.deleteAccount()
                                showSignInView = true
                            } catch {
                                print(error)
                            }
                        }
                    }
                } label: {
                    Text("Delete Account")
                }
            }
            
//            if viewModel.authProviders.contains(.email) {
//                emailSection
//            }
            
            // Anonymous user section
            if let user = viewModel.authUser {
                if user.isAnonymous {
                    Section {
                        Button {
                            parentalGateVM.requireParentalGate {
                                Task {
                                    do {
                                        try await viewModel.linkToEmail()
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        } label: {
                            Text("Link to Email")
                        }
                        
                        Button {
                            parentalGateVM.requireParentalGate {
                                Task {
                                    do {
                                        try await viewModel.linkToGoogle()
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        } label: {
                            Text("Link to Google")
                        }
                        
                        Button {
                            parentalGateVM.requireParentalGate {
                                Task {
                                    do {
                                        try await viewModel.linkToApple()
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        } label: {
                            Text("Link to Apple")
                        }
                    } header: {
                        Text("Sign in Options")
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $parentalGateVM.showParentalGate) {
            ParentalGateView(onSuccess: {
                parentalGateVM.parentalGateSucceeded()
            })
        }
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            Button {
                Task {
                    do {
                        try await viewModel.resetPassword()
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Reset Password")
            }
            
            Button {
                Task {
                    do {
                        try await viewModel.updateEmail()
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Update Email")
            }
            
            Button {
                Task {
                    do {
                        try await viewModel.updatePassword()
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Update Password")
            }
        } header: {
            Text("Email Functions")
        }
    }
}
