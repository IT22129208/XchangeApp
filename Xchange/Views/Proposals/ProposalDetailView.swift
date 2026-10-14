//
//  ProposalDetailView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Trade Negotiation Details with Interactive Barter Gauge & Safe Zone MapKit Integration
//

import SwiftUI

public struct ProposalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tradeStore: TradeProposalStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var safeZoneStore: SafeZoneStore
    
    let proposalId: UUID
    
    @State private var showCounterOfferSheet = false
    @State private var showChatView = false
    @State private var showAcceptAlert = false
    @State private var showDeclineAlert = false
    @State private var showCompleteAlert = false
    @State private var showSafeZonePicker = false
    @State private var showConfetti = false
    
    private var proposal: TradeProposal? {
        tradeStore.getProposal(byId: proposalId)
    }
    
    private var isIncoming: Bool {
        guard let p = proposal else { return false }
        return p.receiverId == userStore.currentUser.id
    }
    
    private var partnerName: String {
        guard let p = proposal else { return "" }
        return isIncoming ? p.initiatorName : p.receiverName
    }
    
    public var body: some View {
        ZStack {
            Group {
                if let p = proposal {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            // Status Card Banner
                            statusBanner(p)
                            
                            // Trade Items Comparison
                            tradeItemsSection(p)
                            
                            // Interactive Barter Parity Scale Gauge with DragGesture
                            InteractiveBarterScaleGauge(
                                offeredValue: p.totalOfferedValue,
                                requestedValue: p.totalRequestedValue,
                                isInteractive: true
                            )
                            
                            // Safe Meetup Zone Info with Apple Maps Integration
                            meetupLocationSection(p)
                            
                            // Counter-Offer History if multiple rounds
                            if !p.counterHistory.isEmpty {
                                counterHistorySection(p)
                            }
                            
                            // In-Trade Chat Teaser Card
                            chatTeaserCard(p)
                        }
                        .padding(20)
                        .padding(.bottom, 100)
                    }
                    .safeAreaInset(edge: .bottom) {
                        actionButtonsBar(p)
                    }
                } else {
                    Text("Trade proposal not found.")
                        .foregroundColor(.secondary)
                }
            }
            
            // Celebratory Confetti Burst
            if showConfetti {
                ConfettiView()
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Trade Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCounterOfferSheet) {
            if let p = proposal {
                CounterOfferModalView(proposal: p)
            }
        }
        .sheet(isPresented: $showSafeZonePicker) {
            SafeZoneMapView { zone in
                tradeStore.setMeetingLocation(proposalId: proposalId, location: "\(zone.name) (\(zone.subtitle))")
            }
        }
        .navigationDestination(isPresented: $showChatView) {
            if let p = proposal {
                TradeChatView(proposal: p)
            }
        }
        .alert("Accept Barter Deal?", isPresented: $showAcceptAlert) {
            Button("Confirm & Accept", role: .none) {
                if let p = proposal {
                    tradeStore.acceptProposal(proposalId: p.id)
                    withAnimation {
                        showConfetti = true
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("By accepting, you agree to exchange the selected items without cash. Both parties can coordinate the meetup location.")
        }
        .alert("Decline Proposal?", isPresented: $showDeclineAlert) {
            Button("Decline", role: .destructive) {
                if let p = proposal {
                    tradeStore.declineProposal(proposalId: p.id)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to decline this trade proposal?")
        }
        .alert("Complete Trade?", isPresented: $showCompleteAlert) {
            Button("Confirm Completed", role: .none) {
                if let p = proposal {
                    tradeStore.completeTrade(proposalId: p.id)
                    withAnimation {
                        showConfetti = true
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Confirm that physical items were inspected and handed over successfully at the safe zone.")
        }
    }
    
    // MARK: - Subviews
    
    private func statusBanner(_ p: TradeProposal) -> some View {
        HStack(spacing: 12) {
            Image(systemName: p.status.iconName)
                .font(.system(size: 24))
                .foregroundColor(p.status.badgeColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(p.status.rawValue)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(p.status.badgeColor)
                
                Text(statusSubtitle(for: p))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(14)
        .background(p.status.badgeColor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func statusSubtitle(for p: TradeProposal) -> String {
        switch p.status {
        case .pending:
            return isIncoming ? "Awaiting your decision or counter-offer" : "Awaiting response from \(p.receiverName)"
        case .countered:
            return "Active counter-offer proposal under review"
        case .accepted:
            return "Deal confirmed! Coordinate handoff at Safe Zone"
        case .declined:
            return "This proposal was declined"
        case .completed:
            return "Items exchanged and trade finalized"
        case .cancelled:
            return "Trade proposal cancelled"
        }
    }
    
    private func tradeItemsSection(_ p: TradeProposal) -> some View {
        VStack(spacing: 14) {
            // Offered Block
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(isIncoming ? "\(p.initiatorName.uppercased()) OFFERS" : "YOU OFFER")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Total: $\(Int(p.totalOfferedValue))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                }
                
                ForEach(p.offeredItems) { item in
                    itemRow(item: item, accentColor: AppTheme.primary)
                }
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Exchange Icon Divider
            HStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 1)
                
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.tradeAccent)
                
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 1)
            }
            
            // Requested Block
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(isIncoming ? "IN EXCHANGE FOR YOUR" : "\(p.receiverName.uppercased()) GIVES")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Total: $\(Int(p.totalRequestedValue))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.tradeAccent)
                }
                
                ForEach(p.requestedItems) { item in
                    itemRow(item: item, accentColor: AppTheme.tradeAccent)
                }
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private func itemRow(item: Item, accentColor: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.systemIcon)
                .font(.system(size: 18))
                .foregroundColor(accentColor)
                .frame(width: 36, height: 36)
                .background(accentColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(item.condition.rawValue)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(item.formattedValue)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(accentColor)
        }
    }
    
    private func meetupLocationSection(_ p: TradeProposal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "shield.checkered")
                        .foregroundColor(AppTheme.tradeAccent)
                    Text("Designated Safe Meetup Zone")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                
                Spacer()
                
                Button {
                    showSafeZonePicker = true
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "map.fill")
                        Text("Change on Map")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                }
            }
            
            HStack(spacing: 10) {
                SafeZoneRadarBadge(zoneName: p.meetingLocation ?? "SLIIT Safe Trade Hub", isVerified: true)
                Spacer()
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    private func counterHistorySection(_ p: TradeProposal) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(AppTheme.counterAccent)
                Text("Negotiation History (\(p.counterHistory.count) Rounds)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            
            ForEach(Array(p.counterHistory.enumerated()), id: \.offset) { index, counter in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Round \(index + 1): \(counter.proposedByName)")
                            .font(.system(size: 12, weight: .bold))
                        Spacer()
                        Text(counter.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    if !counter.note.isEmpty {
                        Text("\"\(counter.note)\"")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding(10)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private func chatTeaserCard(_ p: TradeProposal) -> some View {
        Button {
            showChatView = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("In-Trade Discussion")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Chat directly with \(partnerName) to clarify condition or meetup times")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func actionButtonsBar(_ p: TradeProposal) -> some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 10) {
                if p.status == .pending || p.status == .countered {
                    // Decline
                    Button {
                        showDeclineAlert = true
                    } label: {
                        Text("Decline")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    // Counter
                    Button {
                        showCounterOfferSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.2.squarepath")
                            Text("Counter")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.counterAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(AppTheme.counterAccent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    // Accept
                    Button {
                        showAcceptAlert = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                            Text("Accept")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(AppTheme.tradeGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                } else if p.status == .accepted {
                    Button {
                        showCompleteAlert = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Confirm Handoff & Complete Trade")
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.tradeGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                } else {
                    Text("Trade is \(p.status.rawValue.lowercased())")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    NavigationStack {
        ProposalDetailView(proposalId: TradeProposalStore.sampleIncomingProposalId)
            .environmentObject(TradeProposalStore())
            .environmentObject(UserStore())
            .environmentObject(ChatStore())
            .environmentObject(SafeZoneStore())
    }
}
