//
//  LoadingIndicator.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/8/24.
//

import SwiftUI

struct LoadingIndicator: View {
    @State private var isAnimating = false
    @State private var waveOffset = Angle(degrees: 0)
    @State private var animatedProgress: Double = 0
    @State private var animationTimer: Timer?
    @ObservedObject var viewModel: GenerateStoryViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Wave Animation at bottom
                VStack {
                    Spacer()
                    Wave(offset: waveOffset, percent: animatedProgress * 100)
                        .fill(.accent.opacity(0.56))
                        .ignoresSafeArea()
                }
                
                // Content
                VStack(spacing: 20) {
                    // Animated Image
                    Image("tea")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.theme.accent)
                        .offset(y: isAnimating ? -10 : 10)
                        .animation(
                            Animation.easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        .padding(.bottom, 12)
                    
                    // Loading Text
                    Text(viewModel.loadingMessage)
                        .nunito(.semiBold, 24)
                        .foregroundStyle(Color.theme.primary)
                        .multilineTextAlignment(.center)
                    
                    // Fun Fact Section
                    VStack(spacing: 8) {
                        Text("Book worm fact!")
                            .nunito(.medium, 18)
                            .foregroundStyle(Color.gray.opacity(0.8))
                        
                        Text("The longest novel ever written is\n3 million words long!")
                            .nunito(.regular, 16)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.gray.opacity(0.6))
                    }
                    .padding(.top, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color.white)
        }
        .onAppear {
            isAnimating = true
            startWaveAnimation()
        }
        .onDisappear {
            // Clean up timer when view disappears
            animationTimer?.invalidate()
            animationTimer = nil
        }
        .onChange(of: viewModel.loadingProgress) { _, newProgress in
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedProgress = newProgress
            }
        }
    }
    
    private func startWaveAnimation() {
        // Initial animation
        animate()
        
        // Setup timer for continuous animation
        animationTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            animate()
        }
    }
    
    private func animate() {
        // Reset without animation
        waveOffset = .zero
        
        // Animate to full rotation
        withAnimation(.linear(duration: 2)) {
            waveOffset = Angle(degrees: 360)
        }
    }
}

struct WaveAnimation: View {
    @State private var percent = 20.0
    @State private var waveOffset = Angle(degrees: 0)
    
    var body: some View {
        ZStack {
            // Wave
            Wave(offset: Angle(degrees: waveOffset.degrees), percent: percent)
                .fill(.accent.opacity(0.56))
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                self.waveOffset = Angle(degrees: 360)
            }
        }
    }
}

struct Wave: Shape {
    var offset: Angle
    var percent: Double
    
    var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(offset.degrees, percent)
        }
        set {
            offset = Angle(degrees: newValue.first)
            percent = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        
        let lowestWave = 0.02
        let highestWave = 1.0
        
        let newPercent = lowestWave + (highestWave - lowestWave) * (percent / 100)
        let waveHeight = 0.025 * rect.height
        let yOffset = CGFloat(1 - newPercent) * (rect.height - 4 * waveHeight) + 2 * waveHeight
        let startAngle = offset
        let endAngle = offset + Angle(degrees: 360 + 10)
        
        p.move(to: CGPoint(x: 0, y: yOffset + waveHeight * CGFloat(sin(offset.radians))))
        
        for angle in stride(from: startAngle.degrees, through: endAngle.degrees, by: 3) {
            let x = CGFloat((angle - startAngle.degrees) / 360) * rect.width
            p.addLine(to: CGPoint(x: x, y: yOffset + waveHeight * CGFloat(sin(Angle(degrees: angle).radians))))
        }
        
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        
        return p
    }
}

#Preview {
    LoadingIndicator(viewModel: GenerateStoryViewModel())
}
