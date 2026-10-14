//
//  ValueBalanceBadge.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//

import SwiftUI

public struct ValueBalanceBadge: View {
    let offeredValue: Double
    let requestedValue: Double
    var isCompact: Bool = false
    
    private var difference: Double {
        offeredValue - requestedValue
    }
    
    private var percentageDifference: Double {
        let maxVal = max(offeredValue, requestedValue, 1.0)
        return (abs(difference) / maxVal) * 100.0
    }
    
    private var isFair: Bool {
        percentageDifference <= 12.0
    }
    
    public var body: some View {
        if isCompact {
            compactView
        } else {
            fullView
        }
    }
    
    private var compactView: some View {
        HStack(spacing: 6) {
            Image(systemName: isFair ? "scalemass.fill" : (difference > 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill"))
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(badgeColor)
            
            Text(statusText)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(badgeColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(badgeColor.opacity(0.12))
        .clipShape(Capsule())
    }
    
    private var fullView: some View {
        VStack(spacing: 12) {
            // Header with badge
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "scalemass.fill")
                        .foregroundColor(badgeColor)
                    Text("Barter Valuation Meter")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                
                Spacer()
                
                Text(statusText)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(badgeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badgeColor.opacity(0.12))
                    .clipShape(Capsule())
            }
            
            // Value Comparison Bar
            VStack(spacing: 6) {
                GeometryReader { geo in
                    let total = max(offeredValue + requestedValue, 1.0)
                    let offeredRatio = max(min(offeredValue / total, 0.9), 0.1)
                    
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 10)
                        
                        // Split Bar
                        HStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(AppTheme.primaryGradient)
                                .frame(width: geo.size.width * CGFloat(offeredRatio), height: 10)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(AppTheme.tradeGradient)
                                .frame(width: geo.size.width * CGFloat(1.0 - offeredRatio), height: 10)
                        }
                    }
                }
                .frame(height: 10)
                
                // Labels below bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("You Give")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("$\(Int(offeredValue))")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.primary)
                    }
                    
                    Spacer()
                    
                    Text("VS")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("You Receive")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("$\(Int(requestedValue))")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.tradeAccent)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(badgeColor.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var badgeColor: Color {
        if isFair {
            return AppTheme.tradeAccent
        } else if difference > 0 {
            return AppTheme.primary
        } else {
            return AppTheme.counterAccent
        }
    }
    
    private var statusText: String {
        if isFair {
            return "Fair & Balanced Trade"
        } else if difference > 0 {
            return "+$\(Int(abs(difference))) in Partner's Favor"
        } else {
            return "+$\(Int(abs(difference))) in Your Favor"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ValueBalanceBadge(offeredValue: 280, requestedValue: 280)
        ValueBalanceBadge(offeredValue: 450, requestedValue: 280)
        ValueBalanceBadge(offeredValue: 200, requestedValue: 780)
        ValueBalanceBadge(offeredValue: 280, requestedValue: 280, isCompact: true)
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
