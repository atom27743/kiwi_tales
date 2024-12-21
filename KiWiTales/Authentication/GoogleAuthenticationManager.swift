//
//  GoogleAuthenticationManager.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//

//signing in and saving user data

import Foundation
import GoogleSignIn
import GoogleSignInSwift

final class GoogleAuthenticationManager {
    @MainActor
    func signIn() async throws -> GoogleSignInResult {
        guard let rootVC = Utilities.shared.rootViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        let name = gidSignInResult.user.profile?.givenName
        let email = gidSignInResult.user.profile?.email
        let image = gidSignInResult.user.profile?.imageURL(withDimension: 100)
        
        let tokens = GoogleSignInResult(name: name, email: email, image: image, idToken: idToken, accessToken: accessToken)
        
        return tokens
    }
}

//storing the user's info to profileVM
//"sign in google button function"

@MainActor
final class AuthenticationViewModel: ObservableObject {
    func signInGoogle(profileViewModel: ProfileViewModel) async throws {
        let googleManager = GoogleAuthenticationManager()
        let tokens = try await googleManager.signIn()
        
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult, name: tokens.name)
        try await UserManager.shared.createNewUser(user: user)
        
        try await profileViewModel.loadCurrentUser()
        print("Profile loaded after login: \(String(describing: profileViewModel.user?.name))")
    }
}
