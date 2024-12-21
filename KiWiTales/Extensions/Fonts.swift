//
//  Fonts.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//


import SwiftUI

enum Fonts {
    case black
    case blackItalic
    case bold
    case boldItalic
    case extraBold
    case extraBoldItalic
    case extraLight
    case extraLightItalic
    case italic
    case light
    case lightItalic
    case medium
    case mediumItalic
    case regular
    case semiBold
    case semiBoldItalic
}

extension Font {
    static let nunito: (Fonts, CGFloat) -> Font = { fontType, size in
        switch fontType {
        case .black:
            .custom("Nunito-Black", size: size)
        case .blackItalic:
            .custom("Nunito-BlackItalic", size: size)
        case .bold:
            .custom("Nunito-Bold", size: size)
        case .boldItalic:
            .custom("Nunito-BoldItalic", size: size)
        case .extraBold:
            .custom("Nunito-ExtraBold", size: size)
        case .extraBoldItalic:
            .custom("Nunito-ExtraBoldItalic", size: size)
        case .extraLight:
            .custom("Nunito-ExtraLight", size: size)
        case .extraLightItalic:
            .custom("Nunito-ExtraLightItalic", size: size)
        case .italic:
            .custom("Nunito-Italic", size: size)
        case .light:
            .custom("Nunito-Light", size: size)
        case .lightItalic:
            .custom("Nunito-LightItalic", size: size)
        case .medium:
            .custom("Nunito-Medium", size: size)
        case .mediumItalic:
            .custom("Nunito-MediumItalic", size: size)
        case .regular:
            .custom("Nunito-Regular", size: size)
        case .semiBold:
            .custom("Nunito-SemiBold", size: size)
        case .semiBoldItalic:
            .custom("Nunito-SemiBoldItalic", size: size)
        }
    }
}

extension Text {
    func nunito(_ font: Fonts? = .regular, _ size: CGFloat? = nil) -> Text {
        return self.font(.nunito(font ?? .regular, size ?? 16.0))
    }
}