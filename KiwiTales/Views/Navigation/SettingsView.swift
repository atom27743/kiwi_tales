//
//  SettingsView.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 12/22/24.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
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
                    Task {
                        do {
                            try await viewModel.deleteAccount()
                            showSignInView = true
                        } catch {
                            print(error)
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
                            Task {
                                do {
                                    try await viewModel.linkToEmail()
                                } catch {
                                    print(error)
                                }
                            }
                        } label: {
                            Text("Link to Email")
                        }
                        
                        Button {
                            Task {
                                do {
                                    try await viewModel.linkToGoogle()
                                } catch {
                                    print(error)
                                }
                            }
                        } label: {
                            Text("Link to Google")
                        }
                        
                        Button {
                            Task {
                                do {
                                    try await viewModel.linkToApple()
                                } catch {
                                    print(error)
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
