//
//  BookModel.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 12/21/24.
//

// Used only for ExploreView
import Foundation

struct BookModel: Identifiable {
    var id: String
    var theme: String
    var title: String
    var imageURLs: [String]
    var generatedTexts: [String]
    var imagePrompts: [String]
    var coverImagePrompt: String
    var difficulty: String
}
