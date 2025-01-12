//
//  AuthDataResultModel.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 12/22/24.
//

import Foundation
import FirebaseAuth

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
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() { }
    
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
        // First sign out from Firebase
        try Auth.auth().signOut()
        
        // Clear all authentication related UserDefaults
        UserDefaults.standard.removeObject(forKey: "wasSignedInWithSSO")
        UserDefaults.standard.synchronize()
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
        print("Starting Apple Sign In with Firebase...")
        let credential = OAuthProvider.credential(
            withProviderID: AuthProviderOption.apple.rawValue,
            idToken: tokens.idToken,
            rawNonce: tokens.rawNonce
        )
        
        print("Created OAuth credential")
        let authDataResult = try await Auth.auth().signIn(with: credential)
        let authModel = AuthDataResultModel(user: authDataResult.user)
        print("Successfully signed in with Firebase. User ID: \(authModel.uid)")
        
        do {
            print("Checking for existing user in Firestore...")
            let existingUser = try await UserManager.shared.getUser(userId: authModel.uid)
            
            if existingUser == nil {
                print("Creating new user in Firestore...")
                // Create new user with Apple credentials
                let newUser = DBUser(
                    userId: authModel.uid,
                    email: tokens.email,
                    photoURL: nil,  // Apple doesn't provide photo URL
                    name: tokens.name,
                    dateCreated: Date()
                )
                try await UserManager.shared.createNewUser(user: newUser)
                print("Successfully created new user in Firestore with email: \(tokens.email ?? "nil") and name: \(tokens.name ?? "nil")")
            } else {
                print("Existing user found. Using stored user data.")
            }
        } catch {
            print("Error handling Firestore user: \(error)")
            throw error
        }
        
        UserDefaults.standard.set(true, forKey: "wasSignedInWithSSO")
        return authModel
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
                    _ = Auth.auth().currentUser?.uid
                    
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
