//
//  UserStore.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements User Store with Local Disk Persistence
//

import Foundation
import SwiftUI
import Combine

@MainActor
public class UserStore: ObservableObject {
    @Published public var currentUser: User
    @Published public var allUsers: [User]
    
    private let persistence = PersistenceService.shared
    
    public static let currentUserId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    public static let alexUserId = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
    public static let sophiaUserId = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
    public static let marcusUserId = UUID(uuidString: "44444444-4444-4444-4444-444444444444")!
    public static let elenaUserId = UUID(uuidString: "55555555-5555-5555-5555-555555555555")!
    
    public init() {
        let initialUser = Self.createInitialCurrentUser()
        let initialUsers = Self.createCommunityUsers()
        
        var loadedUser: User
        if var stored: User = PersistenceService.shared.load(User.self, from: PersistenceService.FileKey.user) {
            if stored.displayName.isEmpty || stored.displayName == "Alex" || stored.displayName == "Alex Rivera" {
                stored.displayName = "Sashik Silva"
                stored.username = "sashik"
                PersistenceService.shared.save(stored, to: PersistenceService.FileKey.user)
            }
            loadedUser = stored
        } else {
            loadedUser = initialUser
            PersistenceService.shared.save(initialUser, to: PersistenceService.FileKey.user)
        }
        
        self.currentUser = loadedUser
        self.allUsers = initialUsers
    }
    
    public func saveCurrentUser() {
        persistence.save(currentUser, to: PersistenceService.FileKey.user)
    }
    
    public func updateProfile(displayName: String, bio: String, location: String) {
        updateProfile(displayName: displayName, bio: bio, location: location, email: nil, username: nil)
    }
    
    public func updateProfile(displayName: String, bio: String, location: String, email: String? = nil, username: String? = nil) {
        currentUser.displayName = displayName
        currentUser.bio = bio
        currentUser.location = location
        if let email = email, !email.isEmpty {
            currentUser.email = email
        }
        if let username = username, !username.isEmpty {
            currentUser.username = username
        }
        saveCurrentUser()
        AppTheme.triggerNotificationHaptic(type: .success)
    }
    
    public func updateProfilePhoto(_ image: UIImage) {
        let filename = "user_avatar_\(currentUser.id.uuidString).jpg"
        if persistence.saveImage(image, filename: filename) {
            currentUser.avatar = filename
            saveCurrentUser()
            AppTheme.triggerNotificationHaptic(type: .success)
        }
    }

    
    public func addWishlistItem(_ item: String) {
        let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        currentUser.wishlist.append(trimmed)
        saveCurrentUser()
        AppTheme.triggerHaptic(style: .light)
    }
    
    public func removeWishlistItem(at index: Int) {
        guard index >= 0 && index < currentUser.wishlist.count else { return }
        currentUser.wishlist.remove(at: index)
        saveCurrentUser()
    }
    
    public func addReview(reviewerName: String, rating: Double, comment: String, tradedItem: String) {
        let review = UserReview(
            reviewerName: reviewerName,
            reviewerAvatar: "person.crop.circle.badge.checkmark",
            rating: rating,
            comment: comment,
            tradedItemName: tradedItem,
            date: Date()
        )
        currentUser.reviews.insert(review, at: 0)
        currentUser.tradesCompleted += 1
        
        // Recalculate average rating
        let total = currentUser.reviews.reduce(0.0) { $0 + $1.rating }
        currentUser.rating = round((total / Double(currentUser.reviews.count)) * 100) / 100.0
        
        saveCurrentUser()
        AppTheme.triggerNotificationHaptic(type: .success)
    }
    
    public func resetToDefaults() {
        self.currentUser = Self.createInitialCurrentUser()
        saveCurrentUser()
    }
    
    // MARK: - Factory Initializers
    
    private static func createInitialCurrentUser() -> User {
        User(
            id: currentUserId,
            username: "sashik_madd",
            displayName: "Sashik Silva",
            email: "sashik@sliit.ac.lk",
            bio: "SLIIT Computing student & tech trader. Swapping audio gear, mechanical keyboards, camera primes, and retro games!",
            avatar: "person.crop.circle.fill",
            location: "Malabe, Colombo / SF Hub",
            rating: 4.95,
            tradesCompleted: 18,
            memberSince: "Jan 2024",
            isVerified: true,
            badges: [
                UserBadge(title: "Master Barterer", icon: "crown.fill", colorName: "yellow"),
                UserBadge(title: "SLIIT Campus Verified", icon: "graduationcap.fill", colorName: "blue"),
                UserBadge(title: "100% Reliable", icon: "shield.checkered", colorName: "green")
            ],
            wishlist: [
                "Fujifilm X-T4 or X-T30",
                "Keychron Q1 Pro Wireless",
                "Fender Stratocaster Neck",
                "Apple Vision Pro Accessories"
            ],
            reviews: [
                UserReview(
                    reviewerName: "Elena Rostova",
                    reviewerAvatar: "person.crop.circle.badge.checkmark",
                    rating: 5.0,
                    comment: "Super smooth trade! Custom keyboard was even cleaner than pictured. 10/10 trader!",
                    tradedItemName: "AirPods Max Space Gray",
                    date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
                ),
                UserReview(
                    reviewerName: "Alex Rivera",
                    reviewerAvatar: "person.crop.circle",
                    rating: 5.0,
                    comment: "Fair negotiation and great communication. Met in safe exchange zone right on time.",
                    tradedItemName: "Nintendo Switch OLED",
                    date: Calendar.current.date(byAdding: .day, value: -18, to: Date()) ?? Date()
                )
            ]
        )
    }
    
    private static func createCommunityUsers() -> [User] {
        let user2 = User(
            id: alexUserId,
            username: "alex_rivera",
            displayName: "Alex Rivera",
            email: "alex@xchange.app",
            bio: "Photographer and drone flyer. Always looking for prime lenses and studio gear.",
            avatar: "camera.circle.fill",
            location: "Oakland, CA",
            rating: 4.88,
            tradesCompleted: 24,
            memberSince: "Oct 2023",
            isVerified: true
        )
        
        let user3 = User(
            id: sophiaUserId,
            username: "sophia_chen",
            displayName: "Sophia Chen",
            email: "sophia@xchange.app",
            bio: "Retro gamer & analog synthesizer collector. Willing to trade rare cartridges & eurorack modules!",
            avatar: "gamecontroller.circle.fill",
            location: "San Jose, CA",
            rating: 5.0,
            tradesCompleted: 31,
            memberSince: "Aug 2023",
            isVerified: true
        )
        
        let user4 = User(
            id: marcusUserId,
            username: "marcus_v",
            displayName: "Marcus Vance",
            email: "marcus@xchange.app",
            bio: "Outdoor & hiking gear lover. Looking for lightweight tents, GPS watches, and trail bikes.",
            avatar: "figure.hiking.circle.fill",
            location: "Berkeley, CA",
            rating: 4.79,
            tradesCompleted: 12,
            memberSince: "Feb 2024",
            isVerified: true
        )
        
        let user5 = User(
            id: elenaUserId,
            username: "elena_r",
            displayName: "Elena Rostova",
            email: "elena@xchange.app",
            bio: "Audiophile and vintage sound technician. Restoring Japanese turntables and tube amps.",
            avatar: "music.note.tv.fill",
            location: "San Francisco, CA",
            rating: 4.92,
            tradesCompleted: 40,
            memberSince: "Nov 2022",
            isVerified: true
        )
        
        return [user2, user3, user4, user5]
    }
}
