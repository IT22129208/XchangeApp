//
//  SpatialNegotiationRoomView.swift
//  XchangeSpatial
//
//  Created for Xchange Spatial - VisionOS Prototype (Part B)
//  Implements Shared Immersive Space for Collaborative Barter Negotiation
//

import SwiftUI

public struct SpatialNegotiationRoomView: View {
    @State private var tableRotation: Double = 0.0
    @State private var activeDealStatus: String = "Negotiating Terms (Round 2)"
    @State private var acceptedDeal: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 28) {
            // Immersive Table Header
            VStack(spacing: 6) {
                Text("Shared Spatial Barter Lounge")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                
                Text(activeDealStatus)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(acceptedDeal ? .green : .cyan)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(.top, 40)
            
            // 3D Spatial Trade Table Surface Simulation
            ZStack {
                // Tabletop Surface Disc
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 440, height: 440)
                    .overlay(
                        Circle().stroke(Color.cyan.opacity(0.4), lineWidth: 2)
                    )
                    .rotation3DEffect(.degrees(55), axis: (x: 1, y: 0, z: 0))
                
                // Trader A's Offered Hologram (User Side)
                VStack(spacing: 6) {
                    Image(systemName: "headphones")
                        .font(.system(size: 44))
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.8), radius: 15)
                    Text("Sony XM5 ($280)")
                        .font(.system(size: 12, weight: .bold))
                }
                .offset(y: 80)
                
                // Trader B's Offered Hologram (Partner Side)
                VStack(spacing: 6) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.teal)
                        .shadow(color: .teal.opacity(0.8), radius: 15)
                    Text("Fuji X-T30 II ($780)")
                        .font(.system(size: 12, weight: .bold))
                }
                .offset(y: -80)
                
                // Parity Meter Hologram in Center
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 72, height: 72)
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.cyan)
                }
            }
            .frame(height: 340)
            
            // Collaborative Trade Actions
            HStack(spacing: 24) {
                Button("Propose Counter-Offer") {
                    activeDealStatus = "Counter-Offer Sent via Spatial Audio"
                }
                .buttonStyle(.bordered)
                
                Button("Accept Spatial Deal") {
                    activeDealStatus = "🤝 Deal Confirmed! Both Parties Verified"
                    acceptedDeal = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.bottom, 40)
        }
        .padding(32)
        .glassBackgroundEffect()
    }
}

#Preview {
    SpatialNegotiationRoomView()
}
