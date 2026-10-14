//
//  SpatialItemInspectorView.swift
//  XchangeSpatial
//
//  Created for Xchange Spatial - VisionOS Prototype (Part B)
//  Implements 3D Spatial Holographic Item Inspection with Depth & Gestures
//

import SwiftUI

public struct SpatialItemInspectorView: View {
    @Environment(\.dismiss) private var dismiss
    let item: SpatialItem
    
    @State private var rotationY: Double = 0.0
    @State private var rotationX: Double = 0.0
    @State private var spatialScale: CGFloat = 1.0
    
    public init(item: SpatialItem) {
        self.item = item
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 3D Holographic Stage with Spatial Gestures
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.04))
                        .frame(height: 320)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1.5)
                        )
                    
                    VStack(spacing: 16) {
                        Image(systemName: item.systemIcon)
                            .font(.system(size: 96))
                            .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: .cyan.opacity(0.7), radius: 30)
                            .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
                            .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0))
                            .scaleEffect(spatialScale)
                            .gesture(
                                DragGesture()
                                    .onChanged { val in
                                        rotationY = Double(val.translation.width) * 0.4
                                        rotationX = Double(-val.translation.height) * 0.4
                                    }
                            )
                            .simultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { val in
                                        spatialScale = max(0.8, min(val, 2.2))
                                    }
                            )
                        
                        Text("Pinch & drag to rotate 360° spatial model")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Specifications & Wear Telemetry
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(item.title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Spacer()
                        Text("$\(Int(item.value)) USD")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.cyan)
                    }
                    
                    Text(item.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                    
                    HStack(spacing: 12) {
                        specPill(title: "Condition", value: item.condition, icon: "star.fill")
                        specPill(title: "Spatial Model", value: "USDZ / RealityKit", icon: "cube.fill")
                        specPill(title: "AI Certified", value: "100% Authentic", icon: "checkmark.seal.fill")
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.04))
                .cornerRadius(18)
                
                Spacer()
            }
            .padding(28)
            .navigationTitle("Spatial Hologram Inspector")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .glassBackgroundEffect()
    }
    
    private func specPill(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(.cyan)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 12, weight: .bold))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.06))
        .cornerRadius(10)
    }
}
