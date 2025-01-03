//
//  ImageTheme.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//


import SwiftUI

struct ImageTheme: Identifiable {
    let id: String
    let title: String
    let image: UIImage
    let color: UIColor
    let backgroundColor: UIColor
    
    init(name: String, backgroundHex: String) {
        id = UUID().uuidString
        title = name
        image = UIImage(named: name)!
        color = image.findAverageColor() ?? .clear
        backgroundColor = UIColor(hex: backgroundHex) ?? .clear
    }
}