//
//  AuthDataResultModel.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 12/22/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoURL: String?
    let isAnonymous: Bool
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
}

enum AuthProviderOption: String {
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private init() {
        // Firebase Auth persistence is enabled by default
        // and will maintain the same anonymous user across app restarts
        do {
            try Auth.auth().useUserAccessGroup(nil)
            
        } catch {
            print("Error setting up Firebase user access group: \(error)")
        }
    }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
    
    func getProviders() throws -> Array<AuthProviderOption> {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: Array<AuthProviderOption> = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        
        return providers
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        UserDefaults.standard.set(false, forKey: "wasSignedInWithSSO")
    }
    
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        try await user.delete()
        UserDefaults.standard.set(false, forKey: "wasSignedInWithSSO")
    }
}

// MARK: Sign-In EMAIL
extension AuthenticationManager {
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
}

// MARK: Sign-In SSO
extension AuthenticationManager {
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.withIDToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.idToken, rawNonce: tokens.rawNonce)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}

// MARK: Sign-In Anonymous
extension AuthenticationManager {
    @discardableResult
    func signInAnonymous() async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    private func handleExistingAccountError(_ error: Error) async throws -> AuthDataResultModel {
        let nsError = error as NSError
        // Check if the error is about existing account
        if nsError.domain == AuthErrorDomain {
            if nsError.code == AuthErrorCode.credentialAlreadyInUse.rawValue ||
               nsError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                
                // If we have a credential from the error, use it to sign in
                if let credential = nsError.userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? AuthCredential {
                    // Store anonymous user ID for potential data migration
                    let anonymousUserId = Auth.auth().currentUser?.uid
                    
                    // Sign out of anonymous account
                    try await Auth.auth().currentUser?.delete()
                    
                    // Sign in with existing account
                    let authDataResult = try await Auth.auth().signIn(with: credential)
                    
                    // Here you would implement your data migration if needed
                    // await migrateData(from: anonymousUserId, to: authDataResult.user.uid)
                    
                    UserDefaults.standard.set(true, forKey: "wasSignedInWithSSO")
                    return AuthDataResultModel(user: authDataResult.user)
                }
            }
        }
        
        // If we couldn't handle the error, throw it
        throw error
    }

    func linkGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.withIDToken, accessToken: tokens.accessToken)
        do {
            return try await linkCredential(credential: credential)
        } catch {
            return try await handleExistingAccountError(error)
        }
    }
    
    func linkApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.idToken, rawNonce: tokens.rawNonce)
        do {
            return try await linkCredential(credential: credential)
        } catch {
            return try await handleExistingAccountError(error)
        }
    }
    
    func linkEmail(withEmail: String, password: String) async throws -> AuthDataResultModel {
        let credential = EmailAuthProvider.credential(withEmail: withEmail, password: password)
        do {
            return try await linkCredential(credential: credential)
        } catch {
            return try await handleExistingAccountError(error)
        }
    }
    
    private func linkCredential(credential: AuthCredential) async throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        let authDataResult = try await user.link(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
