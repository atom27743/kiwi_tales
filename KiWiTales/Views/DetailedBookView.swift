//
//  DetailedBookView.swift
//  KiWiTales
//
//  Created by Jina Lee on 10/5/24.
//

import Foundation
import SwiftUI

struct DetailedBookView: View {
    var book: UserBook
    var animation: Namespace.ID

    var body: some View {
        VStack(spacing: 32) {
            AsyncImage(url: URL(string: book.image_urls.first ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } placeholder: {
                ProgressView()
            }
            .frame(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.height * 0.4)
            .cornerRadius(20)
            .shadow(radius: 10)
            .matchedGeometryEffect(id: book.id, in: animation)
            .padding(.top, 48)

            Text(book.title)
                .nunito(.semiBold, 28)
                .foregroundStyle(.white)
                .padding()

            Spacer()
        }
    }
}
