//
//  CounterOfferModalView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//

import SwiftUI

public struct CounterOfferModalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var tradeStore: TradeProposalStore
    
    let proposal: TradeProposal
    
    @State private var counterOfferedItemIds: Set<UUID>
    @State private var counterRequestedItemIds: Set<UUID>
    @State private var counterNote: String = ""
    @State private var showSuccessAlert = false
    
    public init(proposal: TradeProposal) {
        self.proposal = proposal
        _counterOfferedItemIds = State(initialValue: Set(proposal.offeredItems.map { $0.id }))
        _counterRequestedItemIds = State(initialValue: Set(proposal.requestedItems.map { $0.id }))
    }
    
    private var myAvailableItems: [Item] {
        itemStore.userItems(for: userStore.currentUser)
    }
    
    private var partnerItems: [Item] {
        let partnerId = (proposal.receiverId == userStore.currentUser.id) ? proposal.initiatorId : proposal.receiverId
        return itemStore.userItems(for: partnerId)
    }
    
    private var activeOfferedItems: [Item] {
        itemStore.items.filter { counterOfferedItemIds.contains($0.id) }
    }
    
    private var activeRequestedItems: [Item] {
        itemStore.items.filter { counterRequestedItemIds.contains($0.id) }
    }
    
    private var offeredTotal: Double {
        activeOfferedItems.reduce(0) { $0 + $1.estimatedValue }
    }
    
    private var requestedTotal: Double {
        activeRequestedItems.reduce(0) { $0 + $1.estimatedValue }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Explanatory Banner
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.2.squarepath.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.counterAccent)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Make a Counter-Proposal")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                            Text("Adjust the items offered or requested to find fair terms.")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.counterAccent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Real-time Value Comparison
                    ValueBalanceBadge(
                        offeredValue: offeredTotal,
                        requestedValue: requestedTotal
                    )
                    
                    Divider()
                    
                    // Partner's Items Selection (Items you want)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ITEMS YOU WANT IN RETURN")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        ForEach(partnerItems.isEmpty ? proposal.requestedItems : partnerItems) { item in
                            let isSelected = counterRequestedItemIds.contains(item.id)
                            Button {
                                if isSelected && counterRequestedItemIds.count > 1 {
                                    counterRequestedItemIds.remove(item.id)
                                } else {
                                    counterRequestedItemIds.insert(item.id)
                                }
                                AppTheme.triggerHaptic(style: .light)
                            } label: {
                                itemRow(item: item, isSelected: isSelected, isUserItem: false)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Your Items Selection (Items you offer)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ITEMS YOU OFFER FROM YOUR CLOSET")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        ForEach(myAvailableItems.isEmpty ? proposal.offeredItems : myAvailableItems) { item in
                            let isSelected = counterOfferedItemIds.contains(item.id)
                            Button {
                                if isSelected && counterOfferedItemIds.count > 1 {
                                    counterOfferedItemIds.remove(item.id)
                                } else {
                                    counterOfferedItemIds.insert(item.id)
                                }
                                AppTheme.triggerHaptic(style: .light)
                            } label: {
                                itemRow(item: item, isSelected: isSelected, isUserItem: true)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Counter Note
                    VStack(alignment: .leading, spacing: 8) {
                        Text("COUNTER-OFFER REASONING / NOTE")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        TextField("e.g. Could you add the extra accessory or replace item X with item Y?", text: $counterNote, axis: .vertical)
                            .lineLimit(3...5)
                            .font(.system(size: 14))
                            .padding(12)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(20)
                .padding(.bottom, 80)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Counter-Offer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                counterSubmitBar
            }
            .alert("Counter-Offer Sent!", isPresented: $showSuccessAlert) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your counter-proposal has been submitted. The other trader will be notified immediately.")
            }
        }
    }
    
    // MARK: - Subviews & Helpers
    
    private func itemRow(item: Item, isSelected: Bool, isUserItem: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20))
                .foregroundColor(isSelected ? (isUserItem ? AppTheme.primary : AppTheme.tradeAccent) : .secondary)
            
            Image(systemName: item.category.systemIcon)
                .font(.system(size: 16))
                .foregroundColor(isUserItem ? AppTheme.primary : AppTheme.tradeAccent)
                .frame(width: 32, height: 32)
                .background((isUserItem ? AppTheme.primary : AppTheme.tradeAccent).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(item.condition.rawValue)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(item.formattedValue)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(isUserItem ? AppTheme.primary : AppTheme.tradeAccent)
        }
        .padding(12)
        .background(isSelected ? (isUserItem ? AppTheme.primary.opacity(0.08) : AppTheme.tradeAccent.opacity(0.08)) : Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? (isUserItem ? AppTheme.primary : AppTheme.tradeAccent) : Color.clear, lineWidth: 1.5)
        )
    }
    
    private var counterSubmitBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button {
                tradeStore.submitCounterOffer(
                    proposalId: proposal.id,
                    proposingUserId: userStore.currentUser.id,
                    proposingUserName: userStore.currentUser.displayName,
                    newOffered: activeOfferedItems,
                    newRequested: activeRequestedItems,
                    counterNote: counterNote.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                showSuccessAlert = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.system(size: 15, weight: .bold))
                    Text("Submit Counter-Offer")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.counterGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: AppTheme.counterAccent.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    let proposalStore = TradeProposalStore()
    let sampleProposal = proposalStore.proposals.first!
    return CounterOfferModalView(proposal: sampleProposal)
        .environmentObject(ItemStore())
        .environmentObject(UserStore())
        .environmentObject(proposalStore)
}
