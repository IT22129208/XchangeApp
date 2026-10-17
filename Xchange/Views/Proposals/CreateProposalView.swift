//
//  CreateProposalView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//

import SwiftUI

public struct CreateProposalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var tradeStore: TradeProposalStore
    
    let targetItem: Item
    
    @State private var selectedOfferedItemIds: Set<UUID> = []
    @State private var tradeNote: String = ""
    @State private var showSuccessAlert = false
    
    private var myAvailableItems: [Item] {
        itemStore.availableItemsToOffer(for: userStore.currentUser)
    }
    
    private var selectedOfferedItems: [Item] {
        myAvailableItems.filter { selectedOfferedItemIds.contains($0.id) }
    }
    
    private var totalOfferedValue: Double {
        selectedOfferedItems.reduce(0) { $0 + $1.estimatedValue }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Card: What You're Requesting
                    targetItemCard
                    
                    Divider()
                    
                    // Selection Section: Select Items from Your Closet to Offer
                    myItemsSelectionSection
                    
                    // Real-Time Value Balance Meter
                    if !selectedOfferedItems.isEmpty {
                        ValueBalanceBadge(
                            offeredValue: totalOfferedValue,
                            requestedValue: targetItem.estimatedValue
                        )
                    }
                    
                    // Pitch / Note to Trader
                    noteSection
                }
                .padding(20)
                .padding(.bottom, 80)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Propose Barter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                submitProposalBar
            }
            .alert("Proposal Sent!", isPresented: $showSuccessAlert) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your barter proposal has been sent to \(targetItem.ownerName). You'll be notified as soon as they respond or counter-offer!")
            }
        }
    }
    
    // MARK: - Subviews
    
    private var targetItemCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOU WANT TO RECEIVE")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.primary.opacity(0.12))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: targetItem.category.systemIcon)
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.primary)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(targetItem.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .lineLimit(2)
                    
                    HStack {
                        Text(targetItem.formattedValue)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.tradeAccent)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("Owner: \(targetItem.ownerName)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var myItemsSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("SELECT YOUR ITEMS TO OFFER")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(selectedOfferedItemIds.count) selected")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.primary)
            }
            
            if myAvailableItems.isEmpty {
                VStack(spacing: 8) {
                    Text("You don't have any available items listed yet.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("List an item in 'My Closet' tab first to offer it in trades.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                VStack(spacing: 8) {
                    ForEach(myAvailableItems) { item in
                        let isSelected = selectedOfferedItemIds.contains(item.id)
                        
                        Button {
                            if isSelected {
                                selectedOfferedItemIds.remove(item.id)
                            } else {
                                selectedOfferedItemIds.insert(item.id)
                            }
                            AppTheme.triggerHaptic(style: .light)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(isSelected ? AppTheme.primary : .secondary)
                                
                                Image(systemName: item.category.systemIcon)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.primary)
                                    .frame(width: 32, height: 32)
                                    .background(AppTheme.primary.opacity(0.1))
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
                                    .foregroundColor(AppTheme.primary)
                            }
                            .padding(12)
                            .background(isSelected ? AppTheme.primary.opacity(0.08) : Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isSelected ? AppTheme.primary : Color.clear, lineWidth: 1.5)
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PROPOSAL MESSAGE (OPTIONAL)")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.secondary)
            
            TextField("Add a friendly pitch, meetup location idea, or condition details...", text: $tradeNote, axis: .vertical)
                .lineLimit(3...5)
                .font(.system(size: 14))
                .padding(12)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    private var submitProposalBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button {
                _ = tradeStore.createProposal(
                    initiator: userStore.currentUser,
                    receiverId: targetItem.ownerId,
                    receiverName: targetItem.ownerName,
                    receiverAvatar: targetItem.ownerAvatar,
                    receiverRating: targetItem.ownerRating,
                    receiverEmail: targetItem.ownerEmail,
                    receiverPhone: targetItem.ownerPhone,
                    receiverDistrict: targetItem.district,
                    receiverLocation: targetItem.ownerLocation,
                    offeredItems: selectedOfferedItems,
                    requestedItems: [targetItem],
                    note: tradeNote.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                showSuccessAlert = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 15, weight: .bold))
                    Text("Send Trade Proposal")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(selectedOfferedItems.isEmpty ? Color.gray.opacity(0.4) : AppTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: selectedOfferedItems.isEmpty ? .clear : AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(selectedOfferedItems.isEmpty)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    let itemStore = ItemStore()
    let sampleTarget = itemStore.items.first(where: { $0.ownerId != UserStore.currentUserId })!
    return CreateProposalView(targetItem: sampleTarget)
        .environmentObject(itemStore)
        .environmentObject(UserStore())
        .environmentObject(TradeProposalStore())
}
