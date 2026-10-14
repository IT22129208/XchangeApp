//
//  SafeZone.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements MapKit Safe Exchange Zone Model (Rubric Section 6)
//

import Foundation
import CoreLocation

/// Model representing a verified Safe Barter Exchange Zone on Apple Maps
public struct SafeZone: Identifiable, Codable, Hashable {
    public let id: UUID
    public let name: String
    public let subtitle: String
    public let address: String
    public let latitude: Double
    public let longitude: Double
    public let safetyRating: Double // 1.0 - 5.0
    public let isVerifiedByPolice: Bool
    public let isCampusPartner: Bool
    public let operatingHours: String
    public let amenities: [String]
    public let contactPhone: String
    public let systemIcon: String
    
    public init(
        id: UUID = UUID(),
        name: String,
        subtitle: String,
        address: String,
        latitude: Double,
        longitude: Double,
        safetyRating: Double = 4.9,
        isVerifiedByPolice: Bool = false,
        isCampusPartner: Bool = false,
        operatingHours: String = "24/7 Mon-Sun",
        amenities: [String] = ["24/7 CCTV Surveillance", "Well-Lit Exchange Parking", "Security Desk on Duty", "Free Public Wi-Fi"],
        contactPhone: String = "+1 (415) 555-SAFE",
        systemIcon: String = "shield.checkered"
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.safetyRating = safetyRating
        self.isVerifiedByPolice = isVerifiedByPolice
        self.isCampusPartner = isCampusPartner
        self.operatingHours = operatingHours
        self.amenities = amenities
        self.contactPhone = contactPhone
        self.systemIcon = systemIcon
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public func distance(from userCoordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let loc1 = CLLocation(latitude: latitude, longitude: longitude)
        let loc2 = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        return loc1.distance(from: loc2)
    }
    
    public func formattedDistance(from userCoordinate: CLLocationCoordinate2D) -> String {
        let meters = distance(from: userCoordinate)
        let miles = meters / 1609.34
        if miles < 0.1 {
            return "< 0.1 mi away"
        } else {
            return String(format: "%.1f mi away", miles)
        }
    }
}
