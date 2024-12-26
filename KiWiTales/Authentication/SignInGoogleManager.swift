//
//  GoogleSignInResultModel.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 12/22/24.
//


import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel {
    let name: String?
    let email: String?
    let imageURL: String?
    let withIDToken: String
    let accessToken: String
}

final class SignInGoogleManager {
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let withIDToken: String = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        let name = gidSignInResult.user.profile?.name
        let email = gidSignInResult.user.profile?.email
        let imageURL = gidSignInResult.user.profile?.imageURL(withDimension: 100)
        
        let tokens = GoogleSignInResultModel(
            name: name, email: email, imageURL: imageURL?.absoluteString, withIDToken: withIDToken, accessToken: accessToken)
        
        return tokens
    }
}
