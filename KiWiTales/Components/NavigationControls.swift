//
//  NavigationControls.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/11/24.
//

import SwiftUI

struct NavigationControls: View {
    @Binding var currentPage: Int
    let totalPages: Int
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .foregroundColor(currentPage == 0 ? .gray : .white)
            }
            .disabled(currentPage == 0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .foregroundColor(currentPage == totalPages - 1 ? .gray : .white)
            }
            .disabled(currentPage == totalPages - 1)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
        }
    }
}
