//
//  Message.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//

import Foundation

public struct Message: Identifiable, Codable, Hashable {
    public let id: UUID
    public let proposalId: UUID
    public let senderId: UUID
    public let senderName: String
    public let senderAvatar: String
    public let text: String
    public let timestamp: Date
    public let isSystemNotification: Bool
    
    public init(
        id: UUID = UUID(),
        proposalId: UUID,
        senderId: UUID,
        senderName: String,
        senderAvatar: String = "person.crop.circle.fill",
        text: String,
        timestamp: Date = Date(),
        isSystemNotification: Bool = false
    ) {
        self.id = id
        self.proposalId = proposalId
        self.senderId = senderId
        self.senderName = senderName
        self.senderAvatar = senderAvatar
        self.text = text
        self.timestamp = timestamp
        self.isSystemNotification = isSystemNotification
    }
}
