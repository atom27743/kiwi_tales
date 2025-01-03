//
//  TitleHeader.swift
//  KiWi
//
//  Created by Takumi Otsuka on 8/10/24.
//

import SwiftUI

struct TitleHeader: View {
    var headerTitle: String
    var headerImage: String
    var color: Color?
    
    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            Image(headerImage)
                .resizable()
                .scaledToFill()
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
            
            Text(headerTitle)
                .font(.title2)
        }
        .padding(14)
        .frame(width: 360)
        .foregroundStyle(.white)
        .fontWeight(.bold)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 22.0))
        .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 18.0)
                .stroke(Color.white, lineWidth: 4.0)
        )
    }
}

#Preview {
    TitleHeader(headerTitle: "My Books", headerImage: "family_star", color: Color.theme.primary)
}
