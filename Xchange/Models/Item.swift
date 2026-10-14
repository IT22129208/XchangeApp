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
    public var estimatedValue: Double // Reference fair market value (USD) to assist barter parity
    public var preferredTrades: String // What the owner wants in exchange (e.g. "Vintage mechanical keyboard or audio gear")
    public var images: [String] // Asset names or remote URLs
    public var ownerId: UUID
    public var ownerName: String
    public var ownerAvatar: String
    public var ownerRating: Double
    public var ownerLocation: String
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
        ownerAvatar: String = "person.crop.circle.fill",
        ownerRating: Double = 5.0,
        ownerLocation: String = "San Francisco, CA",
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
        self.ownerAvatar = ownerAvatar
        self.ownerRating = ownerRating
        self.ownerLocation = ownerLocation
        self.status = status
        self.tags = tags
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
    
    public var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: estimatedValue)) ?? "$\(Int(estimatedValue))"
    }
}
