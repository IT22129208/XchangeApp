//
//  AppTheme.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//

import SwiftUI

public struct AppTheme {
    // XChange Official Brand Colors (Electric Blue & Emerald Cyan)
    public static let brandBlue = Color(red: 0.08, green: 0.46, blue: 0.98) // Electric Blue
    public static let brandGreen = Color(red: 0.00, green: 0.84, blue: 0.60) // Vivid Emerald Cyan
    public static let brandDark = Color(red: 0.05, green: 0.07, blue: 0.12) // Deep Navy Night
    
    // Primary Theme Colors
    public static let primary = Color(red: 0.08, green: 0.46, blue: 0.98)
    public static let primaryGradient = LinearGradient(
        colors: [Color(red: 0.08, green: 0.46, blue: 0.98), Color(red: 0.00, green: 0.84, blue: 0.60)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let tradeAccent = Color(red: 0.00, green: 0.80, blue: 0.58) // Emerald Green
    public static let tradeGradient = LinearGradient(
        colors: [Color(red: 0.00, green: 0.80, blue: 0.58), Color(red: 0.02, green: 0.58, blue: 0.76)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let counterAccent = Color(red: 0.95, green: 0.30, blue: 0.55) // Neon Coral
    public static let counterGradient = LinearGradient(
        colors: [Color(red: 0.95, green: 0.30, blue: 0.55), Color(red: 0.98, green: 0.52, blue: 0.35)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let warningAccent = Color(red: 0.98, green: 0.64, blue: 0.05) // Amber
    public static let warningGradient = LinearGradient(
        colors: [Color(red: 0.98, green: 0.64, blue: 0.05), Color(red: 0.99, green: 0.78, blue: 0.20)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Backgrounds
    public static let background = Color(UIColor.systemGroupedBackground)
    public static let secondaryBackground = Color(UIColor.secondarySystemGroupedBackground)
    public static let cardBackground = Color(UIColor.secondarySystemBackground)
    
    // Corner Radii
    public static let cornerRadiusSmall: CGFloat = 8
    public static let cornerRadiusMedium: CGFloat = 14
    public static let cornerRadiusLarge: CGFloat = 22
    public static let cornerRadiusPill: CGFloat = 999
    
    // Haptics
    public static func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public static func triggerNotificationHaptic(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

// Custom Glass Card Modifier
public struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 18
    var padding: CGFloat = 16
    
    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}

public extension View {
    func glassCard(cornerRadius: CGFloat = 18, padding: CGFloat = 16) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, padding: padding))
    }
}

// Brand Logo Component
public struct XChangeBrandLogo: View {
    var size: CGFloat = 28
    var showText: Bool = true
    var isDarkBackground: Bool = false
    
    public init(size: CGFloat = 28, showText: Bool = true, isDarkBackground: Bool = false) {
        self.size = size
        self.showText = showText
        self.isDarkBackground = isDarkBackground
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            // Gradient Cross-Arrows Icon
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.32)
                    .fill(Color(red: 0.05, green: 0.07, blue: 0.12))
                    .frame(width: size * 1.25, height: size * 1.25)
                    .shadow(color: AppTheme.brandBlue.opacity(0.3), radius: 6, x: 0, y: 2)
                
                Image(systemName: "arrow.up.right.and.arrow.down.left")
                    .font(.system(size: size * 0.65, weight: .black))
                    .foregroundStyle(AppTheme.primaryGradient)
            }
            
            if showText {
                HStack(spacing: 0) {
                    Text("X")
                        .font(.system(size: size * 0.85, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.primaryGradient)
                    
                    Text("change")
                        .font(.system(size: size * 0.85, weight: .bold, design: .rounded))
                        .foregroundColor(isDarkBackground ? .white : .primary)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        XChangeBrandLogo(size: 36)
        XChangeBrandLogo(size: 32, isDarkBackground: true)
            .padding()
            .background(Color.black)
            .cornerRadius(12)
    }
    .padding()
}
