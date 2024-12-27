//
//  UserManager.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/13/24.
//

//User Data Storage code
import Foundation
import FirebaseFirestore

struct DBUser: Codable, Equatable {
    let userId: String
    let email: String?
    let photoURL: String?
    let name: String?
    let dateCreated: Date?
    var isFirstTimeUser: Bool? // This is not encoded/decoded by default

    init(auth: AuthDataResultModel, name: String? = nil, isFirstTimeUser: Bool? = true) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoURL = auth.photoURL
        self.name = name
        self.dateCreated = Date()
        self.isFirstTimeUser = isFirstTimeUser
    }

    init(userId: String, email: String?, photoURL: String?, name: String?, dateCreated: Date?, isFirstTimeUser: Bool? = true) {
        self.userId = userId
        self.email = email
        self.photoURL = photoURL
        self.name = name
        self.dateCreated = dateCreated
        self.isFirstTimeUser = isFirstTimeUser
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case photoURL = "photo_url"
        case name = "name"
        case dateCreated = "date_created"
        case isFirstTimeUser = "is_first_time_user" // Explicitly define it for Codable
    }

    // Custom Decoder to handle Date and Bool properties
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isFirstTimeUser = try container.decodeIfPresent(Bool.self, forKey: .isFirstTimeUser)
    }

    // Custom Encoder to handle Date and Bool properties
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(photoURL, forKey: .photoURL)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(isFirstTimeUser, forKey: .isFirstTimeUser)
    }

    // Implement Equatable
    static func == (lhs: DBUser, rhs: DBUser) -> Bool {
        return lhs.userId == rhs.userId &&
               lhs.email == rhs.email &&
               lhs.photoURL == rhs.photoURL &&
               lhs.name == rhs.name
    }
}



//struct DBUser: Codable {
//    let userId: String
//    let email: String?
//    let photoUrl: String?
//    let dateCreated: Date?
//    let name: String?
//    
//    init(auth: AuthDataResultModel, name: String?) {
//        self.userId = auth.uid
//        self.email = auth.email
//        self.photoUrl = auth.photoURL
//        self.dateCreated = Date()
//        self.name = name
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case userId = "user_id"
//        case email = "email"
//        case photoUrl = "photo_url"
//        case dateCreated = "date_created"
//        case name = "name"
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.userId = try container.decode(String.self, forKey: .userId)
//        self.email = try container.decodeIfPresent(String.self, forKey: .email)
//        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
//        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
//        self.name = try container.decodeIfPresent(String.self, forKey: .name)
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.userId, forKey: .userId)
//        try container.encodeIfPresent(self.email, forKey: .email)
//        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
//        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
//        try container.encodeIfPresent(self.name, forKey: .name)
//    }
//}


final class UserManager {
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    func createNewUser(user: DBUser) async throws {
        // Prevent saving anonymous users
        guard !user.userId.isEmpty, 
              let email = user.email, 
              !email.isEmpty else {
            print("Skipping Firestore user creation for anonymous or incomplete user")
            return
        }
        
        print("Attempting to create user document in Firestore...")
        let data: [String: Any] = [
            DBUser.CodingKeys.userId.rawValue: user.userId,
            DBUser.CodingKeys.email.rawValue: user.email as Any,
            DBUser.CodingKeys.photoURL.rawValue: user.photoURL as Any,
            DBUser.CodingKeys.name.rawValue: user.name as Any,
            DBUser.CodingKeys.dateCreated.rawValue: user.dateCreated as Any
        ]
        
        do {
            try await userDocument(userId: user.userId).setData(data, merge: false)
            print("Successfully created user document in Firestore")
        } catch {
            print("Error creating user in Firestore: \(error)")
            throw error
        }
    }
    
    func getUser(userId: String) async throws -> DBUser? {
        let snapshot = try await userDocument(userId: userId).getDocument()
        
        guard let data = snapshot.data(), !data.isEmpty else {
            return nil
        }
        
        let userId = data[DBUser.CodingKeys.userId.rawValue] as? String ?? ""
        let email = data[DBUser.CodingKeys.email.rawValue] as? String
        let photoURL = data[DBUser.CodingKeys.photoURL.rawValue] as? String
        let name = data[DBUser.CodingKeys.name.rawValue] as? String
        let dateCreated = (data[DBUser.CodingKeys.dateCreated.rawValue] as? Timestamp)?.dateValue()
        
        return DBUser(userId: userId,
                     email: email,
                     photoURL: photoURL,
                     name: name,
                     dateCreated: dateCreated)
    }
    
    func updateUserProfileURL(userId: String, photoURL: String) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.photoURL.rawValue : photoURL
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateDisplayName(userId: String, displayName: String) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.name.rawValue : displayName
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateUser(user: DBUser) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.userId.rawValue: user.userId,
            DBUser.CodingKeys.email.rawValue: user.email as Any,
            DBUser.CodingKeys.photoURL.rawValue: user.photoURL as Any,
            DBUser.CodingKeys.name.rawValue: user.name as Any,
            DBUser.CodingKeys.dateCreated.rawValue: user.dateCreated as Any
        ]

        
        try await userDocument(userId: user.userId).setData(data, merge: true)
    }
}


//final class UserManager {
//    static let shared = UserManager()
//    private init() { }
//    
//    private let userCollection = Firestore.firestore().collection("users")
//    
//    private func userDocument(userID: String) -> DocumentReference {
//        userCollection.document(userID)
//    }
//    
//    func createNewUser(user: DBUser) async throws {
//        try userDocument(userID: user.userId).setData(from: user, merge: false)
//    }
//    
//    func getUser(userID: String) async throws -> DBUser {
//        let documentSnapshot = try await userDocument(userID: userID).getDocument()
//        
//        guard documentSnapshot.exists else {
//            throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "User document does not exist."])
//        }
//        
//        do {
//            return try documentSnapshot.data(as: DBUser.self)
//        } catch {
//            throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user data."])
//        }
//    }
//}
