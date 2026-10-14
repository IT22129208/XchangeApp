//
//  ViewModifiers.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Custom SwiftUI Modifiers & Gesture Recognizers (Rubric Sections 2 & 3)
//

import SwiftUI

// MARK: - 1. Shimmer Loading Skeleton Modifier

public struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -0.8
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: max(phase - 0.3, 0)),
                            .init(color: Color.white.opacity(0.35), location: phase),
                            .init(color: .clear, location: min(phase + 0.3, 1))
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blendMode(.screen)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.6)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1.3
                }
            }
    }
}

// MARK: - 2. Pressable Micro-Spring Scale Modifier

public struct PressableScaleModifier: ViewModifier {
    var scale: CGFloat = 0.96
    
    public func body(content: Content) -> some View {
        Button(action: {}) {
            content
        }
        .buttonStyle(PressableScaleButtonStyle(scale: scale))
    }
}

public struct PressableScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - 3. Pinch-To-Zoom & Pan Gesture Recognizer Modifier

public struct PinchToZoomModifier: ViewModifier {
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(currentScale)
            .offset(offset)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / finalScale
                        currentScale = max(1.0, min(finalScale * delta, 3.5))
                    }
                    .onEnded { value in
                        finalScale = currentScale
                        if finalScale <= 1.05 {
                            withAnimation(.spring()) {
                                currentScale = 1.0
                                finalScale = 1.0
                                offset = .zero
                                lastOffset = .zero
                            }
                        }
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        if currentScale > 1.0 {
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
            .onTapGesture(count: 2) {
                withAnimation(.spring()) {
                    currentScale = 1.0
                    finalScale = 1.0
                    offset = .zero
                    lastOffset = .zero
                }
                AppTheme.triggerHaptic(style: .light)
            }
    }
}

// MARK: - View Extension Helpers

public extension View {
    /// Applies a continuous shimmering skeleton animation
    func shimmerLoading() -> some View {
        self.modifier(ShimmerModifier())
    }
    
    /// Adds subtle spring squeeze on user touch
    func pressableScale(scale: CGFloat = 0.96) -> some View {
        self.modifier(PressableScaleModifier(scale: scale))
    }
    
    /// Enables interactive two-finger pinch-to-zoom and double-tap-to-reset gesture
    func pinchToZoom() -> some View {
        self.modifier(PinchToZoomModifier())
    }
    
    /// Premium adaptive card container with border stroke and ambient shadow
    func modernCard(cornerRadius: CGFloat = 18) -> some View {
        self
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}
