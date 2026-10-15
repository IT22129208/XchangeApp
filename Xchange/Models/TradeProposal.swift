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
    
    public var receiverId: UUID
    public var receiverName: String
    public var receiverAvatar: String
    public var receiverRating: Double
    public var receiverEmail: String
    public var receiverPhone: String
    
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
        receiverId: UUID,
        receiverName: String,
        receiverAvatar: String = "person.crop.circle.fill",
        receiverRating: Double = 4.8,
        receiverEmail: String = "",
        receiverPhone: String = "",
        offeredItems: [Item],
        requestedItems: [Item],
        note: String = "",
        status: TradeStatus = .pending,
        counterHistory: [TradeCounterOffer] = [],
        meetingLocation: String? = "SLIIT Safe Barter Zone",
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
        self.receiverId = receiverId
        self.receiverName = receiverName
        self.receiverAvatar = receiverAvatar
        self.receiverRating = receiverRating
        self.receiverEmail = receiverEmail
        self.receiverPhone = receiverPhone
        self.offeredItems = offeredItems
        self.requestedItems = requestedItems
        self.note = note
        self.status = status
        self.counterHistory = counterHistory
        self.meetingLocation = meetingLocation
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id, initiatorId, initiatorName, initiatorAvatar, initiatorRating, initiatorEmail, initiatorPhone
        case receiverId, receiverName, receiverAvatar, receiverRating, receiverEmail, receiverPhone
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
        
        receiverId = try container.decode(UUID.self, forKey: .receiverId)
        receiverName = try container.decode(String.self, forKey: .receiverName)
        receiverAvatar = try container.decodeIfPresent(String.self, forKey: .receiverAvatar) ?? "person.crop.circle.fill"
        receiverRating = try container.decodeIfPresent(Double.self, forKey: .receiverRating) ?? 4.8
        receiverEmail = try container.decodeIfPresent(String.self, forKey: .receiverEmail) ?? ""
        receiverPhone = try container.decodeIfPresent(String.self, forKey: .receiverPhone) ?? ""
        
        offeredItems = try container.decodeIfPresent([Item].self, forKey: .offeredItems) ?? []
        requestedItems = try container.decodeIfPresent([Item].self, forKey: .requestedItems) ?? []
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        status = try container.decodeIfPresent(TradeStatus.self, forKey: .status) ?? .pending
        counterHistory = try container.decodeIfPresent([TradeCounterOffer].self, forKey: .counterHistory) ?? []
        meetingLocation = try container.decodeIfPresent(String.self, forKey: .meetingLocation)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
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
}
