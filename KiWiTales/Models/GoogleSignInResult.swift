//
//  GoogleSignInResult.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//

import Foundation

struct GoogleSignInResult {
    let name: String?
    let email: String?
    let image: URL?
    let idToken: String
    let accessToken: String
}
