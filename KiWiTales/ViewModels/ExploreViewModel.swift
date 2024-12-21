//
//  ExploreViewModel.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 9/28/24.
//

import Foundation
import FirebaseFirestore
import Combine
import SwiftUICore

class ExploreViewModel: ObservableObject {
    @Published var books: [UserBook] = []
    @Published var filteredBooks: [UserBook] = []
    @Published var selectedFilter: String = "All"
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    
    init() {
        setupNetworkMonitoring()
        fetchBooks()
    }
    
    private func setupNetworkMonitoring() {
        // Re-fetch books when network becomes available
        Task { @MainActor in
            for await _ in NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).values {
                if networkMonitor.isConnected {
                    fetchBooks()
                }
            }
        }
    }
    
    func fetchBooks() {
        guard networkMonitor.isConnected else {
            self.errorMessage = "No internet connection. Please check your network settings."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true  // Enable offline persistence
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
        
        db.collection("books").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    if (error as NSError).domain == NSURLErrorDomain {
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                    } else {
                        self.errorMessage = "Error fetching books: \(error.localizedDescription)"
                    }
                    print("Error fetching books: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No documents found"
                    return
                }
                
                let fetchedBooks = documents.compactMap { doc -> UserBook? in
                    UserBook(from: doc.data(), id: doc.documentID)
                }
                
                self.books = fetchedBooks
                self.filterBooks()
            }
        }
    }
    
    func filterBooks() {
        if selectedFilter == "All" {
            filteredBooks = books
        } else {
            filteredBooks = books.filter { $0.theme.lowercased() == selectedFilter.lowercased() }
        }
    }
    
    func getBookDetails(_ bookId: String) async -> UserBook? {
        guard networkMonitor.isConnected else {
            await MainActor.run {
                self.errorMessage = "No internet connection. Please check your network settings."
            }
            return nil
        }
        
        do {
            let document = try await db.collection("books").document(bookId).getDocument()
            guard let data = document.data() else {
                await MainActor.run {
                    self.errorMessage = "Book data not found"
                }
                return nil
            }
            
            return UserBook(from: data, id: document.documentID)
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching book details: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    var booksByTheme: [String: [UserBook]] {
        Dictionary(grouping: filteredBooks, by: { $0.theme.capitalized })
    }
}
