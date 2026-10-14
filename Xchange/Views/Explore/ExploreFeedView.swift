//
//  ExploreFeedView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Pixel-perfect Browse marketplace matching the reference design
//

import SwiftUI

public struct ExploreFeedView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var tradeStore: TradeProposalStore
    
    @State private var selectedItemForDetail: Item? = nil
    @State private var showFilterSheet: Bool = false
    
    private let activeGreen = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let borderGreen = Color(red: 0.22, green: 0.45, blue: 0.28)
    private let searchBg = Color(red: 0.05, green: 0.07, blue: 0.06)
    
    // Ordered categories matching the reference screenshot
    private let categoriesOrder: [ItemCategory] = [
        .all,
        .electronics,
        .vehicles,
        .collectibles,
        .services,
        .cameras,
        .musicalInstruments,
        .gaming,
        .fashion,
        .booksMedia,
        .outdoorSports,
        .homeGarden
    ]
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. Top White Navigation Header Bar
                topWhiteHeader
                
                // 2. Main Deep Black Marketplace Feed
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            // Page Title: "Browse"
                            Text("Browse")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                            
                            // Search Bar: "Search listings..."
                            searchBar
                                .padding(.horizontal, 16)
                            
                            // Horizontal Filter Chips: All, Electronics, Vehicles, Collectibles, Services...
                            categoryFilterPills
                            
                            // 2-Column Marketplace Item Grid
                            if itemStore.marketplaceItems.isEmpty {
                                emptyStateView
                            } else {
                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(itemStore.marketplaceItems) { item in
                                        ItemCard(item: item)
                                            .onTapGesture {
                                                AppTheme.triggerHaptic(style: .light)
                                                selectedItemForDetail = item
                                            }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 4)
                            }
                        }
                        .padding(.bottom, 120) // Clearance for elevated custom bottom tab bar
                    }
                    .refreshable {
                        try? await NetworkService.shared.syncWithRemoteCloud()
                        AppTheme.triggerNotificationHaptic(type: .success)
                    }
                }
            }
            .sheet(item: $selectedItemForDetail) { item in
                ItemDetailView(item: item)
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheetView(itemStore: itemStore)
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Subviews
    
    /// Top White Header Bar with centered black "Browse" title
    private var topWhiteHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                
                Text("Browse")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .frame(height: 46)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.ignoresSafeArea(edges: .top))
    }
    
    /// Dark search bar with green border and green magnifying glass
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(activeGreen)
            
            TextField(
                "",
                text: $itemStore.searchQuery,
                prompt: Text("Search listings...").foregroundColor(Color.gray.opacity(0.75))
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            
            if !itemStore.searchQuery.isEmpty {
                Button {
                    itemStore.searchQuery = ""
                    AppTheme.triggerHaptic(style: .light)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.gray)
                        .font(.system(size: 15))
                }
            } else {
                Button {
                    showFilterSheet = true
                    AppTheme.triggerHaptic(style: .light)
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.gray.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 42)
        .background(searchBg)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(borderGreen, lineWidth: 1.2)
        )
    }
    
    /// Category Filter Chips (All, Electronics, Vehicles, Collectibles, Services...)
    private var categoryFilterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categoriesOrder, id: \.self) { category in
                    let isSelected = itemStore.selectedCategory == category
                    
                    Button {
                        AppTheme.triggerHaptic(style: .light)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            itemStore.selectedCategory = category
                        }
                    } label: {
                        Text(category.chipTitle)
                            .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Group {
                                    if isSelected {
                                        activeGreen
                                    } else {
                                        Color.black
                                    }
                                }
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? activeGreen : borderGreen, lineWidth: 1.2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    /// Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray")
                .font(.system(size: 44, weight: .light))
                .foregroundColor(Color.gray.opacity(0.6))
                .padding(.top, 40)
            
            Text("No Listings Found")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("No trade listings match your current filters or search.")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                itemStore.selectedCategory = .all
                itemStore.searchQuery = ""
                AppTheme.triggerHaptic(style: .medium)
            } label: {
                Text("Reset Filters")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(activeGreen)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .overlay(
                        Capsule()
                            .stroke(activeGreen, lineWidth: 1)
                    )
            }
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    let itemStore = ItemStore()
    let userStore = UserStore()
    let tradeStore = TradeProposalStore()
    
    return ExploreFeedView()
        .environmentObject(itemStore)
        .environmentObject(userStore)
        .environmentObject(tradeStore)
}
