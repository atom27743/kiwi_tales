//
//  CustomSideNavigationRow.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/8/24.
//

import SwiftUI

struct CustomSideNavigationRow: View {
    let option: Tabs
    
    var body: some View {
        HStack(spacing: 16) {
            Image(option.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .frame(width: 40, alignment: .leading)
            
            Text(option.title)
                .nunito(.bold, 18)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CustomSideNavigationRow(option: .dashboard)
}
