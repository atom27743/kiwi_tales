//
//  AuthenticationView.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 12/22/24.
//

import SwiftUI

struct AuthenticationView: View {
    @Binding var showSignInView: Bool
    
    var body: some View {
        SignInMethodsView(showSignInView: $showSignInView)
            .presentationBackground(Color.theme.background)
    }
}
