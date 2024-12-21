//
//  CustomNavigationBarHome.swift
//  KiWi
//
//  Created by Takumi Otsuka on 8/10/24.
//

import SwiftUI

struct CustomNavigationBarHome: View {
    @Binding var selectedTab: Tabs
    @Binding var showMenu: Bool
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                HStack {
                    Button {
                        showMenu = true
                    } label: {
                        Image(systemName: "line.horizontal.3")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .padding(.leading, 26)
                    .padding(.bottom, 12)
                    .tint(Color.theme.text)
                    
                    Spacer()
                }
                .frame(height: 100, alignment: .bottom)

                Text("KiWiTales")
                    .foregroundStyle(Color.theme.accent)
                    .nunito(.extraBold, 24)
                    .padding(.bottom, 4)
            }
            .frame(maxWidth: .infinity)
            .background(Color.theme.background)
        }
    }
}

#Preview {
    @Previewable
    @State var selectedTab: Tabs = .home
    
    CustomNavigationBarHome(selectedTab: $selectedTab, showMenu: .constant(false))
}
