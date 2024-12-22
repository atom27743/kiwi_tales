//
//  SettingsViewModel.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 12/22/24.
//


import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var authProviders = Array<AuthProviderOption>()
    @Published var authUser: AuthDataResultModel? = nil
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "kiwi@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "kiwiGoogle"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func linkToEmail() async throws {
        let withEmail = "kiwi@gmail.com"
        let password = "kiwiGoogle"
        self.authUser = try await AuthenticationManager.shared.linkEmail(withEmail: withEmail, password: password)
    }
    
    func linkToGoogle() async throws {
        let manager = SignInGoogleManager()
        let tokens = try await manager.signIn()
        
        self.authUser = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
    }
    
    func linkToApple() async throws {
        let manager = SignInAppleManager()
        let tokens = try await manager.startSignInWithAppleFlow()
        
        self.authUser = try await AuthenticationManager.shared.linkApple(tokens: tokens)
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.delete()
    }
}