//
//  SplashScreenView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Pixel-perfect implementation of the official Xchange Splash Screen
//  Displays animated 4-second loading sequence with brand emblem & progress bar
//

import SwiftUI

public struct SplashScreenView: View {
    public var duration: Double = 4.0
    public var onFinished: () -> Void
    
    @State private var progress: CGFloat = 0.0
    @State private var logoScale: CGFloat = 0.95
    @State private var logoOpacity: Double = 0.0
    
    // Official theme brand colors
    private let barFillGreen = Color(red: 0.24, green: 0.68, blue: 0.38)
    private let barTrackBackground = Color.white.opacity(0.18)
    private let progressBarWidth: CGFloat = 110
    private let progressBarHeight: CGFloat = 4.5
    
    public init(duration: Double = 4.0, onFinished: @escaping () -> Void) {
        self.duration = duration
        self.onFinished = onFinished
    }
    
    public var body: some View {
        ZStack {
            // Full Screen Background: Pure Black
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Centered Brand Emblem & Typography
                VStack(spacing: 16) {
                    // Hexagonal Barter Emblem with Azure Blue, Emerald Green & Diagonal Slash
                    XchangeEmblemView(scale: 1.25)
                    
                    // Brand Wordmark: "Xchange"
                    Text("Xchange")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(0.5)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // 4-Second Animated Loading Progress Bar
                ZStack(alignment: .leading) {
                    // Dark Capsule Track
                    Capsule()
                        .fill(barTrackBackground)
                        .frame(width: progressBarWidth, height: progressBarHeight)
                    
                    // Emerald Green Active Progress Fill
                    Capsule()
                        .fill(barFillGreen)
                        .frame(
                            width: max(progressBarWidth * progress, 4.5),
                            height: progressBarHeight
                        )
                }
                .padding(.top, 28)
                .opacity(logoOpacity)
                
                Spacer()
            }
        }
        .onAppear {
            // Smooth entrance animation
            withAnimation(.easeOut(duration: 0.5)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // Continuous 4-second loading progress
            withAnimation(.linear(duration: duration)) {
                progress = 1.0
            }
            
            // Navigate to Login Screen after exactly 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                AppTheme.triggerHaptic(style: .light)
                onFinished()
            }
        }
    }
}

#Preview {
    SplashScreenView(duration: 4.0) {
        print("Splash finished - navigating to Login Screen")
    }
}
