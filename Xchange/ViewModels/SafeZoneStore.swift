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
                name: "Mission Police Station Barter Lot",
                subtitle: "SFPD Safe Exchange Designated Area",
                address: "630 Valencia St, San Francisco, CA 94110",
                latitude: 37.7628,
                longitude: -122.4220,
                safetyRating: 5.0,
                isVerifiedByPolice: true,
                isCampusPartner: false,
                operatingHours: "24/7 Mon-Sun",
                amenities: ["Continuous Police Surveillance", "24/7 HD Recording Cameras", "Designated Marked Parking Stalls", "Well-Lit Night Exchange"],
                contactPhone: "+1 (415) 558-5400",
                systemIcon: "shield.checkered"
            ),
            SafeZone(
                name: "Central Subway Powell Station Mezzanine",
                subtitle: "Muni & BART Transit Security Zone",
                address: "Market & Powell St, San Francisco, CA 94102",
                latitude: 37.7844,
                longitude: -122.4080,
                safetyRating: 4.8,
                isVerifiedByPolice: true,
                isCampusPartner: false,
                operatingHours: "06:00 – 23:30 Mon-Sun",
                amenities: ["Transit Police Booth", "High Foot Traffic Area", "Wide-Angle CCTV", "Accessible concourse"],
                contactPhone: "+1 (415) 989-2278",
                systemIcon: "tram.fill"
            ),
            SafeZone(
                name: "Salesforce Transit Center Grand Hall",
                subtitle: "Security Monitored Public Plaza",
                address: "425 Mission St, San Francisco, CA 94105",
                latitude: 37.7897,
                longitude: -122.3969,
                safetyRating: 4.9,
                isVerifiedByPolice: false,
                isCampusPartner: false,
                operatingHours: "06:00 – 22:00 Mon-Sun",
                amenities: ["Private Building Security", "Indoor Climate-Controlled", "Free Public Seating", "Direct Transit Access"],
                contactPhone: "+1 (415) 597-5000",
                systemIcon: "building.2.crop.circle.fill"
            ),
            SafeZone(
                name: "UC Berkeley ASUC Student Union Safe Hub",
                subtitle: "Campus Safety & Trade Counter",
                address: "2495 Bancroft Way, Berkeley, CA 94720",
                latitude: 37.8693,
                longitude: -122.2590,
                safetyRating: 4.95,
                isVerifiedByPolice: true,
                isCampusPartner: true,
                operatingHours: "08:00 – 22:00 Daily",
                amenities: ["Student Union Info Desk", "UCPD Monitored", "Device Testing Station", "Secure Locker Access"],
                contactPhone: "+1 (510) 642-6000",
                systemIcon: "graduationcap.fill"
            )
        ]
    }
}
