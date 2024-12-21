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
    
    @State var images = [ImageTheme(name: "fantasy", backgroundHex: "6CC864"), ImageTheme(name: "family", backgroundHex: "FFE77D"), ImageTheme(name: "nature", backgroundHex: "DCC7FF"), ImageTheme(name: "adventure", backgroundHex: "FFBFCE")]
    
    init(viewModel: GenerateStoryViewModel) { 
        self._viewModel = ObservedObject(initialValue: viewModel)
    }
        
    var body: some View {
        ScrollView {
            LazyVGrid(columns: adaptiveColumn, spacing: 20) {
                ForEach(images) { image in
                    VStack(spacing: 4) {
                        Image(uiImage: image.image)
                        Text(image.title.capitalized)
                            .nunito(.semiBold, 24)
                            .foregroundStyle(Color(image.color))
                    }
                    .frame(width: 150, height: 150, alignment: .center)
                    .background(Color(image.backgroundColor))
                    .cornerRadius(10)
                    .font(.title)
                    .softInnerShadow()
                    .onTapGesture {
                        viewModel.selectedTheme = image.title
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(viewModel.selectedTheme == image.title ? Color.accentColor : Color.clear, lineWidth: 4)
                    )
                }
            }
            .padding(4)
        }
        .padding()
    }
}