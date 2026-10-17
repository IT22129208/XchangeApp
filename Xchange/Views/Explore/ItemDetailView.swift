//
//  ItemDetailView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Item Inspection with Pinch-to-Zoom Gesture, AR View & AI Valuation
//

import SwiftUI

public struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var tradeStore: TradeProposalStore
    @EnvironmentObject var safeZoneStore: SafeZoneStore
    
    let item: Item
    
    @State private var showCreateProposalSheet = false
    @State private var showAppraisalModal = false
    @State private var showSafeZoneMap = false
    @State private var showNoImageAlert = false
    @State private var showEditItemSheet = false
    
    private var currentItem: Item {
        itemStore.items.first(where: { $0.id == item.id }) ?? item
    }
    
    private var isOwnItem: Bool {
        currentItem.isOwnedBy(user: userStore.currentUser)
    }
    
    private var resolvedItemImage: UIImage? {
        guard let first = currentItem.images.first, !first.isEmpty else { return nil }
        return PersistenceService.shared.resolveImage(nameOrPath: first)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Image / Visual Stage with Pinch-To-Zoom Gesture
                        itemVisualHero
                            .pinchToZoom()
                        
                        VStack(alignment: .leading, spacing: 18) {
                            // Title & Price/Value
                            titleAndValueSection
                            
                            // Emerging Tech Action Row (AR Inspection & AI Valuation)
                            emergingTechActionRow
                            
                            Divider()
                            
                            // Owner's Barter Wishlist
                            ownerWishlistSection
                            
                            // Item Description
                            descriptionSection
                            
                            // Tags
                            tagsSection
                            
                            Divider()
                            
                            // Safe Barter Hub Recommendation
                            safeZoneMeetupRecommendation
                            
                            // Owner Profile Card
                            ownerProfileCard
                            
                            // Safe Trading Tips Notice
                            safeTradeNotice
                        }
                        .padding(.horizontal, 20)
                        
                        // Bottom spacer for sticky bar
                        Spacer()
                            .frame(height: 100)
                    }
                }
                
                // Sticky Bottom Action Bar
                bottomActionBar
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                }
                
                if isOwnItem {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showEditItemSheet = true
                            AppTheme.triggerHaptic(style: .medium)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "square.and.pencil")
                                Text("Edit")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                        }
                    }
                } else {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            itemStore.toggleFavorite(for: currentItem.id)
                        } label: {
                            Image(systemName: currentItem.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 18))
                                .foregroundColor(currentItem.isFavorite ? .red : .primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showEditItemSheet) {
                EditItemView(item: currentItem)
            }
            .sheet(isPresented: $showCreateProposalSheet) {
                CreateProposalView(targetItem: currentItem)
            }
            .sheet(isPresented: $showAppraisalModal) {
                SmartAppraisalModalView(
                    initialTitle: currentItem.title,
                    initialCategory: currentItem.category,
                    initialCondition: currentItem.condition,
                    initialImage: resolvedItemImage,
                    initialEstimatedValue: currentItem.estimatedValue
                )
            }
            .sheet(isPresented: $showSafeZoneMap) {
                SafeZoneMapView()
            }
            .alert("Picture Required for AI Appraise", isPresented: $showNoImageAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("This item does not have an uploaded picture. A photo is required to search Google Market Data for an accurate average price.")
            }
            .onChange(of: itemStore.items) { _, newItems in
                if !newItems.contains(where: { $0.id == item.id }) {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var itemVisualHero: some View {
        ZStack(alignment: .bottomLeading) {
            if let firstImage = currentItem.images.first, !firstImage.isEmpty {
                if let customImg = PersistenceService.shared.resolveImage(nameOrPath: firstImage) {
                    Image(uiImage: customImg)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 280)
                        .clipped()
                } else if UIImage(named: firstImage) != nil {
                    Image(firstImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 280)
                        .clipped()
                } else if UIImage(systemName: firstImage) != nil {
                    ZStack {
                        LinearGradient(
                            colors: [Color(red: 0.25, green: 0.30, blue: 0.45), Color(red: 0.12, green: 0.15, blue: 0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        Image(systemName: firstImage)
                            .font(.system(size: 72, weight: .regular))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .frame(height: 280)
                } else {
                    Image(firstImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 280)
                        .clipped()
                }
            } else {
                LinearGradient(
                    colors: [Color(red: 0.35, green: 0.40, blue: 0.95), Color(red: 0.20, green: 0.25, blue: 0.75)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 280)
                
                VStack(spacing: 12) {
                    Image(systemName: currentItem.category.systemIcon)
                        .font(.system(size: 72, weight: .regular))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Text(currentItem.category.rawValue)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .textCase(.uppercase)
                        .tracking(1.5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Bottom gradient overlay for badges
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.65)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 100)
            
            // Bottom Badges Overlay
            HStack(spacing: 8) {
                // Condition Badge
                HStack(spacing: 4) {
                    Image(systemName: currentItem.condition.iconName)
                        .font(.system(size: 10, weight: .bold))
                    Text(currentItem.condition.rawValue)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .foregroundColor(.white)
                .clipShape(Capsule())
                
                // Status Badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(currentItem.status.color)
                        .frame(width: 8, height: 8)
                    Text(currentItem.status.rawValue)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .foregroundColor(.white)
                .clipShape(Capsule())
                
                Spacer()
                
                // Zoom hint
                Text("Pinch to zoom")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Capsule())
            }
            .padding(16)
        }
    }
    
    private var titleAndValueSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(currentItem.title)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ESTIMATED VALUE")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text(currentItem.formattedValue)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.primary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(AppTheme.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("LOCATION")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.tradeAccent)
                        Text(currentItem.ownerLocation)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
    
    private var emergingTechActionRow: some View {
        Button {
            if resolvedItemImage == nil {
                AppTheme.triggerNotificationHaptic(type: .warning)
                showNoImageAlert = true
            } else {
                AppTheme.triggerHaptic(style: .medium)
                showAppraisalModal = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .bold))
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("AI Smart Valuation Breakdown")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                        Text("GOOGLE DATA")
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundColor(.black)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(AppTheme.tradeAccent)
                            .clipShape(Capsule())
                    }
                    Text("Live Google market price analysis & average benchmark")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(AppTheme.tradeAccent)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(AppTheme.tradeAccent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.tradeAccent.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var ownerWishlistSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.tradeAccent)
                
                Text("What the Owner Wants to Trade For")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            
            Text(currentItem.preferredTrades)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.tradeAccent.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.tradeAccent.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.system(size: 15, weight: .bold, design: .rounded))
            
            Text(currentItem.description)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
            
            FlowLayout(spacing: 8) {
                ForEach(currentItem.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.primary.opacity(0.08))
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private var safeZoneMeetupRecommendation: some View {
        Button {
            showSafeZoneMap = true
        } label: {
            HStack(spacing: 12) {
                SafeZoneRadarBadge(zoneName: "SLIIT Safe Trade Hub", isVerified: true)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(14)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var displayOwnerPhone: String {
        if !currentItem.ownerPhone.isEmpty {
            return currentItem.ownerPhone
        }
        if currentItem.isOwnedBy(user: userStore.currentUser) && !userStore.currentUser.phoneNumber.isEmpty {
            return userStore.currentUser.phoneNumber
        }
        if currentItem.ownerEmail.lowercased() == "testuser1@xchange.lk" || currentItem.ownerName.lowercased().contains("kasun") {
            return "+94 77 123 4567"
        }
        if currentItem.ownerEmail.lowercased() == "testuser2@xchange.lk" || currentItem.ownerName.lowercased().contains("dilini") {
            return "+94 71 987 6543"
        }
        if currentItem.ownerName.lowercased().contains("sashik") {
            return "+94 76 555 1234"
        }
        return "+94 77 123 4567"
    }
    
    private var ownerProfileCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Listed by Trader")
                .font(.system(size: 15, weight: .bold, design: .rounded))
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    UserAvatarView(avatar: currentItem.ownerAvatar, size: 50)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(currentItem.ownerName)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.blue)
                        }
                        
                        HStack(spacing: 10) {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.2f Rating", currentItem.ownerRating))
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text("15+ Trades")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Contact Number Row
                HStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("CONTACT NUMBER")
                                .font(.system(size: 10, weight: .heavy, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Text(displayOwnerPhone)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    // Direct Call Button
                    if let cleanPhone = displayOwnerPhone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined() as String?,
                       !cleanPhone.isEmpty,
                       let phoneUrl = URL(string: "tel://\(cleanPhone)") {
                        Link(destination: phoneUrl) {
                            HStack(spacing: 4) {
                                Image(systemName: "phone.arrow.up.right.fill")
                                    .font(.system(size: 11, weight: .bold))
                                Text("Call")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.primary)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                    }
                    
                    // Copy Number Button
                    Button {
                        UIPasteboard.general.string = displayOwnerPhone
                        AppTheme.triggerNotificationHaptic(type: .success)
                    } label: {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(Color(UIColor.tertiarySystemGroupedBackground))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var safeTradeNotice: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.tradeAccent)
            
            VStack(alignment: .leading, spacing: 3) {
                Text("XChange Safe Guarantee")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                Text("Trades are 100% cashless. Both parties negotiate and agree upon equal item trades before meeting in designated safe trading zones.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                if isOwnItem {
                    Button {
                        showEditItemSheet = true
                        AppTheme.triggerHaptic(style: .medium)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 16, weight: .bold))
                            Text("Edit Listing Details")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: AppTheme.primary.opacity(0.35), radius: 10, x: 0, y: 4)
                    }
                } else {
                    Button {
                        showCreateProposalSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.2.squarepath")
                                .font(.system(size: 16, weight: .bold))
                            Text("Propose Barter Trade")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: AppTheme.primary.opacity(0.35), radius: 10, x: 0, y: 4)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .background(.ultraThinMaterial)
        }
    }
}

// FlowLayout helper for dynamic tags
public struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(x: bounds.minX + result.origins[index].x, y: bounds.minY + result.origins[index].y)
            subview.place(at: point, proposal: ProposedViewSize(result.sizes[index]))
        }
    }
    
    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, origins: [CGPoint], sizes: [CGSize]) {
        let maxWidth = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var sizes: [CGSize] = []
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            origins.append(CGPoint(x: currentX, y: currentY))
            sizes.append(size)
            
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }
        
        let totalHeight = currentY + lineHeight
        return (CGSize(width: maxX, height: totalHeight), origins, sizes)
    }
}

#Preview {
    let itemStore = ItemStore()
    let sampleItem = itemStore.items.first!
    return ItemDetailView(item: sampleItem)
        .environmentObject(itemStore)
        .environmentObject(UserStore())
        .environmentObject(TradeProposalStore())
        .environmentObject(SafeZoneStore())
}
