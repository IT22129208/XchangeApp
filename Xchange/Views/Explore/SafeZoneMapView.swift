//
//  SafeZoneMapView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements MapKit Interactive Safe Barter Exchange Zones (Rubric Section 6)
//

import SwiftUI
import MapKit

public struct SafeZoneMapView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var safeZoneStore: SafeZoneStore
    @StateObject private var locationService = LocationService.shared
    
    var onSelectZone: ((SafeZone) -> Void)? = nil
    
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedZoneForSheet: SafeZone? = nil
    @State private var mapStyle: AppMapStyle = .standard
    
    enum AppMapStyle: String, CaseIterable {
        case standard = "Standard"
        case hybrid = "Satellite"
    }
    
    public init(onSelectZone: ((SafeZone) -> Void)? = nil) {
        self.onSelectZone = onSelectZone
    }
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Interactive Apple Maps MapKit View
                Map(position: $position, selection: $selectedZoneForSheet) {
                    // User's Location Marker
                    Annotation("Your Location", coordinate: locationService.userLocation) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primary.opacity(0.25))
                                .frame(width: 34, height: 34)
                            Circle()
                                .fill(AppTheme.primary)
                                .frame(width: 14, height: 14)
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 14, height: 14)
                        }
                    }
                    
                    // Verified Safe Zones Annotations
                    ForEach(safeZoneStore.filteredZones) { zone in
                        Annotation(zone.name, coordinate: zone.coordinate) {
                            SafeZoneMapAnnotation(
                                zone: zone,
                                isSelected: selectedZoneForSheet?.id == zone.id
                            )
                            .onTapGesture {
                                selectedZoneForSheet = zone
                                AppTheme.triggerHaptic(style: .medium)
                            }
                        }
                        .tag(zone)
                    }
                }
                .mapStyle(mapStyle == .standard ? .standard(elevation: .realistic) : .hybrid(elevation: .realistic))
                .ignoresSafeArea(edges: .bottom)
                
                // Bottom Overlay Card
                VStack(spacing: 12) {
                    // Map Style & Filter Chips
                    HStack {
                        // Campus Partner Filter
                        Toggle(isOn: $safeZoneStore.filterCampusOnly) {
                            Label("Campus", systemImage: "graduationcap.fill")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .toggleStyle(SafeZoneToggleStyle(activeColor: AppTheme.primary))
                        
                        // Police Verified Filter
                        Toggle(isOn: $safeZoneStore.filterPoliceVerifiedOnly) {
                            Label("Police Lot", systemImage: "shield.fill")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .toggleStyle(SafeZoneToggleStyle(activeColor: AppTheme.tradeAccent))
                        
                        Spacer()
                        
                        // Recenter on User
                        Button {
                            withAnimation {
                                position = .camera(
                                    MapCamera(
                                        centerCoordinate: locationService.userLocation,
                                        distance: 8000
                                    )
                                )
                            }
                            AppTheme.triggerHaptic(style: .light)
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.primary)
                                .frame(width: 36, height: 36)
                                .background(.ultraThickMaterial)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.12), radius: 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Selected Zone Details Banner
                    if let zone = selectedZoneForSheet ?? safeZoneStore.filteredZones.first {
                        SafeZoneDetailCard(
                            zone: zone,
                            userLocation: locationService.userLocation,
                            onChooseZone: {
                                safeZoneStore.selectZone(zone)
                                onSelectZone?(zone)
                                dismiss()
                            }
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Safe Exchange Zones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Picker("Style", selection: $mapStyle) {
                        ForEach(AppMapStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                }
            }
            .onAppear {
                locationService.requestLocationPermission()
                if let first = safeZoneStore.safeZones.first {
                    selectedZoneForSheet = first
                }
            }
        }
    }
}

// MARK: - Annotation View

private struct SafeZoneMapAnnotation: View {
    let zone: SafeZone
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(zone.isCampusPartner ? AppTheme.primary : AppTheme.tradeAccent)
                    .frame(width: isSelected ? 42 : 34, height: isSelected ? 42 : 34)
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
                
                Image(systemName: zone.systemIcon)
                    .font(.system(size: isSelected ? 18 : 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Pulsing Pointer triangle
            TriangleShape()
                .fill(zone.isCampusPartner ? AppTheme.primary : AppTheme.tradeAccent)
                .frame(width: 10, height: 6)
                .offset(y: -2)
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - Safe Zone Detail Card

private struct SafeZoneDetailCard: View {
    let zone: SafeZone
    let userLocation: CLLocationCoordinate2D
    var onChooseZone: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Name, Distance & Safety Score
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(zone.name)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .lineLimit(1)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.tradeAccent)
                    }
                    
                    Text(zone.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Distance badge
                HStack(spacing: 3) {
                    Image(systemName: "figure.walk")
                    Text(zone.formattedDistance(from: userLocation))
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppTheme.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.primary.opacity(0.12))
                .clipShape(Capsule())
            }
            
            Divider()
                .opacity(0.6)
            
            // Amenities Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(zone.amenities, id: \.self) { amenity in
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 9))
                                .foregroundColor(AppTheme.tradeAccent)
                            Text(amenity)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }
            
            // Address & Hours
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(zone.address)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(zone.operatingHours)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // Action Button: Select Safe Zone
                Button {
                    onChooseZone()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "location.north.circle.fill")
                        Text("Select Zone")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(AppTheme.primaryGradient)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Triangle Shape for Marker Pin

private struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Toggle Style for Filter Chips

private struct SafeZoneToggleStyle: ToggleStyle {
    let activeColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
            AppTheme.triggerHaptic(style: .light)
        } label: {
            configuration.label
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(configuration.isOn ? activeColor : Color(UIColor.secondarySystemBackground))
                .foregroundColor(configuration.isOn ? .white : .primary)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.08), radius: 3)
        }
    }
}

#Preview {
    SafeZoneMapView()
        .environmentObject(SafeZoneStore())
}
