//
//  PageView.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//

import SwiftUI

struct PageView: View {
    let imageURL: String?
    let imageName: UIImage?
    let text: String
    
    var body: some View {
        ZStack {
            if let image = imageName {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                    .ignoresSafeArea()
                    .clipped()
            } else if let imageURL = imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                        .ignoresSafeArea()
                        .clipped()
                } placeholder: {
                    ProgressView("Loading image...")
                }
            } else {
                Color.gray
                    .ignoresSafeArea()
            }

            VStack {
                Spacer()
                
                VStack {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        let textArray = Array(text)
                        let firstValidIndex = textArray.firstIndex { $0.isLetter || $0.isNumber }
                        
                        if let index = firstValidIndex {
                            Text(String(textArray.prefix(index)))
                                .nunito(.bold, 22)
                                .foregroundColor(.white)
                            
                            Text(String(textArray[index]))
                                .nunito(.extraBold, 40)
                                .foregroundColor(.white)
                            
                            Text(String(textArray.dropFirst(index + 1)))
                                .nunito(.bold, 22)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        } else {
                            Text(text)
                                .nunito(.bold, 22)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .background(.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 30.0))
                .ignoresSafeArea(edges: .bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
        }
    }
}

