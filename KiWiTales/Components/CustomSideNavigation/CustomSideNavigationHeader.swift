//
//  CustomSideNavigationHeader.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/7/24.
//

import SwiftUI

struct CustomSideNavigationHeader: View {
    @ObservedObject var profileViewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 24) {
            if let user = profileViewModel.user {
                if let photoURL = user.photoURL, let url = URL(string: photoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .background(
                                Circle()
                                    .stroke(Color(hex: "FFFCF6") ?? .white, lineWidth: 6)
                                    .background(
                                        Circle()
                                            .stroke(
                                                Color(hex: "DAECED") ?? Color.white,
                                                lineWidth: 2
                                            )
                                            .hueGradient()
                                    )
                            )
                    } placeholder: {
                        Circle()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    }
                } else if let displayName = user.name {
                    // Show initials avatar when no profile picture is available
                    ZStack {
                        Circle()
                            .fill(displayName.profileColor)
                            .frame(width: 80, height: 80)
                            .background(
                                Circle()
                                    .stroke(Color(hex: "FFFCF6") ?? .white, lineWidth: 6)
                                    .background(
                                        Circle()
                                            .stroke(
                                                Color(hex: "DAECED") ?? Color.white,
                                                lineWidth: 2
                                            )
                                            .hueGradient()
                                    )
                            )
                        
                        Text(displayName.initials)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    // Fallback when neither photo nor name is available
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image("kiwi_profile")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                        )
                        .background(
                            Circle()
                                .stroke(Color(hex: "FFFCF6") ?? .white, lineWidth: 6)
                                .background(
                                    Circle()
                                        .stroke(
                                            Color(hex: "DAECED") ?? Color.white,
                                            lineWidth: 2
                                        )
                                        .hueGradient()
                                )
                        )
                }
                
                if let displayName = user.name {
                    Text("Hello, \(displayName)")
                        .font(.headline)
                        .foregroundStyle(Color.theme.text)
                } else {
                    Text("Welcome!")
                        .font(.headline)
                        .foregroundStyle(Color.theme.text)
                }
            } else {
                Image("kiwi_profile")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                
                Text("Welcome!")
                    .font(.headline)
                    .foregroundStyle(Color.theme.text)
            }
        }
        .task {
            await loadUserProfile()
        }
        .onChange(of: profileViewModel.user?.name) { newValue in
            print("Display name updated: \(newValue ?? "nil")")
        }
    }
    
    private func loadUserProfile() async {
        do {
            try await profileViewModel.loadCurrentUser()
            print("Profile loaded: \(profileViewModel.user?.name ?? "No user")")
        } catch {
            print("Failed to load current user: \(error.localizedDescription)")
        }
    }
}

#Preview {
    CustomSideNavigationHeader(profileViewModel: .init())
}

fileprivate extension String {
    var initials: String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.reduce("") { result, component in
            guard let first = component.first?.uppercased() else { return result }
            return result + first
        }
    }
    
    var profileColor: Color {
        let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .teal]
        let hash = abs(self.hashValue)
        let index = hash % colors.count
        return colors[index]
    }
}
