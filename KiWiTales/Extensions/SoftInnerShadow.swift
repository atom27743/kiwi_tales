//
//  SoftInnerShadow.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//


import SwiftUI

struct SoftInnerShadow: ViewModifier {
    var darkShadowColor: Color = .black.opacity(0.8)
    var lightShadowColor: Color = .white.opacity(0.2)
    var spread: CGFloat = 0.5
    var radius: CGFloat = 10
    var offset: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .background(
                Color.white
                    .shadow(color: darkShadowColor, radius: radius, x: offset, y: offset)
                    .shadow(color: lightShadowColor, radius: radius, x: -offset, y: -offset)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

extension View {
    func softInnerShadow(darkShadow: Color = Color.black.opacity(0.8), lightShadow: Color = Color.white.opacity(0.4), spread: CGFloat = 0.5, radius: CGFloat = 10, offset: CGFloat = 10) -> some View {
        self.modifier(SoftInnerShadow(darkShadowColor: darkShadow, lightShadowColor: lightShadow, spread: spread, radius: radius, offset: offset))
    }
}