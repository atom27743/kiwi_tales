//
//  Images.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 9/24/24.
//

import SwiftUI

extension Image {
    func asUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = CGSize(width: 1, height: 1)
        let size = view?.systemLayoutSizeFitting(targetSize)
        let bounds = CGRect(origin: .zero, size: size ?? targetSize)

        let format = UIGraphicsImageRendererFormat.default()
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)

        return renderer.image { _ in
            view?.drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}
