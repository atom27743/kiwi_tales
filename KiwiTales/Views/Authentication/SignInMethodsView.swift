//
//  SignInMethodsView.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 12/22/24.
//

import SwiftUI
import FirebaseAuth

struct SignInMethodsView: View {
    @StateObject private var viewModel: AuthenticationViewModel = AuthenticationViewModel()
    @StateObject private var parentalGateVM = ParentalGateViewModel.shared
    @Binding var showSignInView: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text(Auth.auth().currentUser?.isAnonymous == true ? 
                 "Sign in to save your stories" : 
                 "Choose a sign-in method")
                .foregroundStyle(Color.theme.text)
                .font(.headline)
                .padding(.top)
            
            if !viewModel.isProviderLinked(.google) {
                Button {
                    parentalGateVM.requireParentalGate {
                        Task {
                            do {
                                try await viewModel.signInGoogle()
                                showSignInView = false
                                UserDefaults.standard.set(true, forKey: "wasSignedInWithSSO")
                            } catch {
                                viewModel.handleError(error)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image("google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        Text(Auth.auth().currentUser?.isAnonymous == true ? 
                             "Continue with Google" :
                             viewModel.providers.isEmpty ? "Sign in with Google" :
                             "Link Google Account")
                            .font(.headline)
                    }
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
            }
            
            if !viewModel.isProviderLinked(.apple) {
                Button {
                    parentalGateVM.requireParentalGate {
                        Task {
                            do {
                                try await viewModel.signInApple()
                                showSignInView = false
                                UserDefaults.standard.set(true, forKey: "wasSignedInWithSSO")
                            } catch {
                                viewModel.handleError(error)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "apple.logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        Text(Auth.auth().currentUser?.isAnonymous == true ? 
                             "Continue with Apple" :
                             viewModel.providers.isEmpty ? "Sign in with Apple" :
                             "Link Apple Account")
                            .font(.headline)
                    }
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            if !viewModel.providers.isEmpty {
                Text("Linked Accounts:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ForEach(viewModel.providers, id: \.rawValue) { provider in
                    HStack {
                        if provider == .google {
                            Image("google")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Google Account Linked")
                        } else if provider == .apple {
                            Image(systemName: "apple.logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Apple Account Linked")
                        }
                    }
                    .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .alert("Sign In Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
        .sheet(isPresented: $parentalGateVM.showParentalGate) {
            ParentalGateView(onSuccess: {
                parentalGateVM.parentalGateSucceeded()
            })
        }
        .onAppear {
            viewModel.updateProviders()
        }
    }
}
