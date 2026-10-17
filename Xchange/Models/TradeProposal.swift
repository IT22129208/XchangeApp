//
//  TradeProposal.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//

import Foundation
import SwiftUI

public enum TradeStatus: String, Codable, CaseIterable {
    case pending = "Pending Review"
    case countered = "Counter-Offered"
    case accepted = "Deal Accepted"
    case declined = "Declined"
    case completed = "Trade Completed"
    case cancelled = "Cancelled"
    
    public var badgeColor: Color {
        switch self {
        case .pending: return .orange
        case .countered: return .purple
        case .accepted: return .green
        case .declined: return .red
        case .completed: return .blue
        case .cancelled: return .gray
        }
    }
    
    public var iconName: String {
        switch self {
        case .pending: return "clock.fill"
        case .countered: return "arrow.2.squarepath"
        case .accepted: return "checkmark.seal.fill"
        case .declined: return "xmark.circle.fill"
        case .completed: return "trophy.fill"
        case .cancelled: return "nosign"
        }
    }
}

public struct TradeCounterOffer: Identifiable, Codable, Hashable {
    public let id: UUID
    public let proposedByUserId: UUID
    public let proposedByName: String
    public let offeredItems: [Item]
    public let requestedItems: [Item]
    public let note: String
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        proposedByUserId: UUID,
        proposedByName: String,
        offeredItems: [Item],
        requestedItems: [Item],
        note: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.proposedByUserId = proposedByUserId
        self.proposedByName = proposedByName
        self.offeredItems = offeredItems
        self.requestedItems = requestedItems
        self.note = note
        self.timestamp = timestamp
    }
}

public struct TradeProposal: Identifiable, Codable, Hashable {
    public let id: UUID
    public var initiatorId: UUID
    public var initiatorName: String
    public var initiatorAvatar: String
    public var initiatorRating: Double
    public var initiatorEmail: String
    public var initiatorPhone: String
    public var initiatorDistrict: String?
    public var initiatorLocation: String?
    
    public var receiverId: UUID
    public var receiverName: String
    public var receiverAvatar: String
    public var receiverRating: Double
    public var receiverEmail: String
    public var receiverPhone: String
    public var receiverDistrict: String?
    public var receiverLocation: String?
    
    public var acceptedByUserId: UUID?
    public var acceptedByName: String?
    public var acceptedAt: Date?
    
    public var initiatorConfirmedCompletion: Bool
    public var receiverConfirmedCompletion: Bool
    
    public var offeredItems: [Item] // Items coming from initiator (or current active counter proposer)
    public var requestedItems: [Item] // Items coming from receiver
    public var note: String
    public var status: TradeStatus
    public var counterHistory: [TradeCounterOffer]
    public var meetingLocation: String?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        initiatorId: UUID,
        initiatorName: String,
        initiatorAvatar: String = "person.crop.circle.fill",
        initiatorRating: Double = 4.9,
        initiatorEmail: String = "",
        initiatorPhone: String = "",
        initiatorDistrict: String? = nil,
        initiatorLocation: String? = nil,
        receiverId: UUID,
        receiverName: String,
        receiverAvatar: String = "person.crop.circle.fill",
        receiverRating: Double = 4.8,
        receiverEmail: String = "",
        receiverPhone: String = "",
        receiverDistrict: String? = nil,
        receiverLocation: String? = nil,
        offeredItems: [Item],
        requestedItems: [Item],
        note: String = "",
        status: TradeStatus = .pending,
        counterHistory: [TradeCounterOffer] = [],
        meetingLocation: String? = "SLIIT Safe Barter Zone",
        acceptedByUserId: UUID? = nil,
        acceptedByName: String? = nil,
        acceptedAt: Date? = nil,
        initiatorConfirmedCompletion: Bool = false,
        receiverConfirmedCompletion: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.initiatorId = initiatorId
        self.initiatorName = initiatorName
        self.initiatorAvatar = initiatorAvatar
        self.initiatorRating = initiatorRating
        self.initiatorEmail = initiatorEmail
        self.initiatorPhone = initiatorPhone
        self.initiatorDistrict = initiatorDistrict
        self.initiatorLocation = initiatorLocation
        self.receiverId = receiverId
        self.receiverName = receiverName
        self.receiverAvatar = receiverAvatar
        self.receiverRating = receiverRating
        self.receiverEmail = receiverEmail
        self.receiverPhone = receiverPhone
        self.receiverDistrict = receiverDistrict
        self.receiverLocation = receiverLocation
        self.offeredItems = offeredItems
        self.requestedItems = requestedItems
        self.note = note
        self.status = status
        self.counterHistory = counterHistory
        self.meetingLocation = meetingLocation
        self.acceptedByUserId = acceptedByUserId
        self.acceptedByName = acceptedByName
        self.acceptedAt = acceptedAt
        self.initiatorConfirmedCompletion = initiatorConfirmedCompletion
        self.receiverConfirmedCompletion = receiverConfirmedCompletion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id, initiatorId, initiatorName, initiatorAvatar, initiatorRating, initiatorEmail, initiatorPhone, initiatorDistrict, initiatorLocation
        case receiverId, receiverName, receiverAvatar, receiverRating, receiverEmail, receiverPhone, receiverDistrict, receiverLocation
        case acceptedByUserId, acceptedByName, acceptedAt
        case initiatorConfirmedCompletion, receiverConfirmedCompletion
        case offeredItems, requestedItems, note, status, counterHistory, meetingLocation, createdAt, updatedAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        initiatorId = try container.decode(UUID.self, forKey: .initiatorId)
        initiatorName = try container.decode(String.self, forKey: .initiatorName)
        initiatorAvatar = try container.decodeIfPresent(String.self, forKey: .initiatorAvatar) ?? "person.crop.circle.fill"
        initiatorRating = try container.decodeIfPresent(Double.self, forKey: .initiatorRating) ?? 4.9
        initiatorEmail = try container.decodeIfPresent(String.self, forKey: .initiatorEmail) ?? ""
        initiatorPhone = try container.decodeIfPresent(String.self, forKey: .initiatorPhone) ?? ""
        initiatorDistrict = try container.decodeIfPresent(String.self, forKey: .initiatorDistrict)
        initiatorLocation = try container.decodeIfPresent(String.self, forKey: .initiatorLocation)
        
        receiverId = try container.decode(UUID.self, forKey: .receiverId)
        receiverName = try container.decode(String.self, forKey: .receiverName)
        receiverAvatar = try container.decodeIfPresent(String.self, forKey: .receiverAvatar) ?? "person.crop.circle.fill"
        receiverRating = try container.decodeIfPresent(Double.self, forKey: .receiverRating) ?? 4.8
        receiverEmail = try container.decodeIfPresent(String.self, forKey: .receiverEmail) ?? ""
        receiverPhone = try container.decodeIfPresent(String.self, forKey: .receiverPhone) ?? ""
        receiverDistrict = try container.decodeIfPresent(String.self, forKey: .receiverDistrict)
        receiverLocation = try container.decodeIfPresent(String.self, forKey: .receiverLocation)
        
        acceptedByUserId = try container.decodeIfPresent(UUID.self, forKey: .acceptedByUserId)
        acceptedByName = try container.decodeIfPresent(String.self, forKey: .acceptedByName)
        acceptedAt = try container.decodeIfPresent(Date.self, forKey: .acceptedAt)
        
        initiatorConfirmedCompletion = try container.decodeIfPresent(Bool.self, forKey: .initiatorConfirmedCompletion) ?? false
        receiverConfirmedCompletion = try container.decodeIfPresent(Bool.self, forKey: .receiverConfirmedCompletion) ?? false
        
        offeredItems = try container.decodeIfPresent([Item].self, forKey: .offeredItems) ?? []
        requestedItems = try container.decodeIfPresent([Item].self, forKey: .requestedItems) ?? []
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        status = try container.decodeIfPresent(TradeStatus.self, forKey: .status) ?? .pending
        counterHistory = try container.decodeIfPresent([TradeCounterOffer].self, forKey: .counterHistory) ?? []
        meetingLocation = try container.decodeIfPresent(String.self, forKey: .meetingLocation)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
    }
    
    /// Checks if a specific user has already pressed the complete button
    public func hasUserConfirmedCompletion(user: User) -> Bool {
        if isIncoming(for: user) {
            return receiverConfirmedCompletion
        } else if isOutgoing(for: user) {
            return initiatorConfirmedCompletion
        }
        return false
    }
    
    /// Checks if the partner trader has pressed the complete button
    public func hasPartnerConfirmedCompletion(user: User) -> Bool {
        if isIncoming(for: user) {
            return initiatorConfirmedCompletion
        } else if isOutgoing(for: user) {
            return receiverConfirmedCompletion
        }
        return false
    }
    
    /// Returns true only when BOTH the initiator and the receiver have pressed the complete button
    public var isFullyCompletedByBothUsers: Bool {
        initiatorConfirmedCompletion && receiverConfirmedCompletion
    }
    
    /// Completion confirmations count (0, 1, or 2)
    public var completionConfirmationCount: Int {
        (initiatorConfirmedCompletion ? 1 : 0) + (receiverConfirmedCompletion ? 1 : 0)
    }
    
    /// Checks if this proposal is incoming to the specified user
    public func isIncoming(for user: User) -> Bool {
        if receiverId == user.id { return true }
        if !receiverEmail.isEmpty && !user.email.isEmpty &&
            receiverEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == user.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            return true
        }
        if !receiverName.isEmpty && !user.displayName.isEmpty &&
            receiverName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == user.displayName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            return true
        }
        if requestedItems.contains(where: { $0.isOwnedBy(user: user) }) {
            return true
        }
        return false
    }
    
    /// Checks if this proposal was sent out by the specified user
    public func isOutgoing(for user: User) -> Bool {
        if initiatorId == user.id { return true }
        if !initiatorEmail.isEmpty && !user.email.isEmpty &&
            initiatorEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == user.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            return true
        }
        if !initiatorName.isEmpty && !user.displayName.isEmpty &&
            initiatorName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == user.displayName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            return true
        }
        if offeredItems.contains(where: { $0.isOwnedBy(user: user) }) {
            return true
        }
        return false
    }
    
    public var totalOfferedValue: Double {
        offeredItems.reduce(0) { $0 + $1.estimatedValue }
    }
    
    public var totalRequestedValue: Double {
        requestedItems.reduce(0) { $0 + $1.estimatedValue }
    }
    
    public var valueDifference: Double {
        totalOfferedValue - totalRequestedValue
    }
    
    public var fairnessScoreDescription: String {
        let diff = abs(valueDifference)
        let maxVal = max(totalOfferedValue, totalRequestedValue, 1.0)
        let percentageDiff = (diff / maxVal) * 100.0
        
        if percentageDiff <= 10 {
            return "Even Fair Trade ⚖️"
        } else if valueDifference > 0 {
            return "+\(Int(diff))$ In Receiver's Favor 🎁"
        } else {
            return "+\(Int(diff))$ In Proposer's Favor 🏷️"
        }
    }
    
    // MARK: - Accepted Trader & Contact Helpers
    
    public struct TraderContactInfo: Identifiable, Hashable {
        public var id: UUID
        public var name: String
        public var avatar: String
        public var rating: Double
        public var email: String
        public var phone: String
        public var district: String
        public var location: String
        public var isCurrentUser: Bool
        
        public init(
            id: UUID,
            name: String,
            avatar: String,
            rating: Double,
            email: String,
            phone: String,
            district: String,
            location: String,
            isCurrentUser: Bool
        ) {
            self.id = id
            self.name = name
            self.avatar = avatar
            self.rating = rating
            self.email = email
            self.phone = phone
            self.district = district
            self.location = location
            self.isCurrentUser = isCurrentUser
        }
    }
    
    /// Fallback resolver to guarantee valid phone numbers and emails for Sri Lankan community traders
    public static func fallbackPhone(for name: String, currentPhone: String = "") -> String {
        let clean = currentPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        if !clean.isEmpty { return clean }
        let lower = name.lowercased()
        if lower.contains("alex") { return "+94 77 234 5678" }
        if lower.contains("sophia") { return "+94 71 345 6789" }
        if lower.contains("marcus") { return "+94 75 456 7890" }
        if lower.contains("elena") { return "+94 72 567 8901" }
        if lower.contains("sashik") { return "+94 76 555 1234" }
        if lower.contains("test") { return "+94 77 123 4567" }
        return "+94 77 555 0199"
    }
    
    public static func fallbackEmail(for name: String, currentEmail: String = "") -> String {
        let clean = currentEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        if !clean.isEmpty { return clean }
        let lower = name.lowercased()
        if lower.contains("alex") { return "alex@xchange.app" }
        if lower.contains("sophia") { return "sophia@xchange.app" }
        if lower.contains("marcus") { return "marcus@xchange.app" }
        if lower.contains("elena") { return "elena@xchange.app" }
        if lower.contains("sashik") { return "sashik@sliit.ac.lk" }
        if lower.contains("test") { return "testuser1@xchange.lk" }
        let handle = lower.replacingOccurrences(of: " ", with: "_").filter { $0.isLetter || $0 == "_" }
        return "\(handle.isEmpty ? "trader" : handle)@xchange.app"
    }
    
    /// Resolves the trader who accepted this offer
    public func acceptedTrader(currentUser: User? = nil) -> TraderContactInfo {
        let isInitiatorAcceptor: Bool
        if let explicitId = acceptedByUserId {
            isInitiatorAcceptor = (explicitId == initiatorId)
        } else if let explicitName = acceptedByName {
            isInitiatorAcceptor = (explicitName.caseInsensitiveCompare(initiatorName) == .orderedSame)
        } else if let lastCounter = counterHistory.last {
            isInitiatorAcceptor = (lastCounter.proposedByUserId != initiatorId)
        } else {
            // In a standard offer, the receiver accepted the initiator's offer
            isInitiatorAcceptor = false
        }
        
        let id = isInitiatorAcceptor ? initiatorId : receiverId
        let name = acceptedByName ?? (isInitiatorAcceptor ? initiatorName : receiverName)
        let avatar = isInitiatorAcceptor ? initiatorAvatar : receiverAvatar
        let rating = isInitiatorAcceptor ? initiatorRating : receiverRating
        let email = Self.fallbackEmail(for: name, currentEmail: isInitiatorAcceptor ? initiatorEmail : receiverEmail)
        let phone = Self.fallbackPhone(for: name, currentPhone: isInitiatorAcceptor ? initiatorPhone : receiverPhone)
        let dist = (isInitiatorAcceptor ? initiatorDistrict : receiverDistrict) ?? SriLankaDistrict.detectDistrict(from: isInitiatorAcceptor ? (initiatorLocation ?? "") : (receiverLocation ?? "")) ?? "Colombo"
        let loc = (isInitiatorAcceptor ? initiatorLocation : receiverLocation) ?? "\(dist), Sri Lanka"
        let isCurrent = (currentUser != nil) && (id == currentUser?.id || name.caseInsensitiveCompare(currentUser?.displayName ?? "") == .orderedSame)
        
        return TraderContactInfo(
            id: id,
            name: name,
            avatar: avatar,
            rating: rating,
            email: email,
            phone: phone,
            district: dist,
            location: loc,
            isCurrentUser: isCurrent
        )
    }
    
    /// Resolves the trade partner contact details to coordinate meetup and exchange
    public func partnerContact(currentUser: User) -> TraderContactInfo {
        let currentIsInitiator = isOutgoing(for: currentUser)
        let id = currentIsInitiator ? receiverId : initiatorId
        let name = currentIsInitiator ? receiverName : initiatorName
        let avatar = currentIsInitiator ? receiverAvatar : initiatorAvatar
        let rating = currentIsInitiator ? receiverRating : initiatorRating
        let email = Self.fallbackEmail(for: name, currentEmail: currentIsInitiator ? receiverEmail : initiatorEmail)
        let phone = Self.fallbackPhone(for: name, currentPhone: currentIsInitiator ? receiverPhone : initiatorPhone)
        let dist = (currentIsInitiator ? receiverDistrict : initiatorDistrict) ?? SriLankaDistrict.detectDistrict(from: currentIsInitiator ? (receiverLocation ?? "") : (initiatorLocation ?? "")) ?? "Colombo"
        let loc = (currentIsInitiator ? receiverLocation : initiatorLocation) ?? "\(dist), Sri Lanka"
        
        return TraderContactInfo(
            id: id,
            name: name,
            avatar: avatar,
            rating: rating,
            email: email,
            phone: phone,
            district: dist,
            location: loc,
            isCurrentUser: false
        )
    }
}
