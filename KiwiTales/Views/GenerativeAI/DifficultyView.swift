//
//  DifficultyView.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//

import SwiftUI

struct DifficultyView: View {
    @ObservedObject var viewModel: GenerateStoryViewModel
    @State private var showInformation: Bool = false
    
    private var data  = Array(1...4)
    private let adaptiveColumn = [GridItem(.adaptive(minimum: 150))]
    private let fixedColumns = [
        GridItem(.flexible(minimum: 250), spacing: 30),
        GridItem(.flexible(minimum: 250), spacing: 30)
    ]
    
    let color: Color = Color(hex: "BFDDFF")!
    
    private let images = ["1xDifficulty", "2xDifficulty", "3xDifficulty", "4xDifficulty"]
    private let labels = ["3 to 5", "6 to 7", "8 to 9", "10 to 12"]
    private let difficultySentences: [Int] = [5, 7, 9, 11]
    
    private var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var cardSize: CGFloat {
        return isIPad ? 250 : 150
    }
    
    init(viewModel: GenerateStoryViewModel) {
        self._viewModel = ObservedObject(initialValue: viewModel)
    }
        
    var body: some View {
        ScrollView {
            VStack {
                difficultySelectionGrid()
                informationSection()
            }
            .padding(isIPad ? 40 : 20)
        }
        .padding()
    }
    
    // Break down the grid content into a separate method
    private func difficultySelectionGrid() -> some View {
        LazyVGrid(columns: isIPad ? fixedColumns : adaptiveColumn, spacing: isIPad ? 30 : 20) {
            ForEach(data.indices, id: \.self) { item in
                difficultyCard(for: item)
                    .padding([.leading,.trailing], isIPad ? 20 : 15)
            }
        }
    }
    
    // Break down individual difficulty card creation
    private func difficultyCard(for item: Int) -> some View {
        ZStack {
            Image(images[item])
                .resizable()
                .scaledToFit()
                .frame(width: cardSize * 0.6, height: cardSize * 0.6)
            
            RoundedRectangle(cornerRadius: isIPad ? 15 : 10)
                .stroke(viewModel.selectedDifficulty == labels[item] ? Color.accentColor : Color.clear, lineWidth: 4)
                .if(showInformation) { view in
                    view.glassmorphism()
                }
            
            if showInformation || viewModel.selectedDifficulty == labels[item] {
                Text(labels[item])
                    .foregroundColor(.white)
                    .nunito(.bold, isIPad ? 32 : 24)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .frame(width: cardSize, height: cardSize)
        .background(color)
        .cornerRadius(isIPad ? 15 : 10)
        .foregroundStyle(Color.white)
        .font(.title)
        .softInnerShadow()
        .onTapGesture {
            let difficulty = labels[item]
            let sentences = difficultySentences[item]
            viewModel.saveDifficulty(difficulty, sentences: sentences)
        }
        .overlay(
            RoundedRectangle(cornerRadius: isIPad ? 15 : 10)
                .stroke(viewModel.selectedDifficulty == labels[item] ? Color.accentColor : Color.clear, lineWidth: 4)
        )
    }
    
    private func informationSection() -> some View {
        HStack(spacing: 10) {
            if showInformation {
                Text("* Choose a theme for your story")
                    .nunito(.regular, isIPad ? 16 : 13)
            }
            
            Image(systemName: "questionmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: isIPad ? 32 : 24, height: isIPad ? 32 : 24)
                .foregroundStyle(showInformation ? Color.theme.accent : Color.gray)
                .onTapGesture {
                    showInformation.toggle()
                }
        }
        .padding(isIPad ? 30 : 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    }
}

#Preview {
    DifficultyView(viewModel: .init())
}
