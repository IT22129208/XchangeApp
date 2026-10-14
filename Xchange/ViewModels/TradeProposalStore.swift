//
//  TradeProposalStore.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Trade Proposal Lifecycle with Robust Disk Persistence & Safe Zone Attachment
//

import Foundation
import SwiftUI
import Combine

@MainActor
public class TradeProposalStore: ObservableObject {
    @Published public var proposals: [TradeProposal] = []
    
    private let persistence = PersistenceService.shared
    
    public init() {
        loadProposals()
    }
    
    // MARK: - Persistence Integration
    
    private func saveProposals() {
        persistence.save(proposals, to: PersistenceService.FileKey.proposals)
    }
    
    private func loadProposals() {
        if let stored: [TradeProposal] = persistence.load([TradeProposal].self, from: PersistenceService.FileKey.proposals), !stored.isEmpty {
            self.proposals = stored
        } else {
            seedSampleProposals()
            saveProposals()
        }
    }
    
    // Incoming proposals sent to the current user (where current user is receiver and status is actionable)
    public func incomingProposals(for userId: UUID) -> [TradeProposal] {
        return proposals.filter { $0.receiverId == userId && ($0.status == .pending || $0.status == .countered) }
    }
    
    // Outgoing proposals sent by current user to others
    public func outgoingProposals(for userId: UUID) -> [TradeProposal] {
        return proposals.filter { $0.initiatorId == userId && ($0.status == .pending || $0.status == .countered) }
    }
    
    // Active agreed deals waiting for physical meetup / shipment
    public func activeDeals(for userId: UUID) -> [TradeProposal] {
        return proposals.filter { ($0.initiatorId == userId || $0.receiverId == userId) && $0.status == .accepted }
    }
    
    // Past completed or archived trades
    public func pastTrades(for userId: UUID) -> [TradeProposal] {
        return proposals.filter { ($0.initiatorId == userId || $0.receiverId == userId) && ($0.status == .completed || $0.status == .declined || $0.status == .cancelled) }
    }
    
    // Total pending badge count
    public func pendingCount(for userId: UUID) -> Int {
        return incomingProposals(for: userId).count
    }
    
    public func getProposal(byId id: UUID) -> TradeProposal? {
        proposals.first(where: { $0.id == id })
    }
    
    // MARK: - Trade Actions
    
    public func createProposal(
        initiator: User,
        receiverId: UUID,
        receiverName: String,
        receiverAvatar: String,
        receiverRating: Double,
        offeredItems: [Item],
        requestedItems: [Item],
        note: String,
        meetingLocation: String? = nil
    ) -> TradeProposal {
        let proposal = TradeProposal(
            initiatorId: initiator.id,
            initiatorName: initiator.displayName,
            initiatorAvatar: initiator.avatar,
            initiatorRating: initiator.rating,
            receiverId: receiverId,
            receiverName: receiverName,
            receiverAvatar: receiverAvatar,
            receiverRating: receiverRating,
            offeredItems: offeredItems,
            requestedItems: requestedItems,
            note: note,
            status: .pending,
            meetingLocation: meetingLocation ?? "SLIIT Computing Hub Safe Trade Booth"
        )
        
        proposals.insert(proposal, at: 0)
        saveProposals()
        AppTheme.triggerNotificationHaptic(type: .success)
        return proposal
    }
    
    public func acceptProposal(proposalId: UUID) {
        if let index = proposals.firstIndex(where: { $0.id == proposalId }) {
            proposals[index].status = .accepted
            proposals[index].updatedAt = Date()
            saveProposals()
            AppTheme.triggerNotificationHaptic(type: .success)
        }
    }
    
    public func declineProposal(proposalId: UUID) {
        if let index = proposals.firstIndex(where: { $0.id == proposalId }) {
            proposals[index].status = .declined
            proposals[index].updatedAt = Date()
            saveProposals()
            AppTheme.triggerNotificationHaptic(type: .warning)
        }
    }
    
    public func cancelProposal(proposalId: UUID) {
        if let index = proposals.firstIndex(where: { $0.id == proposalId }) {
            proposals[index].status = .cancelled
            proposals[index].updatedAt = Date()
            saveProposals()
            AppTheme.triggerHaptic(style: .medium)
        }
    }
    
    public func submitCounterOffer(
        proposalId: UUID,
        proposingUserId: UUID,
        proposingUserName: String,
        newOffered: [Item],
        newRequested: [Item],
        counterNote: String
    ) {
        if let index = proposals.firstIndex(where: { $0.id == proposalId }) {
            let counter = TradeCounterOffer(
                proposedByUserId: proposingUserId,
                proposedByName: proposingUserName,
                offeredItems: newOffered,
                requestedItems: newRequested,
                note: counterNote,
                timestamp: Date()
            )
            
            proposals[index].counterHistory.append(counter)
            proposals[index].offeredItems = newOffered
            proposals[index].requestedItems = newRequested
            proposals[index].note = counterNote
            proposals[index].status = .countered
            proposals[index].updatedAt = Date()
            saveProposals()
            AppTheme.triggerNotificationHaptic(type: .success)
        }
    }
    
    public func completeTrade(proposalId: UUID) {
        if let index = proposals.firstIndex(where: { $0.id == proposalId }) {
            proposals[index].status = .completed
            proposals[index].updatedAt = Date()
            saveProposals()
            AppTheme.triggerNotificationHaptic(type: .success)
        }
    }
    
    public func setMeetingLocation(proposalId: UUID, location: String) {
        if let index = proposals.firstIndex(where: { $0.id == proposalId }) {
            proposals[index].meetingLocation = location
            proposals[index].updatedAt = Date()
            saveProposals()
            AppTheme.triggerHaptic(style: .light)
        }
    }
    
    public func resetToDefaults() {
        seedSampleProposals()
        saveProposals()
    }
    
    public static let sampleIncomingProposalId = UUID(uuidString: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")!
    public static let sampleOutgoingProposalId = UUID(uuidString: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb")!
    public static let sampleActiveDealId = UUID(uuidString: "cccccccc-cccc-cccc-cccc-cccccccccccc")!

    // MARK: - Sample Seed Proposals
    private func seedSampleProposals() {
        let currentUserId = UserStore.currentUserId
        let alexId = UserStore.alexUserId
        let sophiaId = UserStore.sophiaUserId
        let marcusId = UserStore.marcusUserId
        
        // Item fixtures for proposals
        let myHeadphones = Item(
            title: "Sony WH-1000XM5 Noise-Cancelling Headphones",
            description: "Mint condition, used only in home office. Comes with original magnetic travel case.",
            category: .electronics,
            condition: .likeNew,
            estimatedValue: 280,
            preferredTrades: "Looking for mechanical keyboard or audio gear.",
            images: ["headphones_sony"],
            ownerId: currentUserId,
            ownerName: "Sashik M."
        )
        
        let myKeyboard = Item(
            title: "Custom 65% Mechanical Keyboard (Brass Plate)",
            description: "Custom built with Gateron Oil Kings, aluminum case with brass weight.",
            category: .electronics,
            condition: .gentlyUsed,
            estimatedValue: 210,
            preferredTrades: "Trade for Shure SM7B or Nintendo Switch.",
            images: ["keyboard_custom"],
            ownerId: currentUserId,
            ownerName: "Sashik M."
        )
        
        let alexFujiCamera = Item(
            title: "Fujifilm X-T30 II Mirrorless Camera (Silver)",
            description: "Gorgeous retro aesthetics with film simulations. Pristine sensor.",
            category: .cameras,
            condition: .likeNew,
            estimatedValue: 780,
            preferredTrades: "Looking to trade for headphones + gear.",
            images: ["camera_fuji"],
            ownerId: alexId,
            ownerName: "Alex Rivera"
        )
        
        let sophiaAnaloguePocket = Item(
            title: "Analogue Pocket Handheld Console (Black) + Dock",
            description: "Plays GB/GBC/GBA with FPGA hardware. Includes dock and controller.",
            category: .gaming,
            condition: .brandNew,
            estimatedValue: 360,
            preferredTrades: "Trade for DJ gear or ANC headphones.",
            images: ["console_analogue"],
            ownerId: sophiaId,
            ownerName: "Sophia Chen"
        )
        
        let marcusGarminWatch = Item(
            title: "Garmin Fenix 7 Sapphire Solar Multisport Watch",
            description: "Titanium bezel with sapphire crystal lens and solar charging.",
            category: .outdoorSports,
            condition: .gentlyUsed,
            estimatedValue: 520,
            preferredTrades: "Trade for GoPro or backpacking tent.",
            images: ["watch_garmin"],
            ownerId: marcusId,
            ownerName: "Marcus Vance"
        )
        
        // 1. Incoming proposal from Sophia Chen
        let incoming1 = TradeProposal(
            id: Self.sampleIncomingProposalId,
            initiatorId: sophiaId,
            initiatorName: "Sophia Chen",
            initiatorAvatar: "gamecontroller.circle.fill",
            initiatorRating: 5.0,
            receiverId: currentUserId,
            receiverName: "Sashik M.",
            receiverAvatar: "person.crop.circle.fill",
            receiverRating: 4.95,
            offeredItems: [sophiaAnaloguePocket],
            requestedItems: [myKeyboard],
            note: "Hey Sashik! I've been searching everywhere for a lubed custom board with brass plate. My Analogue Pocket is practically brand new in box with the TV dock. Let me know if this trade works!",
            status: .pending,
            counterHistory: [],
            meetingLocation: "SLIIT Computing Hub Safe Trade Booth",
            createdAt: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date()
        )
        
        // 2. Outgoing proposal from current user to Alex Rivera
        let outgoingWithCounter = TradeProposal(
            id: Self.sampleOutgoingProposalId,
            initiatorId: currentUserId,
            initiatorName: "Sashik M.",
            initiatorAvatar: "person.crop.circle.fill",
            initiatorRating: 4.95,
            receiverId: alexId,
            receiverName: "Alex Rivera",
            receiverAvatar: "camera.circle.fill",
            receiverRating: 4.88,
            offeredItems: [myHeadphones, myKeyboard],
            requestedItems: [alexFujiCamera],
            note: "Added both my Sony XM5 and the Custom 65% Keyboard to balance out the camera value!",
            status: .countered,
            counterHistory: [
                TradeCounterOffer(
                    proposedByUserId: currentUserId,
                    proposedByName: "Sashik M.",
                    offeredItems: [myHeadphones],
                    requestedItems: [alexFujiCamera],
                    note: "Initial proposal: Sony XM5 for Fuji X-T30 II.",
                    timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                ),
                TradeCounterOffer(
                    proposedByUserId: alexId,
                    proposedByName: "Alex Rivera",
                    offeredItems: [alexFujiCamera],
                    requestedItems: [myHeadphones, myKeyboard],
                    note: "Hey! The Fuji camera is valued around $780. If you can include your custom keyboard alongside the Sony XM5, we have an awesome deal!",
                    timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date()) ?? Date()
                )
            ],
            meetingLocation: "Mission Police Station Barter Lot (Safe Zone)",
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        )
        
        // 3. Active deal (Accepted, coordinating meetup)
        let activeDeal = TradeProposal(
            id: Self.sampleActiveDealId,
            initiatorId: marcusId,
            initiatorName: "Marcus Vance",
            initiatorAvatar: "figure.hiking.circle.fill",
            initiatorRating: 4.79,
            receiverId: currentUserId,
            receiverName: "Sashik M.",
            receiverAvatar: "person.crop.circle.fill",
            receiverRating: 4.95,
            offeredItems: [marcusGarminWatch],
            requestedItems: [myHeadphones],
            note: "Trade accepted! Let's meet up this Saturday morning at the Safe Hub.",
            status: .accepted,
            counterHistory: [],
            meetingLocation: "SLIIT Computing Hub Safe Trade Booth (Saturday 11 AM)",
            createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        )
        
        self.proposals = [incoming1, outgoingWithCounter, activeDeal]
    }
}
