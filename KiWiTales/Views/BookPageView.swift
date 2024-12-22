//
//  BookPageView.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 12/22/24.
//

import SwiftUI

struct BookPageView: View {
    let imageURL: String?
    let text: String
    
    var body: some View {
        ZStack {
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                            .ignoresSafeArea()
                            .clipped()
                    default:
                        Color.gray.opacity(0.2)
                            .ignoresSafeArea()
                    }
                }
            } else {
                Color.gray.opacity(0.2)
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

#Preview {
    BookPageView(
        imageURL: "https://firebasestorage.googleapis.com:443/v0/b/kiwi-d57c5.appspot.com/o/books%2FZZDUDd1bJsZw8G0Z03cx0yfanDu1%2F5B084C43-8F92-4713-997D-FA7E32F2EAA8%2Fimages%2F2.jpg?alt=media&token=3a19ed09-b518-40ba-83bb-1567c5549ce4",
        text: "The stinky flower was bigger than the princess!")
}
