//
//  SignInWithAppleResult.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 12/27/24.
//

import Foundation

struct SignInWithAppleResult {
    let idToken: String
    let rawNonce: String
    let name: String?
    let email: String?
}
