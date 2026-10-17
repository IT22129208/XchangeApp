//
//  ProposalsListView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//

import SwiftUI

public struct ProposalsListView: View {
    @EnvironmentObject var tradeStore: TradeProposalStore
    @EnvironmentObject var userStore: UserStore
    
    @State private var selectedTab: ProposalTab = .active
    @State private var selectedProposalForCounter: TradeProposal? = nil
    @State private var proposalToComplete: TradeProposal? = nil
    @State private var showCompleteConfirmAlert: Bool = false
    @State private var showSuccessBanner: Bool = false
    @State private var completedPartnerName: String = ""
    
    public enum ProposalTab: String, CaseIterable, Identifiable {
        case active = "Active Deals"
        case incoming = "Incoming"
        case outgoing = "Outgoing"
        case history = "History"
        
        public var id: String { rawValue }
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Segmented Picker (Active Deals brought to front)
                segmentedBar
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                // Active Deals Quick Banner if browsing another tab while active deals exist
                if selectedTab != .active {
                    let activeDealsCount = tradeStore.activeDeals(for: userStore.currentUser).count
                    if activeDealsCount > 0 {
                        Button {
                            AppTheme.triggerHaptic(style: .medium)
                            selectedTab = .active
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.24, green: 0.65, blue: 0.38).opacity(0.18))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "handshake.fill")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(red: 0.24, green: 0.65, blue: 0.38))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text("Active Deals Ready")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Text("\(activeDealsCount) ACTIVE")
                                            .font(.system(size: 9, weight: .heavy))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color(red: 0.24, green: 0.65, blue: 0.38))
                                            .clipShape(Capsule())
                                    }
                                    
                                    Text("You have accepted trades waiting for meetup & barter exchange.")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(12)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color(red: 0.24, green: 0.65, blue: 0.38).opacity(0.4), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .padding(.bottom, 4)
                    }
                }
                
                // Success banner upon completing a trade
                if showSuccessBanner {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Barter Deal Completed! 🎉")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Trade with \(completedPartnerName) has been marked as complete and logged in History.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                showSuccessBanner = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.green.opacity(0.4), lineWidth: 1.2)
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Proposal List
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 14) {
                        let list = proposalsForCurrentTab
                        if list.isEmpty {
                            emptyView
                        } else {
                            ForEach(list) { proposal in
                                NavigationLink(destination: ProposalDetailView(proposalId: proposal.id)) {
                                    TradeCard(
                                        proposal: proposal,
                                        currentUser: userStore.currentUser,
                                        currentUserId: userStore.currentUser.id,
                                        onAccept: {
                                            tradeStore.acceptProposal(proposalId: proposal.id, acceptedBy: userStore.currentUser)
                                        },
                                        onDecline: {
                                            tradeStore.declineProposal(proposalId: proposal.id)
                                        },
                                        onCounter: {
                                            selectedProposalForCounter = proposal
                                        },
                                        onComplete: {
                                            proposalToComplete = proposal
                                            showCompleteConfirmAlert = true
                                        }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(16)
                }
                .refreshable {
                    await tradeStore.fetchRemoteProposals()
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Barter Trades")
            .sheet(item: $selectedProposalForCounter) { proposal in
                CounterOfferModalView(proposal: proposal)
            }
            .alert(completeAlertTitle, isPresented: $showCompleteConfirmAlert) {
                if let p = proposalToComplete {
                    let partner = p.isIncoming(for: userStore.currentUser) ? p.initiatorName : p.receiverName
                    let userConfirmed = p.hasUserConfirmedCompletion(user: userStore.currentUser)
                    let partnerConfirmed = p.hasPartnerConfirmedCompletion(user: userStore.currentUser)
                    
                    if userConfirmed {
                        Button("Simulate \(partner)'s Confirmation (Demo)") {
                            tradeStore.completeTrade(proposalId: p.id)
                            completedPartnerName = partner
                            withAnimation {
                                showSuccessBanner = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                withAnimation {
                                    showSuccessBanner = false
                                }
                            }
                        }
                        Button("OK, I'll Wait for Partner", role: .cancel) {
                            proposalToComplete = nil
                        }
                    } else {
                        Button(partnerConfirmed ? "Finalize Deal (2/2)" : "Confirm My Handoff (1/2)") {
                            completedPartnerName = partner
                            _ = tradeStore.confirmCompletion(proposalId: p.id, by: userStore.currentUser)
                            withAnimation {
                                showSuccessBanner = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                withAnimation {
                                    showSuccessBanner = false
                                }
                            }
                        }
                        
                        if !partnerConfirmed {
                            Button("Simulate Both Confirmed (Demo)") {
                                completedPartnerName = partner
                                tradeStore.completeTrade(proposalId: p.id)
                                withAnimation {
                                    showSuccessBanner = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                    withAnimation {
                                        showSuccessBanner = false
                                    }
                                }
                            }
                        }
                        
                        Button("Cancel", role: .cancel) {
                            proposalToComplete = nil
                        }
                    }
                }
            } message: {
                if let p = proposalToComplete {
                    let partner = p.isIncoming(for: userStore.currentUser) ? p.initiatorName : p.receiverName
                    let userConfirmed = p.hasUserConfirmedCompletion(user: userStore.currentUser)
                    let partnerConfirmed = p.hasPartnerConfirmedCompletion(user: userStore.currentUser)
                    
                    if userConfirmed {
                        Text("You have already confirmed your part (1/2). Both users must press the complete button for the trade to be completed. Waiting for \(partner) to confirm on their phone.")
                    } else if partnerConfirmed {
                        Text("\(partner) has already confirmed the handoff (1/2)! Tap Finalize Deal to confirm your side and complete the trade.")
                    } else {
                        Text("Confirm that you have safely met with \(partner) and exchanged your items. Both users must press the complete button for the trade to be completed.")
                    }
                } else {
                    Text("Both users must press the complete button for the trade to be completed.")
                }
            }
            .onAppear {
                Task {
                    await tradeStore.fetchRemoteProposals()
                }
            }
        }
    }
    
    // MARK: - Helpers & Subviews
    
    private var completeAlertTitle: String {
        guard let p = proposalToComplete else { return "Complete Deal" }
        let userConfirmed = p.hasUserConfirmedCompletion(user: userStore.currentUser)
        let partnerConfirmed = p.hasPartnerConfirmedCompletion(user: userStore.currentUser)
        if userConfirmed {
            return "Awaiting Partner Confirmation (1/2)"
        } else if partnerConfirmed {
            return "Partner Confirmed! Finalize Trade (2/2)"
        } else {
            return "Confirm Item Handoff (1/2)"
        }
    }
    
    private var proposalsForCurrentTab: [TradeProposal] {
        let user = userStore.currentUser
        switch selectedTab {
        case .active:
            return tradeStore.activeDeals(for: user)
        case .incoming:
            return tradeStore.incomingProposals(for: user)
        case .outgoing:
            return tradeStore.outgoingProposals(for: user)
        case .history:
            return tradeStore.pastTrades(for: user)
        }
    }
    
    private var segmentedBar: some View {
        HStack(spacing: 6) {
            ForEach(ProposalTab.allCases) { tab in
                let isSelected = selectedTab == tab
                Button {
                    selectedTab = tab
                    AppTheme.triggerHaptic(style: .light)
                } label: {
                    HStack(spacing: 4) {
                        Text(tab.rawValue)
                            .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        
                        let badgeCount: Int = {
                            switch tab {
                            case .active:
                                return tradeStore.activeDeals(for: userStore.currentUser).count
                            case .incoming:
                                return tradeStore.incomingProposals(for: userStore.currentUser).count
                            case .outgoing:
                                return tradeStore.outgoingProposals(for: userStore.currentUser).count
                            case .history:
                                return 0
                            }
                        }()
                        
                        if badgeCount > 0 {
                            Text("\(badgeCount)")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundColor(isSelected ? AppTheme.primary : .white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(
                                    isSelected
                                    ? Color.white
                                    : (tab == .active ? Color(red: 0.24, green: 0.65, blue: 0.38) : (tab == .incoming ? Color(red: 0.95, green: 0.28, blue: 0.28) : Color.gray))
                                )
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isSelected ? AppTheme.primary : Color(UIColor.secondarySystemGroupedBackground))
                    .foregroundColor(isSelected ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(4)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: emptyIcon)
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.7))
                .padding(.top, 40)
            
            Text(emptyTitle)
                .font(.system(size: 16, weight: .bold, design: .rounded))
            
            Text(emptySubtitle)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var emptyIcon: String {
        switch selectedTab {
        case .active: return "handshake.fill"
        case .incoming: return "tray"
        case .outgoing: return "paperplane"
        case .history: return "archivebox"
        }
    }
    
    private var emptyTitle: String {
        switch selectedTab {
        case .active: return "No Active Deals"
        case .incoming: return "No Incoming Proposals"
        case .outgoing: return "No Outgoing Proposals"
        case .history: return "No Past Trades"
        }
    }
    
    private var emptySubtitle: String {
        switch selectedTab {
        case .active: return "When you and a barter partner accept an agreement, you will coordinate meetup details, contacts, and exchange items here."
        case .incoming: return "When other traders offer items for your closet, their proposals will appear here."
        case .outgoing: return "Browse the marketplace and propose trades for items you want to see them here."
        case .history: return "Completed and archived trades will be safely logged here."
        }
    }
}

#Preview {
    ProposalsListView()
        .environmentObject(TradeProposalStore())
        .environmentObject(UserStore())
}
