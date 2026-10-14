//
//  SafeZoneRadarBadge.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Animated Radar Pulse Component for Verified Safe Meetup Zones (Rubric Section 2)
//

import SwiftUI

public struct SafeZoneRadarBadge: View {
    var zoneName: String = "SLIIT Safe Trade Booth"
    var isVerified: Bool = true
    
    @State private var pulseAnimation: Bool = false
    
    public init(zoneName: String = "SLIIT Safe Trade Booth", isVerified: Bool = true) {
        self.zoneName = zoneName
        self.isVerified = isVerified
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            // Animated Radar Beacon
            ZStack {
                Circle()
                    .stroke(AppTheme.tradeAccent.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 22, height: 22)
                    .scaleEffect(pulseAnimation ? 1.6 : 0.8)
                    .opacity(pulseAnimation ? 0 : 0.8)
                
                Circle()
                    .fill(AppTheme.tradeAccent)
                    .frame(width: 10, height: 10)
                    .shadow(color: AppTheme.tradeAccent.opacity(0.6), radius: 3)
            }
            .frame(width: 24, height: 24)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: 1.8)
                        .repeatForever(autoreverses: false)
                ) {
                    pulseAnimation = true
                }
            }
            
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text("VERIFIED SAFE ZONE")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .foregroundColor(AppTheme.tradeAccent)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.tradeAccent)
                }
                
                Text(zoneName)
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppTheme.tradeAccent.opacity(0.1))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AppTheme.tradeAccent.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    SafeZoneRadarBadge()
        .padding()
}
