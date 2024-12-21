//
//  OnboardingHeader.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//


import SwiftUI

struct OnboardingHeader: View {
    var title: String
    var description: String
    @Binding var currentPage: Int
    let totalPages: Int
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 32) {
            HStack(alignment: .center) {
                Spacer()
                
                ForEach(0..<totalPages, id: \.self) { index in
                    Circle()
                        .foregroundStyle(index <= currentPage ? Color.theme.accent : Color(white: 0.9))
                        .frame(width: 44, height: 44)
                        .overlay {
                            Text("\(index + 1)")
                                .nunito(.black, 18)
                                .foregroundStyle(index <= currentPage ? Color.white : Color.black)
                        }
                    
                    if index < totalPages - 1 {
                        Spacer()
                        HStack {
                            ForEach(0..<5, id: \.self) { smallIndex in
                                Circle()
                                    .frame(width: 5, height: 5)
                                    .foregroundStyle(index >= currentPage ? Color(white: 0.85) : Color.theme.accent)
                            }
                        }
                        .frame(height: 10)
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .padding()
            
            VStack {
                Text(title)
                    .nunito(.extraBold, 24)
                    .foregroundStyle(Color.theme.primary)
                
                Text(description)
                    .nunito(.bold, 20)
                    .foregroundStyle(Color.theme.text)
            }
        }
        .padding()
        .padding(.top, 24)
        .background(GeometryReader { proxy in
            Color.clear
                .preference(key: OffsetPreferenceKey.self, value: proxy.frame(in: .global).minX)
        })
        .onPreferenceChange(OffsetPreferenceKey.self) { value in
            withAnimation(.easeInOut(duration: 0.3)) {
                self.offset = value
            }
        }
    }
    
    func smallCircleColor(for smallIndex: Int, at index: Int) -> Color {
        let progress = CGFloat(index) + (offset / UIScreen.main.bounds.width)
        let threshold = CGFloat(index) + CGFloat(smallIndex + 1) / 5
        return progress >= threshold ? Color.theme.accent : Color.theme.secondary
    }
}

struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
