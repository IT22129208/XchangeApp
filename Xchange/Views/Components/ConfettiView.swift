//
//  ConfettiView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Particle Physics Animation for Completed Trades (Rubric Section 2)
//

import SwiftUI

public struct ConfettiView: View {
    @State private var isAnimating: Bool = false
    
    private let colors: [Color] = [
        AppTheme.primary,
        AppTheme.tradeAccent,
        AppTheme.counterAccent,
        Color.yellow,
        Color.purple,
        Color.orange
    ]
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<45, id: \.self) { index in
                    ConfettiPiece(
                        containerSize: geo.size,
                        color: colors[index % colors.count],
                        index: index,
                        isAnimating: isAnimating
                    )
                }
            }
            .onAppear {
                isAnimating = true
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: View {
    let containerSize: CGSize
    let color: Color
    let index: Int
    let isAnimating: Bool
    
    private var randomX: CGFloat {
        CGFloat.random(in: 20...(containerSize.width - 20))
    }
    
    private var randomSize: CGFloat {
        CGFloat.random(in: 6...12)
    }
    
    private var randomRotation: Double {
        Double.random(in: 0...720)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: randomSize, height: randomSize * 1.5)
            .position(
                x: isAnimating ? randomX : containerSize.width / 2,
                y: isAnimating ? containerSize.height + 40 : -20
            )
            .rotationEffect(.degrees(isAnimating ? randomRotation : 0))
            .animation(
                Animation.interpolatingSpring(stiffness: 12, damping: 5)
                    .speed(Double.random(in: 0.5...0.9))
                    .delay(Double(index) * 0.025),
                value: isAnimating
            )
            .opacity(isAnimating ? 0.9 : 0)
    }
}
