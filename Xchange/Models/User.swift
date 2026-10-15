//
//  User.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//

import Foundation
import SwiftUI

public struct UserBadge: Identifiable, Codable, Hashable {
    public var id: String { title }
    public let title: String
    public let icon: String
    public let colorName: String
    
    public init(title: String, icon: String, colorName: String) {
        self.title = title
        self.icon = icon
        self.colorName = colorName
    }
}

public struct UserReview: Identifiable, Codable, Hashable {
    public let id: UUID
    public let reviewerName: String
    public let reviewerAvatar: String
    public let rating: Double
    public let comment: String
    public let tradedItemName: String
    public let date: Date
    
    public init(
        id: UUID = UUID(),
        reviewerName: String,
        reviewerAvatar: String,
        rating: Double,
        comment: String,
        tradedItemName: String,
        date: Date = Date()
    ) {
        self.id = id
        self.reviewerName = reviewerName
        self.reviewerAvatar = reviewerAvatar
        self.rating = rating
        self.comment = comment
        self.tradedItemName = tradedItemName
        self.date = date
    }
}

public struct User: Identifiable, Codable, Hashable {
    public var id: UUID
    public var username: String
    public var displayName: String
    public var email: String
    public var bio: String
    public var avatar: String
    public var location: String
    public var phoneNumber: String
    public var rating: Double
    
    /// Generates a consistent, deterministic UUID from any user identifier (email or Firebase UID)
    public static func deterministicId(for string: String) -> UUID {
        let clean = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !clean.isEmpty else { return UUID() }
        
        var hash1: UInt64 = 14695981039346656037
        var hash2: UInt64 = 1099511628211
        for byte in clean.utf8 {
            hash1 = (hash1 ^ UInt64(byte)) &* 1099511628211
            hash2 = (hash2 &* 14695981039346656037) ^ UInt64(byte)
        }
        
        let b0 = UInt8((hash1 >> 56) & 0xFF)
        let b1 = UInt8((hash1 >> 48) & 0xFF)
        let b2 = UInt8((hash1 >> 40) & 0xFF)
        let b3 = UInt8((hash1 >> 32) & 0xFF)
        let b4 = UInt8((hash1 >> 24) & 0xFF)
        let b5 = UInt8((hash1 >> 16) & 0xFF)
        let b6 = UInt8((hash1 >> 8) & 0xFF)
        let b7 = UInt8(hash1 & 0xFF)
        
        let b8 = UInt8((hash2 >> 56) & 0xFF)
        let b9 = UInt8((hash2 >> 48) & 0xFF)
        let b10 = UInt8((hash2 >> 40) & 0xFF)
        let b11 = UInt8((hash2 >> 32) & 0xFF)
        let b12 = UInt8((hash2 >> 24) & 0xFF)
        let b13 = UInt8((hash2 >> 16) & 0xFF)
        let b14 = UInt8((hash2 >> 8) & 0xFF)
        let b15 = UInt8(hash2 & 0xFF)
        
        return UUID(uuid: (b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15))
    }
    public var tradesCompleted: Int
    public var memberSince: String
    public var isVerified: Bool
    public var badges: [UserBadge]
    public var wishlist: [String]
    public var reviews: [UserReview]
    
    public init(
        id: UUID = UUID(),
        username: String,
        displayName: String,
        email: String,
        bio: String,
        avatar: String = "person.crop.circle.fill",
        location: String = "Colombo, Sri Lanka",
        phoneNumber: String = "+94 76 555 1234",
        rating: Double = 4.9,
        tradesCompleted: Int = 14,
        memberSince: String = "May 2024",
        isVerified: Bool = true,
        badges: [UserBadge] = [
            UserBadge(title: "Verified Trader", icon: "checkmark.seal.fill", colorName: "blue"),
            UserBadge(title: "Fast Shipper/Meeter", icon: "bolt.fill", colorName: "amber"),
            UserBadge(title: "Top Rated", icon: "star.fill", colorName: "yellow")
        ],
        wishlist: [String] = ["Analog Synthesizers", "Mechanical Keyboards", "Sony E-Mount Lenses", "Leather Goods"],
        reviews: [UserReview] = []
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.email = email
        self.bio = bio
        self.avatar = avatar
        self.location = location
        self.phoneNumber = phoneNumber
        self.rating = rating
        self.tradesCompleted = tradesCompleted
        self.memberSince = memberSince
        self.isVerified = isVerified
        self.badges = badges
        self.wishlist = wishlist
        self.reviews = reviews
    }
    
    enum CodingKeys: String, CodingKey {
        case id, username, displayName, email, bio, avatar, location, phoneNumber
        case rating, tradesCompleted, memberSince, isVerified, badges, wishlist, reviews
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        displayName = try container.decode(String.self, forKey: .displayName)
        email = try container.decode(String.self, forKey: .email)
        bio = try container.decode(String.self, forKey: .bio)
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar) ?? "person.crop.circle.fill"
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? "Colombo, Sri Lanka"
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber) ?? "+94 76 555 1234"
        rating = try container.decodeIfPresent(Double.self, forKey: .rating) ?? 4.9
        tradesCompleted = try container.decodeIfPresent(Int.self, forKey: .tradesCompleted) ?? 0
        memberSince = try container.decodeIfPresent(String.self, forKey: .memberSince) ?? "May 2024"
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified) ?? true
        badges = try container.decodeIfPresent([UserBadge].self, forKey: .badges) ?? []
        wishlist = try container.decodeIfPresent([String].self, forKey: .wishlist) ?? []
        reviews = try container.decodeIfPresent([UserReview].self, forKey: .reviews) ?? []
    }
}
