//
//  AuthenticationViewModel.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 12/22/24.
//


import Foundation
import FirebaseAuth

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var providers: [AuthProviderOption] = []
    
    init() {
        updateProviders()
    }
    
    func updateProviders() {
        do {
            providers = try AuthenticationManager.shared.getProviders()
        } catch {
            handleError(error)
        }
    }
    
    func signInGoogle() async throws {
        let manager = SignInGoogleManager()
        let tokens = try await manager.signIn()
        
        if let currentUser = Auth.auth().currentUser {
            if currentUser.isAnonymous {
                _ = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
            } else {
                // Link Google to existing SSO account
                _ = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
            }
        } else {
            try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        }
        updateProviders()
    }
    
    func signInApple() async throws {
        let manager = SignInAppleManager()
        let tokens = try await manager.startSignInWithAppleFlow()
        try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
    }
    
    func signInAnonymously() async throws {
        try await AuthenticationManager.shared.signInAnonymous()
        updateProviders()
    }
    
    func signOut() async throws {
        try await AuthenticationManager.shared.signOut()
        updateProviders()
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.delete()
        updateProviders()
    }
    
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
    
    func isProviderLinked(_ provider: AuthProviderOption) -> Bool {
        providers.contains(provider)
    }
}
