//
//  CustomAlert.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 9/23/24.
//

import SwiftUI

struct CustomAlert: View {
    @Binding var showCustomAlert: Bool
    var onSaveAndExit: () -> Void
    var onExit: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Material.ultraThinMaterial)
            
            VStack(spacing: 48) {
                Text("Oh no! If you exit now, your story won't be saved :(")
                    .nunito(.medium, 24)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                HStack(spacing: 18) {
                    Button(action: {
                        onSaveAndExit()
                    }) {
                        Text("Save & exit")
                            .nunito(.medium, 24)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        onExit()
                    }) {
                        Text("Exit")
                            .nunito(.medium, 24)
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(.appText)
                    .tint(.white)
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            
            Button {
                showCustomAlert = false
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 18, height: 18)
            }
            .padding()
            .tint(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .padding(18)
        .frame(height: 300)
    }
}

#Preview {
    CustomAlert(showCustomAlert: .constant(true), onSaveAndExit: {}, onExit: {})
}
