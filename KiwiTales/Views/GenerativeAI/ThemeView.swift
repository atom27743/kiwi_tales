//
//  ThemeView.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//

import SwiftUI

struct ThemeView: View {
    @ObservedObject var viewModel: GenerateStoryViewModel
    
    private var data  = Array(1...4)
    private let adaptiveColumn = [GridItem(.adaptive(minimum: 150))]
    private let fixedColumns = [
        GridItem(.flexible(minimum: 250), spacing: 30),
        GridItem(.flexible(minimum: 250), spacing: 30)
    ]
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State var images = [ImageTheme(name: "fantasy", backgroundHex: "6CC864"), ImageTheme(name: "family", backgroundHex: "FFE77D"), ImageTheme(name: "nature", backgroundHex: "DCC7FF"), ImageTheme(name: "adventure", backgroundHex: "FFBFCE")]
    
    init(viewModel: GenerateStoryViewModel) {
        self._viewModel = ObservedObject(initialValue: viewModel)
    }
    
    private var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var cardSize: CGFloat {
        return isIPad ? 250 : 150
    }
        
    var body: some View {
        ScrollView {
            LazyVGrid(columns: isIPad ? fixedColumns : adaptiveColumn, spacing: isIPad ? 30 : 20) {
                ForEach(images) { image in
                    VStack(spacing: isIPad ? 8 : 2) {
                        Image(uiImage: image.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: cardSize * 0.6, height: cardSize * 0.6)
                        Text(image.title.capitalized)
                            .nunito(.semiBold, isIPad ? 32 : 24)
                            .foregroundStyle(Color(image.color))
                    }
                    .frame(width: cardSize, height: cardSize)
                    .background(Color(image.backgroundColor))
                    .cornerRadius(15)
                    .font(.title)
                    .softInnerShadow()
                    .onTapGesture {
                        viewModel.selectedTheme = image.title
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(viewModel.selectedTheme == image.title ? Color.accentColor : Color.clear, lineWidth: 4)
                    )
                }
            }
            .padding(isIPad ? 40 : 20)
        }
        .padding()
    }
}

#Preview {
    ThemeView(viewModel: .init())
}
