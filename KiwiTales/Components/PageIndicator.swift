//
//  PageIndicator.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/11/24.
//

import SwiftUI

struct PageIndicator: View {
    @Binding var currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index <= currentPage ? Color.accentColor : Color.white.opacity(0.8))
                    .frame(width: capsuleWidth(for: totalPages), height: 10)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
        .frame(width: fixedWidth(), alignment: .center)  // Ensure a fixed width
        .padding(.horizontal, 16)
    }
    
    // This function controls the width of each capsule, shrinking if more pages are added
    private func capsuleWidth(for totalPages: Int) -> CGFloat {
        let maxCapsuleWidth: CGFloat = 30
        let minCapsuleWidth: CGFloat = 10
        let maxVisiblePages: Int = 5  // Maximum number of visible page indicators
            
        // Adjust the capsule width based on the number of total pages
        if totalPages > maxVisiblePages {
            let adaptiveWidth = maxCapsuleWidth - CGFloat(totalPages - maxVisiblePages)
            return max(adaptiveWidth, minCapsuleWidth)
        } else {
            return maxCapsuleWidth
        }
    }
    
    // This function ensures the total width is consistent, regardless of the page count
    private func fixedWidth() -> CGFloat {
        return UIScreen.main.bounds.width / 2
    }
}
