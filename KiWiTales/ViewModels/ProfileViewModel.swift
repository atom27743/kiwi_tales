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
        if let currentUser = Auth.auth().currentUser {
            let authDataResult = AuthDataResultModel(user: currentUser)
                
            do {
                let fetchedUser = try await UserManager.shared.getUser(userID: authDataResult.uid)
                DispatchQueue.main.async {
                    self.user = fetchedUser
                }
            } catch {
                DispatchQueue.main.async {
                    self.user = nil
                }
                print(
                    "Failed to fetch user data: \(error.localizedDescription)"
                )
            }
        } else {
            print("No current user available in Firebase")
            DispatchQueue.main.async {
                self.user = nil
            }
        }
    }
    
    func resetUser() {
        DispatchQueue.main.async {
            self.user = nil
        }
    }
}
