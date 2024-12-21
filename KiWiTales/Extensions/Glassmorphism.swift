//
//  Glassmorphism.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//

import SwiftUI

struct Glassmorphism: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    private let cornerRadius: CGFloat
    private var gradients: [Color] { [
            Color.white.opacity(1.0),
            Color.white.opacity(0.1),
            Color.white.opacity(0.1),
            Color.white.opacity(0.4),
            Color.white.opacity(0.5),
        ]
    }
    
    init(_ cornerRadius: CGFloat = 16.0) {
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Material.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(LinearGradient(
                        colors: gradients,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                    )
            }
    }
}

extension View {
    func glassmorphism(cornerRadius: CGFloat = 16.0) -> some View {
        modifier(Glassmorphism(cornerRadius))
    }
    
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
