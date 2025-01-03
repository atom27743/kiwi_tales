//
//  UserBook.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 9/19/24.
//

import Foundation
import FirebaseFirestore

// Saved to Firestore
struct UserBook: Codable, Identifiable {
    @DocumentID var id: String?
    let book_id: String
    let cover_image_prompt: String
    let date_created: Date
    let difficulty: String
    let generated_texts: [String]
    let image_prompts: [String]
    let image_urls: [String]
    let theme: String
    let title: String
    let user_id: String
    
    // Add convenience initializer for creating from Firestore data
    init?(from dict: [String: Any], id: String) {
        self.id = id
        guard let book_id = dict["book_id"] as? String,
              let cover_image_prompt = dict["cover_image_prompt"] as? String,
              let date_created = (dict["date_created"] as? Timestamp)?.dateValue(),
              let difficulty = dict["difficulty"] as? String,
              let generated_texts = dict["generated_texts"] as? [String],
              let image_prompts = dict["image_prompts"] as? [String],
              let image_urls = dict["image_urls"] as? [String],
              let theme = dict["theme"] as? String,
              let title = dict["title"] as? String,
              let user_id = dict["user_id"] as? String
        else { return nil }
        
        self.book_id = book_id
        self.cover_image_prompt = cover_image_prompt
        self.date_created = date_created
        self.difficulty = difficulty
        self.generated_texts = generated_texts
        self.image_prompts = image_prompts
        self.image_urls = image_urls
        self.theme = theme
        self.title = title
        self.user_id = user_id
    }
}
