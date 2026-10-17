//
//  Item.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//

import Foundation
import SwiftUI

public enum ItemCondition: String, Codable, CaseIterable, Identifiable {
    case brandNew = "Brand New"
    case likeNew = "Like New"
    case gentlyUsed = "Gently Used"
    case fair = "Fair Condition"
    case vintageSalvage = "Vintage / Salvage"
    
    public var id: String { rawValue }
    
    public var color: Color {
        switch self {
        case .brandNew: return .green
        case .likeNew: return .teal
        case .gentlyUsed: return .blue
        case .fair: return .orange
        case .vintageSalvage: return .purple
        }
    }
    
    public var iconName: String {
        switch self {
        case .brandNew: return "sparkles"
        case .likeNew: return "star.fill"
        case .gentlyUsed: return "hand.thumbsup.fill"
        case .fair: return "wrench.and.screwdriver.fill"
        case .vintageSalvage: return "clock.arrow.circlepath"
        }
    }
}

public enum ItemCategory: String, Codable, CaseIterable, Identifiable {
    case all = "All"
    case electronics = "Electronics"
    case gaming = "Gaming"
    case cameras = "Cameras & Optics"
    case fashion = "Fashion & Apparel"
    case musicalInstruments = "Musical Instruments"
    case collectibles = "Collectibles & Art"
    case vehicles = "Vehicles"
    case services = "Services"
    case homeGarden = "Home & Decor"
    case outdoorSports = "Sports & Outdoors"
    case booksMedia = "Books & Vinyl"
    
    public var id: String { rawValue }
    
    public var systemIcon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .electronics: return "laptopcomputer.and.iphone"
        case .gaming: return "gamecontroller.fill"
        case .cameras: return "camera.fill"
        case .fashion: return "tshirt.fill"
        case .musicalInstruments: return "guitars.fill"
        case .collectibles: return "shield.fill"
        case .vehicles: return "car.fill"
        case .services: return "wrench.and.screwdriver.fill"
        case .homeGarden: return "house.fill"
        case .outdoorSports: return "figure.hiking"
        case .booksMedia: return "books.vertical.fill"
        }
    }
    
    public var chipTitle: String {
        switch self {
        case .all: return "All"
        case .electronics: return "Electronics"
        case .vehicles: return "Vehicles"
        case .collectibles: return "Collectibles"
        case .services: return "Services"
        case .cameras: return "Cameras"
        case .musicalInstruments: return "Instruments"
        case .gaming: return "Gaming"
        case .fashion: return "Fashion"
        case .booksMedia: return "Books & Vinyl"
        case .outdoorSports: return "Outdoors"
        case .homeGarden: return "Home & Decor"
        }
    }
}

public enum ItemStatus: String, Codable, CaseIterable {
    case available = "Available"
    case inTradeNegotiation = "In Trade"
    case traded = "Traded"
    case archived = "Archived"
    
    public var color: Color {
        switch self {
        case .available: return .green
        case .inTradeNegotiation: return .orange
        case .traded: return .secondary
        case .archived: return .gray
        }
    }
}

public struct Item: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var description: String
    public var category: ItemCategory
    public var condition: ItemCondition
    public var estimatedValue: Double // Reference fair market value (LKR) to assist barter parity
    public var preferredTrades: String // What the owner wants in exchange
    public var images: [String] // Asset names or remote URLs
    public var ownerId: UUID
    public var ownerName: String
    public var ownerEmail: String
    public var ownerPhone: String
    public var ownerAvatar: String
    public var ownerRating: Double
    public var ownerLocation: String
    public var district: String?
    public var status: ItemStatus
    public var tags: [String]
    public var createdAt: Date
    public var isFavorite: Bool
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: ItemCategory,
        condition: ItemCondition,
        estimatedValue: Double,
        preferredTrades: String,
        images: [String],
        ownerId: UUID,
        ownerName: String,
        ownerEmail: String = "",
        ownerPhone: String = "",
        ownerAvatar: String = "person.crop.circle.fill",
        ownerRating: Double = 5.0,
        ownerLocation: String = "Colombo, Sri Lanka",
        district: String? = nil,
        status: ItemStatus = .available,
        tags: [String] = [],
        createdAt: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.condition = condition
        self.estimatedValue = estimatedValue
        self.preferredTrades = preferredTrades
        self.images = images
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.ownerEmail = ownerEmail
        self.ownerPhone = ownerPhone
        self.ownerAvatar = ownerAvatar
        self.ownerRating = ownerRating
        self.ownerLocation = ownerLocation
        self.district = district ?? SriLankaDistrict.detectDistrict(from: ownerLocation) ?? "Colombo"
        self.status = status
        self.tags = tags
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, category, condition, estimatedValue, preferredTrades
        case images, ownerId, ownerName, ownerEmail, ownerPhone, ownerAvatar, ownerRating, ownerLocation, district
        case status, tags, createdAt, isFavorite
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        category = try container.decode(ItemCategory.self, forKey: .category)
        condition = try container.decode(ItemCondition.self, forKey: .condition)
        estimatedValue = try container.decode(Double.self, forKey: .estimatedValue)
        preferredTrades = try container.decode(String.self, forKey: .preferredTrades)
        images = try container.decode([String].self, forKey: .images)
        ownerId = try container.decode(UUID.self, forKey: .ownerId)
        ownerName = try container.decode(String.self, forKey: .ownerName)
        ownerEmail = try container.decodeIfPresent(String.self, forKey: .ownerEmail) ?? ""
        ownerPhone = try container.decodeIfPresent(String.self, forKey: .ownerPhone) ?? ""
        ownerAvatar = try container.decodeIfPresent(String.self, forKey: .ownerAvatar) ?? "person.crop.circle.fill"
        ownerRating = try container.decodeIfPresent(Double.self, forKey: .ownerRating) ?? 5.0
        let loc = try container.decodeIfPresent(String.self, forKey: .ownerLocation) ?? "Colombo, Sri Lanka"
        ownerLocation = loc
        district = try container.decodeIfPresent(String.self, forKey: .district) ?? SriLankaDistrict.detectDistrict(from: loc) ?? "Colombo"
        status = try container.decodeIfPresent(ItemStatus.self, forKey: .status) ?? .available
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }
    
    /// Returns the resolved Sri Lankan district for this ad
    public var itemDistrict: String {
        if let d = district, !d.isEmpty {
            return d
        }
        return SriLankaDistrict.detectDistrict(from: ownerLocation) ?? "Colombo"
    }
    
    /// Evaluates if this listing belongs to the selected district filter
    public func matchesDistrict(_ selectedDistrict: SriLankaDistrict) -> Bool {
        if selectedDistrict == .all {
            return true
        }
        let target = selectedDistrict.rawValue.lowercased()
        if itemDistrict.lowercased() == target {
            return true
        }
        if ownerLocation.lowercased().contains(target) {
            return true
        }
        if let detected = SriLankaDistrict.detectDistrict(from: ownerLocation),
           detected.lowercased() == target {
            return true
        }
        return false
    }
    
    /// Checks if this item belongs to the specified user
    public func isOwnedBy(user: User) -> Bool {
        if self.ownerId == user.id {
            return true
        }
        if !self.ownerEmail.isEmpty && !user.email.isEmpty &&
            self.ownerEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == user.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            return true
        }
        if !self.ownerName.isEmpty && !user.displayName.isEmpty &&
            self.ownerName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == user.displayName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            return true
        }
        return false
    }
    
    public var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_LK")
        formatter.currencyCode = "LKR"
        formatter.currencySymbol = "LKR "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: estimatedValue)) ?? "LKR \(Int(estimatedValue))"
    }
}
