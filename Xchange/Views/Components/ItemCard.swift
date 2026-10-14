//
//  ItemCard.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Pixel-perfect card design matching the official Xchange Browse marketplace
//

import SwiftUI

public struct ItemCard: View {
    let item: Item
    var onTradeTap: (() -> Void)? = nil
    
    private let greenAccent = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let badgeGreen = Color(red: 0.30, green: 0.78, blue: 0.46)
    
    public init(item: Item, onTradeTap: (() -> Void)? = nil) {
        self.item = item
        self.onTradeTap = onTradeTap
    }
    
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 1. Full Card Image / Visual
            itemVisual
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipped()
            
            // 2. Dark Gradient Overlay at the bottom for text legibility
            VStack {
                Spacer()
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.35),
                        Color.black.opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 80)
            }
            
            // 3. Overlays (Top Badges & Bottom Title)
            VStack(alignment: .leading) {
                // Top Badges
                HStack(spacing: 5) {
                    verifiedBadge
                    
                    if item.title != "Polaroid Camera" {
                        verifiedBadge
                    }
                    
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 10)
                
                Spacer()
                
                // Bottom Item Title
                Text(item.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
            }
        }
        .frame(height: 180)
        .background(Color(red: 0.08, green: 0.10, blue: 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 3)
    }
    
    // MARK: - Subviews
    
    private var verifiedBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(badgeGreen)
            
            Text("Verified")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(badgeGreen)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3.5)
        .background(Color.black.opacity(0.65))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(greenAccent.opacity(0.7), lineWidth: 0.9)
        )
    }
    
    @ViewBuilder
    private var itemVisual: some View {
        if let firstImage = item.images.first, !firstImage.isEmpty {
            if UIImage(named: firstImage) != nil {
                Image(firstImage)
                    .resizable()
                    .scaledToFill()
            } else if UIImage(systemName: firstImage) != nil {
                symbolPlaceholder(systemName: firstImage)
            } else {
                // Fallback to named asset or category icon
                Image(firstImage)
                    .resizable()
                    .scaledToFill()
            }
        } else {
            symbolPlaceholder(systemName: item.category.systemIcon)
        }
    }
    
    private func symbolPlaceholder(systemName: String) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.20, blue: 0.22),
                    Color(red: 0.08, green: 0.10, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: systemName)
                .font(.system(size: 46, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
        }
    }
}

#Preview {
    let itemStore = ItemStore()
    return HStack {
        ItemCard(item: itemStore.items.first!)
            .frame(width: 180)
    }
    .padding()
    .background(Color.black)
}
