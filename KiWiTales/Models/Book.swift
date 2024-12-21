//
//  Page.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/11/24.
//

// Collects from Gemini Model
import Foundation
import UIKit

struct StorySegment: Codable {
    let title: String
    let coverImagePrompt: String
    let contents: [Contents]
    
    enum CodingKeys: String, CodingKey {
        case title
        case coverImagePrompt = "cover_image_prompt"
        case contents
    }
}

struct Contents: Codable {
    let sentence: String
    let imagePrompt: String
    
    enum CodingKeys: String, CodingKey {
        case sentence
        case imagePrompt = "image_prompt"
    }
}
