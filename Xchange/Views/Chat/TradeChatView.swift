//
//  TradeChatView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//

import SwiftUI

public struct TradeChatView: View {
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var tradeStore: TradeProposalStore
    
    let proposal: TradeProposal
    
    @State private var messageInput: String = ""
    @State private var showCounterSheet = false
    
    private var isIncoming: Bool {
        proposal.receiverId == userStore.currentUser.id
    }
    
    private var partnerName: String {
        isIncoming ? proposal.initiatorName : proposal.receiverName
    }
    
    private var partnerAvatar: String {
        isIncoming ? proposal.initiatorAvatar : proposal.receiverAvatar
    }
    
    private var messages: [Message] {
        chatStore.messages(for: proposal.id)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Mini Proposal Sticky Bar
            miniProposalBanner
            
            // Chat Bubble List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // System Safe Trading Warning
                        systemWarningBadge
                        
                        ForEach(messages) { msg in
                            messageBubble(msg)
                                .id(msg.id)
                        }
                    }
                    .padding(16)
                }
                .onChange(of: messages.count) {
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Quick Suggestion Chips
            quickSuggestionBar
            
            // Bottom Message Input
            inputBar
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(partnerName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCounterSheet) {
            CounterOfferModalView(proposal: proposal)
        }
    }
    
    // MARK: - Subviews
    
    private var miniProposalBanner: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text("Trade: \(proposal.offeredItems.first?.title ?? "Item") ⇋ \(proposal.requestedItems.first?.title ?? "Item")")
                        .font(.system(size: 12, weight: .bold))
                        .lineLimit(1)
                }
                
                Text(proposal.status.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(proposal.status.badgeColor)
            }
            
            Spacer()
            
            Button {
                showCounterSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.2.squarepath")
                    Text("Counter")
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppTheme.counterAccent)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(AppTheme.counterAccent.opacity(0.12))
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .overlay(
            Rectangle()
                .fill(Color.primary.opacity(0.06))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var systemWarningBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "lock.shield.fill")
                .foregroundColor(AppTheme.tradeAccent)
            Text("Always arrange meetups in well-lit public safe exchange zones.")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .clipShape(Capsule())
        .padding(.bottom, 8)
    }
    
    private func messageBubble(_ msg: Message) -> some View {
        let isMe = msg.senderId == userStore.currentUser.id
        
        return HStack {
            if isMe { Spacer(minLength: 40) }
            
            VStack(alignment: isMe ? .trailing : .leading, spacing: 3) {
                Text(msg.text)
                    .font(.system(size: 14))
                    .foregroundColor(isMe ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isMe ? AppTheme.primary : Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(msg.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !isMe { Spacer(minLength: 40) }
        }
    }
    
    private var quickSuggestionBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                suggestionChip(text: "Where would you like to meet?")
                suggestionChip(text: "Is the condition still mint?")
                suggestionChip(text: "I can meet tomorrow afternoon!")
                suggestionChip(text: "Would you consider a counter-offer?")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }
    
    private func suggestionChip(text: String) -> some View {
        Button {
            messageInput = text
        } label: {
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.primary.opacity(0.08))
                .clipShape(Capsule())
        }
    }
    
    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Type your message...", text: $messageInput)
                .font(.system(size: 14))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
            
            Button {
                guard !messageInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                chatStore.sendMessage(
                    proposalId: proposal.id,
                    senderId: userStore.currentUser.id,
                    senderName: userStore.currentUser.displayName,
                    senderAvatar: userStore.currentUser.avatar,
                    text: messageInput.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                messageInput = ""
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(messageInput.isEmpty ? .secondary.opacity(0.5) : AppTheme.primary)
            }
            .disabled(messageInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    let proposalStore = TradeProposalStore()
    let sampleProposal = proposalStore.proposals.first!
    return NavigationStack {
        TradeChatView(proposal: sampleProposal)
            .environmentObject(ChatStore())
            .environmentObject(UserStore())
            .environmentObject(proposalStore)
    }
}
