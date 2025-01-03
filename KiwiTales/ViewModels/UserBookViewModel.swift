//
//  UserBookViewModel.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 9/19/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserBookViewModel: ObservableObject {
    @Published var books: [UserBook] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    private var fetchSpecificUser: Bool
    private var specificUserID: String?

    init(fetchSpecificUser: Bool = false, specificUserID: String? = nil) {
        self.fetchSpecificUser = fetchSpecificUser
//        self.specificUserID = Tokens.atom
        self.specificUserID = "QPjGy24vi1fns0OeMC79TweO1Oh2"
        setupAuthStateListener()
    }

    deinit {
        listener?.remove()
        if let authStateListener = authStateListener {
            Auth.auth().removeStateDidChangeListener(authStateListener)
        }
    }

    private func setupAuthStateListener() {
        if fetchSpecificUser {
            fetchUserBooks()
        } else {
            authStateListener = Auth
                .auth()
                .addStateDidChangeListener { [weak self] auth, user in
                    if let user = user {
                        self?.fetchUserBooks()
                    } else {
                        self?.books = []
                        self?.listener?.remove()
                        self?.listener = nil
                    }
                }
        }
    }

    func fetchUserBooks() {
        listener?.remove()

        var query: Query = db.collection("books")

        if fetchSpecificUser, let specificUserID = specificUserID {
            query = query.whereField("user_id", isEqualTo: specificUserID)
        } else if let userID = Auth.auth().currentUser?.uid {
            query = query.whereField("user_id", isEqualTo: userID)
        } else {
            print("No user is currently logged in")
            return
        }

        query = query.order(by: "date_created", descending: true)
            .limit(to: 5)

        listener = query.addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user books: \(error.localizedDescription)")
            } else {
                if let snapshot = snapshot {
                    // Clear cache when books are updated
                    self?.clearCacheForUpdatedBooks(snapshot: snapshot)
                    self?.books = snapshot.documents.compactMap { document in
                        try? document.data(as: UserBook.self)
                    }
                }
            }
        }
    }
    
    private func clearCacheForUpdatedBooks(snapshot: QuerySnapshot) {
        let updatedBookIDs = snapshot.documents.map { $0.documentID }
        
        // Iterate through the existing books and clear the cache for removed books
        books.forEach { book in
            if !updatedBookIDs.contains(book.id ?? ""), let imageUrl = book.image_urls.first {
                ImageCache.shared.removeImage(forKey: imageUrl)
            }
        }
    }
}
