//
//  SafeZoneStore.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Safe Exchange Zone ViewModel (Rubric Section 6)
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

/// ViewModel managing verified Safe Exchange Zones on Apple Maps
@MainActor
public final class SafeZoneStore: ObservableObject {
    @Published public var safeZones: [SafeZone] = []
    @Published public var selectedZone: SafeZone? = nil
    @Published public var filterCampusOnly: Bool = false
    @Published public var filterPoliceVerifiedOnly: Bool = false
    
    private let persistence = PersistenceService.shared
    
    public init() {
        loadSafeZones()
    }
    
    public var filteredZones: [SafeZone] {
        safeZones.filter { zone in
            if filterCampusOnly && !zone.isCampusPartner { return false }
            if filterPoliceVerifiedOnly && !zone.isVerifiedByPolice { return false }
            return true
        }
    }
    
    public func sortedByProximity(from coordinate: CLLocationCoordinate2D) -> [SafeZone] {
        filteredZones.sorted {
            $0.distance(from: coordinate) < $1.distance(from: coordinate)
        }
    }
    
    public func selectZone(_ zone: SafeZone) {
        self.selectedZone = zone
        AppTheme.triggerHaptic(style: .medium)
    }
    
    public func addCustomZone(_ zone: SafeZone) {
        safeZones.insert(zone, at: 0)
        saveSafeZones()
        AppTheme.triggerNotificationHaptic(type: .success)
    }
    
    // MARK: - Persistence
    
    private func saveSafeZones() {
        persistence.save(safeZones, to: PersistenceService.FileKey.safeZones)
    }
    
    private func loadSafeZones() {
        if let stored: [SafeZone] = persistence.load([SafeZone].self, from: PersistenceService.FileKey.safeZones), !stored.isEmpty {
            self.safeZones = stored
        } else {
            seedVerifiedSafeZones()
            saveSafeZones()
        }
    }
    
    private func seedVerifiedSafeZones() {
        self.safeZones = [
            SafeZone(
                name: "SLIIT Computing Hub Safe Trade Booth",
                subtitle: "Faculty of Computing, Malabe Campus",
                address: "New Kandy Rd, Malabe, Sri Lanka",
                latitude: 6.9147,
                longitude: 79.9729,
                safetyRating: 5.0,
                isVerifiedByPolice: true,
                isCampusPartner: true,
                operatingHours: "07:00 – 21:00 Mon-Sat",
                amenities: ["Campus Security Guard Station", "CCTV Monitored", "Power Outlet for Testing Devices", "High-Speed Wi-Fi"],
                contactPhone: "+94 11 754 4801",
                systemIcon: "graduationcap.fill"
            ),
            SafeZone(
                name: "Colombo Fort Police Safe Barter Lot",
                subtitle: "Sri Lanka Police Safe Barter Designated Zone",
                address: "Olcott Mawatha, Colombo 01, Sri Lanka",
                latitude: 6.9344,
                longitude: 79.8543,
                safetyRating: 5.0,
                isVerifiedByPolice: true,
                isCampusPartner: false,
                operatingHours: "24/7 Mon-Sun",
                amenities: ["Continuous Police Surveillance", "24/7 HD Recording Cameras", "Designated Marked Parking Stalls", "Well-Lit Night Exchange"],
                contactPhone: "+94 11 243 1424",
                systemIcon: "shield.checkered"
            ),
            SafeZone(
                name: "One Galle Face Mall Safe Concourse",
                subtitle: "Security Monitored Public Mall Concourse",
                address: "1A Centre Rd, Galle Face, Colombo 02, Sri Lanka",
                latitude: 6.9271,
                longitude: 79.8456,
                safetyRating: 4.9,
                isVerifiedByPolice: false,
                isCampusPartner: false,
                operatingHours: "10:00 – 22:00 Daily",
                amenities: ["Private Building Security", "Indoor Air-Conditioned", "Device Power Plugs", "High Foot Traffic"],
                contactPhone: "+94 11 777 5555",
                systemIcon: "building.2.crop.circle.fill"
            ),
            SafeZone(
                name: "Kandy City Centre Safe Exchange Point",
                subtitle: "Central Province Trade Safety Hub",
                address: "5 Dalada Veediya, Kandy, Sri Lanka",
                latitude: 7.2936,
                longitude: 80.6384,
                safetyRating: 4.85,
                isVerifiedByPolice: true,
                isCampusPartner: false,
                operatingHours: "08:30 – 21:00 Daily",
                amenities: ["Security Desk", "CCTV Monitored", "Convenient Seating Area", "Direct Transit Access"],
                contactPhone: "+94 81 220 5900",
                systemIcon: "tram.fill"
            ),
            SafeZone(
                name: "Galle Dutch Fort Tourist Police Barter Point",
                subtitle: "Southern Heritage Safe Trade Booth",
                address: "Church St, Galle Fort, Galle, Sri Lanka",
                latitude: 6.0300,
                longitude: 80.2170,
                safetyRating: 4.95,
                isVerifiedByPolice: true,
                isCampusPartner: false,
                operatingHours: "07:00 – 21:00 Mon-Sun",
                amenities: ["Tourist Police Monitored", "Well-Lit Historic Plaza", "Pedestrian-Only Area"],
                contactPhone: "+94 91 223 2222",
                systemIcon: "shield.checkered"
            ),
            SafeZone(
                name: "University of Moratuwa Safe Trade Center",
                subtitle: "Faculty of Engineering Tech Hub",
                address: "Bandaranayake Mawatha, Moratuwa, Sri Lanka",
                latitude: 6.7969,
                longitude: 79.9018,
                safetyRating: 4.9,
                isVerifiedByPolice: true,
                isCampusPartner: true,
                operatingHours: "08:00 – 20:00 Mon-Sat",
                amenities: ["Campus Security Monitored", "Electronics Testing Workbench", "Wi-Fi Access"],
                contactPhone: "+94 11 265 0301",
                systemIcon: "graduationcap.fill"
            )
        ]
    }
}
