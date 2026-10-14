//
//  VolumetricBarterScaleView.swift
//  XchangeSpatial
//
//  Created for Xchange Spatial - VisionOS Prototype (Part B)
//  Implements 3D Volumetric Dual-Pan Balance Scale in True 3D Physical Space
//

import SwiftUI

public struct VolumetricBarterScaleView: View {
    @State private var offeredWeight: Double = 350.0
    @State private var requestedWeight: Double = 350.0
    @State private var spatialZDepth: Double = 0.0
    @State private var isInteracting: Bool = false
    
    private var tiltDegrees: Double {
        let diff = offeredWeight - requestedWeight
        let maxVal = max(offeredWeight, requestedWeight, 1.0)
        return max(-20.0, min(20.0, (diff / maxVal) * 24.0))
    }
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 24) {
            // Volumetric Header
            VStack(spacing: 4) {
                Text("3D Volumetric Barter Scale")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                
                Text(abs(offeredWeight - requestedWeight) < 30 ? "⚖️ Perfect Spatial Parity" : (offeredWeight > requestedWeight ? "Leaning Left (Partner's Favor)" : "Leaning Right (Your Favor)"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(abs(offeredWeight - requestedWeight) < 30 ? .green : .cyan)
            }
            .padding(.top, 16)
            
            // Central 3D Volumetric Balance Rig
            ZStack {
                // Fulcrum Stand in 3D Space
                VStack(spacing: 0) {
                    Spacer()
                    // Triangular Brass Pivot
                    Capsule()
                        .fill(LinearGradient(colors: [.gray, .white.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 14, height: 160)
                    
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 90, height: 20)
                }
                .frame(height: 240)
                
                // 3D Tilting Balance Arm & Floating Pans
                HStack(alignment: .top, spacing: 0) {
                    // Left Spatial Pan (You Offer)
                    SpatialPan(
                        label: "You Offer",
                        value: offeredWeight,
                        color: .blue,
                        onAdd: { offeredWeight += 50 },
                        onMinus: { offeredWeight = max(50, offeredWeight - 50) }
                    )
                    
                    // Crossbar Arm
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [.blue, .cyan, .teal], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 260, height: 10)
                        .shadow(color: .cyan.opacity(0.5), radius: 8)
                    
                    // Right Spatial Pan (Partner Offers)
                    SpatialPan(
                        label: "They Offer",
                        value: requestedWeight,
                        color: .teal,
                        onAdd: { requestedWeight += 50 },
                        onMinus: { requestedWeight = max(50, requestedWeight - 50) }
                    )
                }
                .rotationEffect(.degrees(tiltDegrees), anchor: .center)
                .rotation3DEffect(.degrees(12), axis: (x: 1, y: 0, z: 0))
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: tiltDegrees)
            }
            .frame(height: 280)
            
            // Spatial Interactive Controls
            HStack(spacing: 20) {
                Button("Simulate Even Parity") {
                    offeredWeight = 500
                    requestedWeight = 500
                }
                .buttonStyle(.bordered)
                
                Button("Simulate Unbalanced Offer") {
                    offeredWeight = 780
                    requestedWeight = 280
                }
                .buttonStyle(.bordered)
            }
            .padding(.bottom, 20)
        }
        .padding(30)
        .glassBackgroundEffect()
    }
}

// MARK: - Spatial Pan Subview

private struct SpatialPan: View {
    let label: String
    let value: Double
    let color: Color
    var onAdd: () -> Void
    var onMinus: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            // Steel Wire Cable
            Rectangle()
                .fill(Color.white.opacity(0.4))
                .frame(width: 2, height: 50)
            
            // Spatial Pan Disc
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 110, height: 110)
                    .overlay(Circle().stroke(color, lineWidth: 2))
                    .shadow(color: color.opacity(0.4), radius: 10)
                
                VStack(spacing: 2) {
                    Text(label)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.secondary)
                    
                    Text("$\(Int(value))")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(color)
                    
                    HStack(spacing: 8) {
                        Button("+", action: onAdd)
                            .buttonStyle(.bordered)
                            .controlSize(.mini)
                        Button("-", action: onMinus)
                            .buttonStyle(.bordered)
                            .controlSize(.mini)
                    }
                }
            }
        }
        .frame(width: 120)
    }
}

#Preview {
    VolumetricBarterScaleView()
}
