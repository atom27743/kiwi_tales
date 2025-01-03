//
//  GenerateStoryView.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//

import SwiftUI
import FirebaseAuth

enum AlertType {
    case authenticationRequired
    case insufficientInformation
}

struct GenerateStoryView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var generateStoryViewModel: GenerateStoryViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @State private var currentPage: Int = 0
    @State private var createStory: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertType: AlertType?
    
    @Binding var showSignInView: Bool
    @Binding var selectGenerate: Bool
    
    let totalPages: Int = 3
    
    let titles = ["Unleash your imagination", "Set the stage", "Tailor your tale"]
    let descriptions = ["Pick your magic words!", "Choose your story's theme!", "Select your story's complexity!"]
    
    var body: some View {
        ZStack {
            exitButton
                .padding(.top, 30)
            
            VStack {
                OnboardingHeader(
                    title: titles[currentPage],
                    description: descriptions[currentPage],
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .padding()
                .padding(.top, 60)
                
                ZStack(alignment: .bottom) {
                    TabView(selection: $currentPage) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            tabView(for: index)
                                .tag(index)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onChange(of: currentPage) { _, newPage in
                        validatePageChange(for: newPage)
                    }
                    .offset(y:-40)
                    
                    VStack(spacing: 10) {
                        Button {
                            withAnimation {
                                proceedToNextPage()
                            }
                        } label: {
                            Text(currentPage == totalPages - 1 ? "Generate" : "Next")
                                .nunito(.semiBold, 18)
                                .foregroundStyle(Color.white)
                                .padding(8)
                                .frame(width: 130, height: 45)
                                .background(RoundedRectangle(cornerRadius: 15).fill(Color.theme.accent))
                        }
                        
                        // Back button
                        if currentPage > 0 {
                            Button {
                                withAnimation {
                                    currentPage -= 1
                                }
                            } label: {
                                Text("Back")
                                    .nunito(.semiBold, 18)
                                    .foregroundStyle(Color.white)
                                    .padding(6)
                                    .frame(width: 130, height: 45)
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.4)))
                            }
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 75)
                    .alert(isPresented: $showAlert) {
                        switch alertType {
                        case .authenticationRequired:
                            return Alert(
                                title: Text("Authentication Required"),
                                message: Text(alertMessage),
                                primaryButton: .default(Text("Sign In"), action: {
                                    showSignInView = true
                                }),
                                secondaryButton: .cancel()
                            )
                        case .insufficientInformation:
                            return Alert(
                                title: Text("Insufficient Information"),
                                message: Text(alertMessage),
                                dismissButton: .default(Text("OK"))
                            )
                        case .none:
                            return Alert(title: Text("Error"))
                        }
                    }
                }
            }
        }
        .background(Color.white)
        .ignoresSafeArea()
        .sheet(isPresented: $showSignInView) {
            AuthenticationView(showSignInView: $showSignInView)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $createStory, content: {
            StoryView(viewModel: generateStoryViewModel, selectGenerate: $selectGenerate)
        })
    }
    
    @ViewBuilder
    func tabView(for index: Int) -> some View {
        switch index {
        case 0:
            KeywordsView(viewModel: generateStoryViewModel)
        case 1:
            ThemeView(viewModel: generateStoryViewModel)
        case 2:
            DifficultyView(viewModel: generateStoryViewModel)
        default:
            ProgressView()
        }
    }
    
    func validatePageChange(for newPage: Int) {
        switch newPage {
        case 1:
            if generateStoryViewModel.keywords.isEmpty || generateStoryViewModel.keywords.count < 3 {
                alertMessage = "Please provide three keywords."
                alertType = .insufficientInformation
                showAlert = true
                currentPage = 0
            }
        case 2:
            if generateStoryViewModel.selectedTheme.isEmpty {
                alertMessage = "Please select a theme."
                alertType = .insufficientInformation
                showAlert = true
                currentPage = 1
            }
        case 3:
            if generateStoryViewModel.selectedDifficulty.isEmpty {
                alertMessage = "Please select a difficulty level."
                alertType = .insufficientInformation
                showAlert = true
                currentPage = 2
            }
        default:
            break
        }
    }
    
    private func proceedToNextPage() {
        if currentPage == totalPages - 1 {
            // On the last page, check authentication before generating
            if Auth.auth().currentUser?.isAnonymous == true {
                alertType = .authenticationRequired
                alertMessage = "Please sign in to save your stories"
                showAlert = true
            } else {
                // User is authenticated with SSO, proceed with generation
                createStory = true
            }
        } else {
            if validateCurrentPage() {
                currentPage += 1
            }
        }
    }
    
    func validateCurrentPage() -> Bool {
        switch currentPage {
        case 0:
            if generateStoryViewModel.keywords.isEmpty || generateStoryViewModel.keywords.count < 3 {
                alertMessage = "Please provide three keywords."
                alertType = .insufficientInformation
                showAlert = true
                return false
            }
        case 1:
            if generateStoryViewModel.selectedTheme.isEmpty {
                alertMessage = "Please select a theme."
                alertType = .insufficientInformation
                showAlert = true
                return false
            }
        case 2:
            if generateStoryViewModel.selectedDifficulty.isEmpty {
                alertMessage = "Please select a difficulty level."
                alertType = .insufficientInformation
                showAlert = true
                return false
            }
        default:
            break
        }
        return true
    }
    
    func checkAuthenticationAndGenerateStory() {
        if Auth.auth().currentUser == nil {
            alertMessage = "You must log in to generate a story."
            alertType = .authenticationRequired
            showAlert = true
        } else {
            generateStoryViewModel.generateStory()
            createStory = true
        }
    }
    
    @ViewBuilder
    var exitButton: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                selectGenerate = false
            } label: {
                Image(systemName: "xmark")
                    .font(.title3.weight(.black))
                    .padding(12)
            }
            .foregroundStyle(Color(hex: "5E5E5E", opacity: 1.0) ?? Color.gray)
            .padding(24)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}

#Preview {
    GenerateStoryView(authenticationViewModel: .init(), generateStoryViewModel: GenerateStoryViewModel.init(), profileViewModel: .init(), showSignInView: .constant(true), selectGenerate: .constant(true))
}
