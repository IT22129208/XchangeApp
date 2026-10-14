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
    public let id: UUID
    public var username: String
    public var displayName: String
    public var email: String
    public var bio: String
    public var avatar: String
    public var location: String
    public var rating: Double
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
        location: String = "San Francisco, CA",
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
        self.rating = rating
        self.tradesCompleted = tradesCompleted
        self.memberSince = memberSince
        self.isVerified = isVerified
        self.badges = badges
        self.wishlist = wishlist
        self.reviews = reviews
    }
}
