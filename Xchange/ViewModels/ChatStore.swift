//
//  ChatStore.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements In-Trade Chat Store with Robust Disk Persistence
//

import Foundation
import SwiftUI
import Combine

@MainActor
public class ChatStore: ObservableObject {
    @Published public var messages: [Message] = []
    
    private let persistence = PersistenceService.shared
    
    public init() {
        loadMessages()
    }
    
    // MARK: - Persistence Integration
    
    private func saveMessages() {
        persistence.save(messages, to: PersistenceService.FileKey.messages)
    }
    
    private func loadMessages() {
        if let stored: [Message] = persistence.load([Message].self, from: PersistenceService.FileKey.messages), !stored.isEmpty {
            self.messages = stored
        } else {
            seedSampleMessages()
            saveMessages()
        }
    }
    
    public func messages(for proposalId: UUID) -> [Message] {
        return messages.filter { $0.proposalId == proposalId }.sorted { $0.timestamp < $1.timestamp }
    }
    
    public func sendMessage(
        proposalId: UUID,
        senderId: UUID,
        senderName: String,
        senderAvatar: String,
        text: String
    ) {
        let newMsg = Message(
            proposalId: proposalId,
            senderId: senderId,
            senderName: senderName,
            senderAvatar: senderAvatar,
            text: text,
            timestamp: Date(),
            isSystemNotification: false
        )
        messages.append(newMsg)
        saveMessages()
        AppTheme.triggerHaptic(style: .light)
    }
    
    public func addSystemMessage(proposalId: UUID, text: String) {
        let newMsg = Message(
            proposalId: proposalId,
            senderId: UUID(),
            senderName: "XChange System",
            senderAvatar: "sparkles",
            text: text,
            timestamp: Date(),
            isSystemNotification: true
        )
        messages.append(newMsg)
        saveMessages()
    }
    
    public func resetToDefaults() {
        seedSampleMessages()
        saveMessages()
    }
    
    private func seedSampleMessages() {
        let currentUserId = UserStore.currentUserId
        let sophiaId = UserStore.sophiaUserId
        let alexId = UserStore.alexUserId
        
        let incomingId = TradeProposalStore.sampleIncomingProposalId
        let outgoingId = TradeProposalStore.sampleOutgoingProposalId
        let activeDealId = TradeProposalStore.sampleActiveDealId
        
        // 1. Chat for incoming proposal with Sophia
        let sophiaMsg1 = Message(
            proposalId: incomingId,
            senderId: sophiaId,
            senderName: "Sophia Chen",
            senderAvatar: "gamecontroller.circle.fill",
            text: "Hey Sashik! I saw your custom 65% keyboard listing. Does it come with the extra keycaps from the set?",
            timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date()
        )
        
        let currentMsg1 = Message(
            proposalId: incomingId,
            senderId: currentUserId,
            senderName: "Sashik M.",
            senderAvatar: "person.crop.circle.fill",
            text: "Hey Sophia! Yes, I have the entire base kit box with all novelty keys and mac/windows modifiers.",
            timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date()
        )
        
        let sophiaMsg2 = Message(
            proposalId: incomingId,
            senderId: sophiaId,
            senderName: "Sophia Chen",
            senderAvatar: "gamecontroller.circle.fill",
            text: "Awesome! I sent an official trade proposal offering my Analogue Pocket. Take a look and let me know what you think!",
            timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date()
        )
        
        // 2. Chat for outgoing counter-offer negotiation with Alex Rivera
        let alexMsg1 = Message(
            proposalId: outgoingId,
            senderId: currentUserId,
            senderName: "Sashik M.",
            senderAvatar: "person.crop.circle.fill",
            text: "Hi Alex, I love the Fuji X-T30 II. Would you trade it for my Sony WH-1000XM5 headphones?",
            timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        )
        
        let alexMsg2 = Message(
            proposalId: outgoingId,
            senderId: alexId,
            senderName: "Alex Rivera",
            senderAvatar: "camera.circle.fill",
            text: "Hey! The XM5s are sweet, but the Fuji value is higher. If you can include your custom keyboard with it, I'd be down to trade! I sent a counter-offer.",
            timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date()) ?? Date()
        )
        
        // 3. Active deal meetup coordination
        let activeMsg1 = Message(
            proposalId: activeDealId,
            senderId: currentUserId,
            senderName: "Sashik M.",
            senderAvatar: "person.crop.circle.fill",
            text: "Hey Marcus! Thanks for accepting the deal. Does the Safe Trade Booth work for you this Saturday around 11 AM?",
            timestamp: Calendar.current.date(byAdding: .hour, value: -12, to: Date()) ?? Date()
        )
        
        self.messages = [sophiaMsg1, currentMsg1, sophiaMsg2, alexMsg1, alexMsg2, activeMsg1]
    }
}
