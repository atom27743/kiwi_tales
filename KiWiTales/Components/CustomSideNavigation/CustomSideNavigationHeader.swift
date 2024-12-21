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
            if let imageURL = profileViewModel.user?.photoUrl, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode:
                                    .fit)
                            .frame(width:
                                    80, height: 80)
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
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image("kiwi_profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            }

            if let name = profileViewModel.user?.name {
                Text("Hello, \(Text(name).foregroundStyle(Color.theme.accent))")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.theme.text)
                    .multilineTextAlignment(.center)
            } else {
                Text("Welcome!")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.theme.text)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            print(
                "CustomSideNavigationHeader appeared. User: \(profileViewModel.user?.name ?? "No user")"
            )
            Task {
                do {
                    try await profileViewModel.loadCurrentUser()
                    print("Profile loaded: \(profileViewModel.user?.name ?? "No user")")
                } catch {
                    print("Failed to load current user: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    CustomSideNavigationHeader(profileViewModel: .init())
}


