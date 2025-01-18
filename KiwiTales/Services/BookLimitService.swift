//
//  BookLimitService.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 1/15/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class BookLimitService {
    private let db = Firestore.firestore()
    static let shared = BookLimitService()
    private let maxDailyBooks = 2
    
    func canCreateBook() async throws -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw APIError.invalidRequest(message: "User not authenticated")
        }
        
        // Get today's start and end timestamps
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Query books created today
        let query = db.collection("books")
            .whereField("user_id", isEqualTo: userId)
            .whereField("date_created", isGreaterThan: Timestamp(date: startOfDay))
            .whereField("date_created", isLessThan: Timestamp(date: endOfDay))
        
        let snapshot = try await query.getDocuments()
        return snapshot.documents.count < maxDailyBooks
    }
    
    func getRemainingBooks() async throws -> Int {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw APIError.invalidRequest(message: "User not authenticated")
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let query = db.collection("books")
            .whereField("user_id", isEqualTo: userId)
            .whereField("date_created", isGreaterThan: Timestamp(date: startOfDay))
            .whereField("date_created", isLessThan: Timestamp(date: endOfDay))
            
        let snapshot = try await query.getDocuments()
        return maxDailyBooks - snapshot.documents.count
    }
} 
