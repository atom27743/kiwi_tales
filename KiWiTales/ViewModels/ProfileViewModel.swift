//
//  BookUserViewModel.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//



import Foundation
import FirebaseAuth

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    
    var displayName: String? {
        return user?.name
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // Explicitly update on the main thread
        await MainActor.run {
            self.user = nil // Clear previous user
        }
        
        let fetchedUser = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
        // Ensure UI update happens on main thread
        await MainActor.run {
            if fetchedUser == nil {
                print("No user found in Firestore, creating new user...")
                let newUser = DBUser(auth: authDataResult)
                Task {
                    do {
                        try await UserManager.shared.createNewUser(user: newUser)
                        self.user = newUser
                    } catch {
                        print("Error creating new user: \(error)")
                    }
                }
            } else {
                self.user = fetchedUser
                
                if fetchedUser?.email == nil || fetchedUser?.name == nil {
                    print("User profile is incomplete. Consider adding more details.")
                }
            }
            
            print("Loaded user: \(self.user?.name ?? "No display name")")
        }
    }

    
    func resetUser() {
        DispatchQueue.main.async {
            self.user = nil
        }
    }
}
