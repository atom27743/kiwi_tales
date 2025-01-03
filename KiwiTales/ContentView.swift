//
//  ContentView.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/5/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import FirebaseStorage

struct FirebaseImageView: View {
    let imagePath: String
    @State private var image: UIImage? = nil
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        let storageRef = Storage.storage().reference().child(imagePath)

        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                errorMessage = "Failed to load image."
                isLoading = false
                return
            }

            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = uiImage
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid image data."
                    self.isLoading = false
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject var authenticationViewModel = AuthenticationViewModel()
    @StateObject var profileViewModel = ProfileViewModel()
    
    @State var showSignInView: Bool = false
    
    var body: some View {
        RootView(
            viewModel: authenticationViewModel,
            profileViewModel: profileViewModel,
            showSignInView: $showSignInView
        )
        .onAppear(perform: checkAuthenticatedUser)
//        FirebaseImageView(imagePath: "books/82703066-EE57-44C8-84EC-E20BE70497C0/images/7.jpg")
//            .frame(width: 200, height: 200)
//            .clipped()
    }
    
    private func checkAuthenticatedUser() {
        if Auth.auth().currentUser != nil {
            Task {
                do {
                    try await profileViewModel.loadCurrentUser()
                    showSignInView = false
                } catch {
                    showSignInView = true
                }
            }
        } else {
            showSignInView = true
        }
    }
}

#Preview {
    ContentView()
}
