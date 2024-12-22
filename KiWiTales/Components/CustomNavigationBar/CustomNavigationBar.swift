//
//  CustomNavigationBar.swift
//  KiWi
//
//  Created by Takumi Otsuka on 8/10/24.
//

import SwiftUI

struct CustomNavigationBar: View {
    @Binding var showMenu: Bool
    @Binding var selectedTab: Tabs
    var headerTitle: String
    var headerImage: String
    var headerColor: Color?
    
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
                    .padding(.bottom , 12)
                    .tint(Color.theme.text)
                    
                    Spacer()
                }
                .frame(height: 100, alignment: .bottom)

                Button {
                    selectedTab = .home
                } label: {
                    Text("KiwiTales")
                        .nunito(.extraBold, 24)
                        .padding(.bottom, 4)
                }
                .tint(Color.accentColor)
            }
            .frame(maxWidth: .infinity)
            .background(Color.theme.background)
            
            TitleHeader(headerTitle: headerTitle, headerImage: headerImage, color: headerColor)
        }
    }
}

#Preview {
    @Previewable
    @State var selectedTab: Tabs = .dashboard
    
    CustomNavigationBar(showMenu: .constant(false), selectedTab: $selectedTab, headerTitle: "My Books", headerImage: "family_star", headerColor: Color.theme.primary)
}
