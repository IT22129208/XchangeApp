//
//  SpatialMainView.swift
//  XchangeSpatial
//
//  Created for Xchange Spatial - VisionOS Prototype (Part B)
//  Implements Spatial Glassmorphism UI, Ornaments & Hover Effects
//

import SwiftUI

public struct SpatialMainView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var selectedCategory: String = "All"
    @State private var isImmersiveActive: Bool = false
    @State private var inspectedItem: SpatialItem? = nil
    
    private let categories = ["All", "Electronics", "Cameras", "Gaming", "Synthesizers", "Vintage"]
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            // Spatial Sidebar with Glassmorphic List
            List(categories, id: \.self, selection: $selectedCategory) { cat in
                HStack(spacing: 12) {
                    Image(systemName: iconForCategory(cat))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.cyan)
                    Text(cat)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Spatial XChange")
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Spatial Showroom Hero
                    heroBanner
                    
                    // 3D Spatial Grid
                    Text("Spatial Trade Items in Room")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 20)], spacing: 20) {
                        ForEach(SpatialItem.sampleItems) { item in
                            SpatialItemCard(item: item) {
                                inspectedItem = item
                            }
                        }
                    }
                }
                .padding(28)
            }
        }
        .glassBackgroundEffect()
        // VisionOS Bottom Spatial Ornament Toolbar
        .ornament(attachmentAnchor: .scene(.bottom)) {
            HStack(spacing: 20) {
                Button {
                    openWindow(id: "volumetric-scale")
                } label: {
                    Label("Launch 3D Volumetric Scale", systemImage: "scalemass.fill")
                        .font(.system(size: 14, weight: .bold))
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                
                Button {
                    Task {
                        if isImmersiveActive {
                            await dismissImmersiveSpace()
                            isImmersiveActive = false
                        } else {
                            await openImmersiveSpace(id: "immersive-negotiation-room")
                            isImmersiveActive = true
                        }
                    }
                } label: {
                    Label(isImmersiveActive ? "Exit Immersive Room" : "Enter Shared Spatial Room", systemImage: "person.2.badge.gearshape.fill")
                        .font(.system(size: 14, weight: .bold))
                }
                .buttonStyle(.bordered)
                .tint(.teal)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .glassBackgroundEffect()
        }
        .sheet(item: $inspectedItem) { item in
            SpatialItemInspectorView(item: item)
        }
    }
    
    private var heroBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("VISIONOS SPATIAL SHOWROOM")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.teal)
                
                Text("Inspect Physical Goods as 3D Spatial Holograms")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                
                Text("Pinch, rotate, and balance trades on a 3D dual-pan scale floating in your room.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "visionpro.and.arrow.forward.fill")
                .font(.system(size: 54))
                .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .padding(24)
        .background(Color.white.opacity(0.04))
        .cornerRadius(22)
    }
    
    private func iconForCategory(_ cat: String) -> String {
        switch cat {
        case "Electronics": return "laptopcomputer"
        case "Cameras": return "camera.fill"
        case "Gaming": return "gamecontroller.fill"
        case "Synthesizers": return "guitars.fill"
        case "Vintage": return "clock.arrow.circlepath"
        default: return "square.grid.2x2.fill"
        }
    }
}

// MARK: - Spatial Item Card with Hover Effect

public struct SpatialItemCard: View {
    let item: SpatialItem
    var onInspect: () -> Void
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 140)
                
                Image(systemName: item.systemIcon)
                    .font(.system(size: 52))
                    .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: .cyan.opacity(0.4), radius: 10)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .lineLimit(1)
                
                HStack {
                    Text("$\(Int(item.value)) USD")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.cyan)
                    
                    Spacer()
                    
                    Text(item.condition)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.teal.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            
            Button("Inspect 3D Hologram") {
                onInspect()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .frame(maxWidth: .infinity)
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .hoverEffect(.highlight)
    }
}

// MARK: - Spatial Domain Model Fixture

public struct SpatialItem: Identifiable, Hashable {
    public let id: UUID = UUID()
    public let title: String
    public let systemIcon: String
    public let value: Double
    public let condition: String
    public let description: String
    
    public static let sampleItems: [SpatialItem] = [
        SpatialItem(title: "Fujifilm X-T30 II Mirrorless", systemIcon: "camera.fill", value: 780, condition: "Like New", description: "Silver body with 35mm f/2 prime lens. Zero sensor dust."),
        SpatialItem(title: "Teenage Engineering OP-1 Field", systemIcon: "music.note.tv.fill", value: 1450, condition: "Mint", description: "Anodized aluminum body with spatial stereo sound synthesizer."),
        SpatialItem(title: "Analogue Pocket Handheld", systemIcon: "gamecontroller.fill", value: 310, condition: "Brand New", description: "FPGA hardware console playing GB/GBC cartridges."),
        SpatialItem(title: "Sony WH-1000XM5 Headphones", systemIcon: "headphones", value: 280, condition: "Like New", description: "Industry-leading ANC with spatial audio head-tracking.")
    ]
}
