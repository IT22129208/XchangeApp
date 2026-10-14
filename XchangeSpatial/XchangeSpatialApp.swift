//
//  XchangeSpatialApp.swift
//  XchangeSpatial
//
//  Created for Xchange Spatial - VisionOS Spatial Computing Prototype (Part B - 10% of Marks)
//  Implements Spatial Computing, Volumetric Windows & Immersive Spaces
//

import SwiftUI

@main
public struct XchangeSpatialApp: App {
    @State private var immersionState: ImmersionStyle = .mixed
    
    public init() {}
    
    public var body: some Scene {
        // Primary 2.5D Spatial Window
        WindowGroup(id: "main-showroom") {
            SpatialMainView()
        }
        .windowStyle(.plain)
        .defaultSize(width: 1050, height: 720)
        
        // Volumetric 3D Dual-Pan Barter Scale Stage
        WindowGroup(id: "volumetric-scale") {
            VolumetricBarterScaleView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)
        
        // Immersive Mixed Space for Collaborative Trade Table
        ImmersiveSpace(id: "immersive-negotiation-room") {
            SpatialNegotiationRoomView()
        }
        .immersionStyle(selection: $immersionState, in: .mixed)
    }
}
