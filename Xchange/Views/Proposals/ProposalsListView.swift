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
    
    @State private var selectedTab: ProposalTab = .incoming
    @State private var selectedProposalForCounter: TradeProposal? = nil
    
    public enum ProposalTab: String, CaseIterable, Identifiable {
        case incoming = "Incoming"
        case outgoing = "Outgoing"
        case active = "Active Deals"
        case history = "History"
        
        public var id: String { rawValue }
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Segmented Picker
                segmentedBar
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
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
                                            tradeStore.acceptProposal(proposalId: proposal.id)
                                        },
                                        onDecline: {
                                            tradeStore.declineProposal(proposalId: proposal.id)
                                        },
                                        onCounter: {
                                            selectedProposalForCounter = proposal
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
            .onAppear {
                Task {
                    await tradeStore.fetchRemoteProposals()
                }
            }
        }
    }
    
    // MARK: - Helpers & Subviews
    
    private var proposalsForCurrentTab: [TradeProposal] {
        let user = userStore.currentUser
        switch selectedTab {
        case .incoming:
            return tradeStore.incomingProposals(for: user)
        case .outgoing:
            return tradeStore.outgoingProposals(for: user)
        case .active:
            return tradeStore.activeDeals(for: user)
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
                        
                        if tab == .incoming {
                            let count = tradeStore.pendingCount(for: userStore.currentUser)
                            if count > 0 {
                                Text("\(count)")
                                    .font(.system(size: 10, weight: .heavy))
                                    .foregroundColor(isSelected ? AppTheme.primary : .white)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(isSelected ? Color.white : AppTheme.primary)
                                    .clipShape(Capsule())
                            }
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
        case .incoming: return "tray"
        case .outgoing: return "paperplane"
        case .active: return "handshake"
        case .history: return "archivebox"
        }
    }
    
    private var emptyTitle: String {
        switch selectedTab {
        case .incoming: return "No Incoming Proposals"
        case .outgoing: return "No Outgoing Proposals"
        case .active: return "No Active Deals"
        case .history: return "No Past Trades"
        }
    }
    
    private var emptySubtitle: String {
        switch selectedTab {
        case .incoming: return "When other traders offer items for your closet, their proposals will appear here."
        case .outgoing: return "Browse the marketplace and propose trades for items you want to see them here."
        case .active: return "When you and a trade partner accept an agreement, you will coordinate meetup details here."
        case .history: return "Completed and archived trades will be safely logged here."
        }
    }
}

#Preview {
    ProposalsListView()
        .environmentObject(TradeProposalStore())
        .environmentObject(UserStore())
}
