//
//  XchangeLogoView.swift
//  Xchange
//
//  Created for Xchange - Official Brand Logo Component
//  Renders the exact 6-column blue & green hexagonal barter matrix logo with diagonal slash
//

import SwiftUI

public struct XchangeLogoView: View {
    var scale: CGFloat = 1.0
    var showText: Bool = true
    var isDarkBackground: Bool = false
    
    // Exact official brand colors extracted from reference design
    public static let brandBlue = Color(red: 0.12, green: 0.58, blue: 0.96) // Azure blue
    public static let brandGreen = Color(red: 0.24, green: 0.68, blue: 0.38) // Emerald green
    
    public init(scale: CGFloat = 1.0, showText: Bool = true, isDarkBackground: Bool = false) {
        self.scale = scale
        self.showText = showText
        self.isDarkBackground = isDarkBackground
    }
    
    public var body: some View {
        VStack(spacing: 14 * scale) {
            // Hexagonal Barter Matrix Emblem
            XchangeEmblemView(scale: scale)
            
            // Brand Wordmark: "Xchange"
            if showText {
                Text("Xchange")
                    .font(.system(size: 34 * scale, weight: .bold, design: .rounded))
                    .foregroundColor(isDarkBackground ? .white : .black)
                    .tracking(0.5)
            }
        }
    }
}

// MARK: - Official Hexagonal Barter Emblem Graphic

public struct XchangeEmblemView: View {
    var scale: CGFloat = 1.0
    
    public init(scale: CGFloat = 1.0) {
        self.scale = scale
    }
    
    public var body: some View {
        ZStack {
            // 6 Vertical Hexagonal Columns
            HStack(alignment: .center, spacing: 6.5 * scale) {
                // Column 1 (Outer Left)
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 3.5 * scale)
                        .fill(XchangeLogoView.brandBlue)
                        .frame(width: 8.5 * scale, height: 34 * scale)
                    Spacer().frame(height: 22 * scale)
                }
                
                // Column 2 (Mid Left)
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 3.5 * scale)
                        .fill(XchangeLogoView.brandBlue)
                        .frame(width: 8.5 * scale, height: 48 * scale)
                    Spacer().frame(height: 26 * scale)
                }
                
                // Column 3 (Center Left - High Blue Peak & Lower Tip)
                VStack(spacing: 18 * scale) {
                    RoundedRectangle(cornerRadius: 3.5 * scale)
                        .fill(XchangeLogoView.brandBlue)
                        .frame(width: 8.5 * scale, height: 50 * scale)
                    
                    RoundedRectangle(cornerRadius: 3.5 * scale)
                        .fill(XchangeLogoView.brandBlue)
                        .frame(width: 8.5 * scale, height: 14 * scale)
                }
                
                // Column 4 (Center Right - Upper Green Tip & Low Green Peak)
                VStack(spacing: 18 * scale) {
                    RoundedRectangle(cornerRadius: 3.5 * scale)
                        .fill(XchangeLogoView.brandGreen)
                        .frame(width: 8.5 * scale, height: 14 * scale)
                    
                    RoundedRectangle(cornerRadius: 3.5 * scale)
                        .fill(XchangeLogoView.brandGreen)
                        .frame(width: 8.5 * scale, height: 50 * scale)
                }
                
                // Column 5 (Mid Right)
                VStack(spacing: 0) {
                    Spacer().frame(height: 26 * scale)
                    RoundedRectangle(cornerRadius: 3.5 * scale)
                        .fill(XchangeLogoView.brandGreen)
                        .frame(width: 8.5 * scale, height: 48 * scale)
                }
                
                // Column 6 (Outer Right)
                VStack(spacing: 0) {
                    Spacer().frame(height: 22 * scale)
                    RoundedRectangle(cornerRadius: 3.5 * scale)
                        .fill(XchangeLogoView.brandGreen)
                        .frame(width: 8.5 * scale, height: 34 * scale)
                }
            }
            .frame(width: 86 * scale, height: 96 * scale)
            
            // Dynamic Green Slash (Sweeping from bottom-left to top-right at ~44 deg)
            Capsule()
                .fill(XchangeLogoView.brandGreen)
                .frame(width: 9.5 * scale, height: 98 * scale)
                .rotationEffect(.degrees(-44))
        }
        .frame(width: 92 * scale, height: 100 * scale)
    }
}

#Preview {
    VStack(spacing: 40) {
        XchangeLogoView()
        
        ZStack {
            Color.black
            XchangeLogoView(isDarkBackground: true)
        }
        .frame(height: 200)
    }
    .padding()
}
