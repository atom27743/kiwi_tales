//
//  BookView.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 9/29/24.
//

import SwiftUI

struct BookView: View {
    let book: UserBook
    @Binding var cachedImages: [String: UIImage]
    
    var body: some View {
        VStack {
            if let imageUrl = book.image_urls.first {
                if let cachedImage = ImageCache.shared.getImage(forKey: imageUrl) {
                    Image(uiImage: cachedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 5, y: 5)
                        .onAppear {
                            print("Displaying cached image for URL: \(imageUrl)")
                        }
                } else {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .onAppear {
                                    if let uiImage = convertToUIImage(from: image) {
                                        print("Caching image for URL: \(imageUrl)")
                                        ImageCache.shared.setImage(uiImage, forKey: imageUrl)
                                    }
                                }
                        case .failure:
                            Text("Failed to load image")
                                .frame(width: 150, height: 200)
                                .cornerRadius(10)
                                .shadow(radius: 5, y: 5)
                        case .empty:
                            ProgressView()
                                .frame(width: 150, height: 200)
                                .cornerRadius(10)
                                .shadow(radius: 5, y: 5)
                        @unknown default:
                            ProgressView()
                                .frame(width: 150, height: 200)
                                .cornerRadius(10)
                                .shadow(radius: 5, y: 5)
                        }
                    }
                    .onAppear {
                        print("Fetching image from URL: \(imageUrl)")
                    }
                    .frame(width: 150, height: 200)
                    .cornerRadius(10)
                    .shadow(radius: 5, y: 5)
                }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray)
                    .frame(width: 150, height: 200)
                    .shadow(radius: 5, y: 5)
                    .overlay(Text("No Image"))
            }
        }
    }
    
    private func convertToUIImage(from image: Image) -> UIImage? {
        let controller = UIHostingController(rootView: image)
        let view = controller.view
        
        let targetSize = CGSize(width: 150, height: 200)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
        }
    }
}
