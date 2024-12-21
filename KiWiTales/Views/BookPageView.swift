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
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.white)
                            
                            Text(String(textArray[index]))
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(String(textArray.dropFirst(index + 1)))
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        } else {
                            Text(text)
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding()
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 230)
                .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 20.0))
                .ignoresSafeArea(edges: .bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
        }
    }
}
