//
//  HueGradient.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/7/24.
//

import SwiftUI

struct HueGradient: ViewModifier {
    @State private var pulsate = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: pulsate ? 10 : 3)
                .animation(.easeInOut(duration: 2.5).repeatForever(), value: pulsate)
                .onAppear {
                    pulsate.toggle()
                }
            
            content
        }
    }
}

extension View {
    func hueGradient() -> some View {
        modifier(HueGradient())
    }
}
