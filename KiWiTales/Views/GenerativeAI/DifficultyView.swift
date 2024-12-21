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
    
    let color: Color = Color(hex: "BFDDFF")!
    
    private let images = ["1xDifficulty", "2xDifficulty", "3xDifficulty", "4xDifficulty"]
    private let labels = ["3 to 5", "6 to 7", "8 to 9", "10 to 12"]
    private let difficultySentences: [Int] = [5, 7, 9, 11]
    
    init(viewModel: GenerateStoryViewModel) {
        self._viewModel = ObservedObject(initialValue: viewModel)
    }
        
    var body: some View {
        ScrollView {
            VStack {
                difficultySelectionGrid()
                
                informationSection()
            }
            .padding(4)
        }
        .padding()
    }
    
    // Break down the grid content into a separate method
    private func difficultySelectionGrid() -> some View {
        LazyVGrid(columns: adaptiveColumn, spacing: 20) {
            ForEach(data.indices, id: \.self) { item in
                difficultyCard(for: item)
            }
        }
    }
    
    // Break down individual difficulty card creation
    private func difficultyCard(for item: Int) -> some View {
        ZStack {
            Image(images[item])
                .frame(width: 150, height: 150, alignment: .center)
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(viewModel.selectedDifficulty == labels[item] ? Color.accentColor : Color.clear, lineWidth: 4)
                .if(showInformation) { view in
                    view.glassmorphism()
                }
            
            if showInformation || viewModel.selectedDifficulty == labels[item] {
                Text(labels[item])
                    .foregroundColor(.white)
                    .nunito(.bold, 24)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .background(color)
        .cornerRadius(10)
        .foregroundStyle(Color.white)
        .font(.title)
        .softInnerShadow()
        .onTapGesture {
            let difficulty = labels[item]
            let sentences = difficultySentences[item]
            viewModel.saveDifficulty(difficulty, sentences: sentences)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(viewModel.selectedDifficulty == labels[item] ? Color.accentColor : Color.clear, lineWidth: 4)
        )
    }
    
    private func informationSection() -> some View {
        HStack(spacing: 10) {
            if showInformation {
                Text("* Choose a theme for your story")
                    .nunito(.regular, 13)
            }
            
            Image(systemName: "questionmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(showInformation ? Color.theme.accent : Color.gray)
                .onTapGesture {
                    showInformation.toggle()
                }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    }
}

