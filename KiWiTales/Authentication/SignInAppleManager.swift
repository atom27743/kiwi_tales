//
//  SignInWithAppleResult.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 12/22/24.
//

import Foundation
import SwiftUI
import CryptoKit
import AuthenticationServices

struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    let authorizationButtonType: ASAuthorizationAppleIDButton.ButtonType
    let authorizationButtonStyle: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton(
            authorizationButtonType: authorizationButtonType,
            authorizationButtonStyle: authorizationButtonStyle)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) { }
}

@MainActor
final class SignInAppleManager: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var currentNonce: String?
    private var completionHandler: ((Result<SignInWithAppleResult, Error>) -> Void)? = nil
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
    
    func startSignInWithAppleFlow() async throws -> SignInWithAppleResult {
        try await withCheckedThrowingContinuation { continuation in
            self.startSignInWithAppleFlow { result in
                switch result {
                case .success(let signInAppleResult):
                    continuation.resume(returning: signInAppleResult)
                    return
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func startSignInWithAppleFlow(completion: @escaping (Result<SignInWithAppleResult, Error>) -> Void) {
        print("1. Starting Sign In With Apple Flow")
        
        let nonce = randomNonceString()
        currentNonce = nonce
        print("3. Generated nonce")
        
        completionHandler = completion
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        print("4. Created Apple ID request")

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        print("5. Set up authorization controller")
        authorizationController.performRequests()
        print("6. Performed requests")
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("7. Authorization completed")
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("Error: Failed to get Apple ID Credential")
            completionHandler?(.failure(URLError(.badServerResponse)))
            return
        }
        print("8. Got Apple ID Credential")
        print("Available data from Apple:")
        print("- User ID: \(appleIDCredential.user)")
        print("- Full Name: \(String(describing: appleIDCredential.fullName))")
        print("- Email: \(String(describing: appleIDCredential.email))")
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Error: Failed to get identity token")
            completionHandler?(.failure(URLError(.badServerResponse)))
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Error: Failed to decode identity token")
            completionHandler?(.failure(URLError(.badServerResponse)))
            return
        }
        
        guard let currentNonce = currentNonce else {
            print("Error: Invalid state - nonce is missing")
            completionHandler?(.failure(URLError(.badServerResponse)))
            return
        }
        
        let name: String? = {
            if let fullName = appleIDCredential.fullName {
                return fullName.givenName
            }
            return nil
        }()
        
        let email = appleIDCredential.email
        
        let tokens = SignInWithAppleResult(
            idToken: idTokenString,
            rawNonce: currentNonce,
            name: name,
            email: email
        )
        
        // Dispatch to main queue to ensure UI updates happen on the main thread
        DispatchQueue.main.async {
            self.completionHandler?(.success(tokens))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization failed with error: \(error)")
        print("Error domain: \((error as NSError).domain)")
        print("Error code: \((error as NSError).code)")
        print("Error description: \(error.localizedDescription)")
        if let nsError = error as NSError? {
            for (key, value) in nsError.userInfo {
                print("UserInfo - \(key): \(value)")
            }
        }
        completionHandler?(.failure(error))
    }
}
