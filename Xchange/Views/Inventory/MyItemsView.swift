//
//  MyItemsView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//

import SwiftUI

public struct MyItemsView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var userStore: UserStore
    
    @State private var showAddItemSheet = false
    @State private var selectedItemForDetail: Item? = nil
    
    private var myItems: [Item] {
        itemStore.userItems(for: userStore.currentUser.id)
    }
    
    private var totalInventoryValue: Double {
        myItems.reduce(0) { $0 + $1.estimatedValue }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Portfolio Valuation Summary Card
                    portfolioCard
                    
                    // Items Header
                    HStack {
                        Text("Your Listed Items (\(myItems.count))")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Items List
                    if myItems.isEmpty {
                        emptyClosetView
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(myItems) { item in
                                myItemRow(item: item)
                                    .onTapGesture {
                                        selectedItemForDetail = item
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("My Closet")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddItemSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("List Item")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddItemSheet) {
                AddItemView()
            }
            .sheet(item: $selectedItemForDetail) { item in
                ItemDetailView(item: item)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var portfolioCard: some View {
        ZStack(alignment: .leading) {
            AppTheme.primaryGradient
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TOTAL BARTER CAPITAL")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                        
                        Text("$\(Int(totalInventoryValue))")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button {
                        showAddItemSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Add Item")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.15), radius: 4)
                    }
                }
                
                HStack(spacing: 16) {
                    statPill(title: "Active", count: myItems.filter { $0.status == .available }.count, color: .green)
                    statPill(title: "In Trade", count: myItems.filter { $0.status == .inTradeNegotiation }.count, color: .orange)
                    statPill(title: "Traded", count: myItems.filter { $0.status == .traded }.count, color: .blue)
                }
            }
            .padding(18)
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: AppTheme.primary.opacity(0.25), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    private func statPill(title: String, count: Int, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text("\(count) \(title)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.2))
        .clipShape(Capsule())
    }
    
    private func myItemRow(item: Item) -> some View {
        HStack(spacing: 12) {
            // Category Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.primary.opacity(0.12))
                    .frame(width: 52, height: 52)
                
                Image(systemName: item.category.systemIcon)
                    .font(.system(size: 22))
                    .foregroundColor(AppTheme.primary)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(item.condition.rawValue)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(item.formattedValue)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.primary)
                }
                
                // Wishlist snippet
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.tradeAccent)
                    Text(item.preferredTrades)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Status Tag
            Text(item.status.rawValue)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(item.status.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(item.status.color.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
    
    private var emptyClosetView: some View {
        VStack(spacing: 14) {
            Image(systemName: "square.grid.3x3.topleft.filled")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
                .padding(.top, 40)
            
            Text("Your Closet is Empty")
                .font(.system(size: 16, weight: .bold, design: .rounded))
            
            Text("List items you own (electronics, cameras, musical gear, etc.) to start trading without cash.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Button {
                showAddItemSheet = true
            } label: {
                Text("List Your First Item")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AppTheme.primaryGradient)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    MyItemsView()
        .environmentObject(ItemStore())
        .environmentObject(UserStore())
}
