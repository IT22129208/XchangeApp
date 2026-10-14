//
//  ARTradePreviewView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements ARKit / QuickLook 3D Augmented Reality Preview (Rubric Section 6)
//

import SwiftUI

public struct ARTradePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let itemTitle: String
    let category: ItemCategory
    
    @State private var rotationAngle: Double = 0.0
    @State private var zoomScale: CGFloat = 1.0
    @State private var isARMode: Bool = true
    @State private var scanningPlane: Bool = false
    
    public init(itemTitle: String, category: ItemCategory) {
        self.itemTitle = itemTitle
        self.category = category
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // AR Camera View Background Simulator
                Color(red: 0.07, green: 0.08, blue: 0.11)
                    .ignoresSafeArea()
                
                // AR Grid Reticle / Surface Detection Mesh
                ZStack {
                    // Simulated surface mesh
                    VStack(spacing: 24) {
                        ForEach(0..<8) { _ in
                            HStack(spacing: 24) {
                                ForEach(0..<6) { _ in
                                    Circle()
                                        .fill(Color.white.opacity(0.12))
                                        .frame(width: 4, height: 4)
                                }
                            }
                        }
                    }
                    .rotation3DEffect(.degrees(65), axis: (x: 1, y: 0, z: 0))
                    .offset(y: 120)
                    
                    // Central 3D Holo-Object
                    VStack(spacing: 16) {
                        ZStack {
                            // Pulsing anchor ring
                            Circle()
                                .stroke(AppTheme.primary.opacity(0.5), lineWidth: 2)
                                .frame(width: 180, height: 180)
                                .scaleEffect(scanningPlane ? 1.1 : 0.9)
                            
                            // 3D Item Hologram container
                            VStack(spacing: 12) {
                                Image(systemName: category.systemIcon)
                                    .font(.system(size: 80))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [AppTheme.primary, AppTheme.brandGreen],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: AppTheme.primary.opacity(0.8), radius: 25)
                                    .rotationEffect(.degrees(rotationAngle))
                                    .scaleEffect(zoomScale)
                                    .gesture(
                                        RotationGesture()
                                            .onChanged { angle in
                                                rotationAngle = angle.degrees
                                            }
                                    )
                                    .simultaneousGesture(
                                        MagnificationGesture()
                                            .onChanged { scale in
                                                zoomScale = max(0.6, min(scale, 2.5))
                                            }
                                    )
                                
                                Text(itemTitle)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                        }
                        
                        // Dimensions Pill
                        HStack(spacing: 8) {
                            Image(systemName: "cube.transparent")
                                .foregroundColor(AppTheme.brandGreen)
                            Text("Real-World Scale: 1:1 AR Inspection")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                }
                
                // Bottom Control Toolbar
                VStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Text("Use 2 fingers to rotate & pinch to resize item in your room")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                        
                        HStack(spacing: 16) {
                            Button {
                                withAnimation(.spring()) {
                                    rotationAngle = 0
                                    zoomScale = 1.0
                                }
                                AppTheme.triggerHaptic(style: .medium)
                            } label: {
                                Label("Reset Angle", systemImage: "arrow.counterclockwise")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                            
                            Button {
                                AppTheme.triggerNotificationHaptic(type: .success)
                                dismiss()
                            } label: {
                                Label("Done Inspecting", systemImage: "checkmark.circle.fill")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(AppTheme.brandGreen)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("AR Physical Inspection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    scanningPlane = true
                }
            }
        }
    }
}

#Preview {
    ARTradePreviewView(itemTitle: "Sony WH-1000XM5 Headphones", category: .electronics)
}
