//
//  HomeLandingView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Pixel-perfect implementation of the official Xchange Home Landing Interface
//  greets authenticated users with Categories at the top, real-time auto-filtering search,
//  and scrollable Recent Listings with Sri Lanka locations and LKR currency
//

import SwiftUI

public struct HomeLandingView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var itemStore: ItemStore
    
    var onNavigateToBrowse: (() -> Void)? = nil
    var onAddListing: (() -> Void)? = nil
    
    @State private var searchText: String = ""
    @State private var selectedItemForDetail: Item? = nil
    @State private var selectedCategoryFilter: ItemCategory = .all
    
    // Official theme brand colors
    private let fieldBorderGreen = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let fieldDarkBackground = Color(red: 0.08, green: 0.11, blue: 0.13)
    private let cardBackground = Color(red: 0.09, green: 0.12, blue: 0.14)
    
    // Categories to display at the top
    private let displayCategories: [ItemCategory] = [
        .all,
        .electronics,
        .vehicles,
        .collectibles,
        .services,
        .cameras,
        .gaming,
        .fashion,
        .musicalInstruments,
        .outdoorSports,
        .booksMedia,
        .homeGarden
    ]
    
    public init(onNavigateToBrowse: (() -> Void)? = nil, onAddListing: (() -> Void)? = nil) {
        self.onNavigateToBrowse = onNavigateToBrowse
        self.onAddListing = onAddListing
    }
    
    private var greetingName: String {
        let displayName = userStore.currentUser.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !displayName.isEmpty {
            return displayName.components(separatedBy: " ").first ?? displayName
        }
        let username = userStore.currentUser.username.trimmingCharacters(in: .whitespacesAndNewlines)
        if !username.isEmpty {
            return username.capitalized
        }
        return "Trader"
    }
    
    // Auto-filtered recent items reacting instantly to search text and category filter
    private var filteredRecentItems: [Item] {
        itemStore.items.filter { item in
            // Only available or in-trade items
            guard item.status != .traded else { return false }
            
            // Category filter check
            if selectedCategoryFilter != .all {
                guard item.category == selectedCategoryFilter else { return false }
            }
            
            // Real-time search query filtering (does not wait for submit button)
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !query.isEmpty {
                let matchesTitle = item.title.localizedCaseInsensitiveContains(query)
                let matchesDesc = item.description.localizedCaseInsensitiveContains(query)
                let matchesTags = item.tags.contains(where: { $0.localizedCaseInsensitiveContains(query) })
                let matchesTrades = item.preferredTrades.localizedCaseInsensitiveContains(query)
                let matchesLocation = item.ownerLocation.localizedCaseInsensitiveContains(query)
                let matchesCategory = item.category.rawValue.localizedCaseInsensitiveContains(query)
                guard matchesTitle || matchesDesc || matchesTags || matchesTrades || matchesLocation || matchesCategory else {
                    return false
                }
            }
            
            return true
        }
        .sorted { $0.createdAt > $1.createdAt }
    }
    
    // User's own active listings (strictly specific to the logged-in user only)
    private var myActiveItems: [Item] {
        itemStore.items.filter { $0.isOwnedBy(user: userStore.currentUser) && $0.status == .available }
    }
    
    public var body: some View {
        ZStack {
            // Full Screen Background: Pure Pitch Black
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top White Banner Bar with Centered "Xchange" Wordmark
                topWhiteHeaderBanner
                
                // Scrollable Landing Page Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // 1. Welcome Greeting Header with Sri Lanka location badge
                        welcomeGreetingHeader
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        // 2. Real-time Auto-Filtering Search Bar
                        searchBar
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                        
                        // 3. Categories Section at the TOP
                        categoriesTopSection
                            .padding(.top, 20)
                        
                        // 4. My Active Listings Section (if user has items)
                        if !myActiveItems.isEmpty {
                            myActiveListingsSection
                                .padding(.top, 22)
                        }
                        
                        // 5. Recent Listings Section (Downward scrollable list)
                        recentListingsSection
                            .padding(.top, 22)
                            .padding(.bottom, 120) // Clearance for custom floating bottom navigation bar
                    }
                }
            }
        }
        .sheet(item: $selectedItemForDetail) { item in
            ItemDetailView(item: item)
        }
    }
    
    // MARK: - Top Header White Banner
    
    private var topWhiteHeaderBanner: some View {
        HStack {
            Spacer()
            Text("Xchange")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .tracking(0.5)
            Spacer()
        }
        .frame(height: 52)
        .background(Color.white)
        .clipShape(UnevenRoundedCornerShape(bottomLeading: 22, bottomTrailing: 22))
        .shadow(color: Color.black.opacity(0.3), radius: 10, y: 4)
    }
    
    // MARK: - Welcome Greeting Header
    
    private var welcomeGreetingHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome, \(greetingName)!")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 5) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(fieldBorderGreen)
                
                Text(userStore.currentUser.location)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.gray.opacity(0.85))
                
                Text("•")
                    .foregroundColor(Color.gray.opacity(0.6))
                
                Text("LKR Currency Active")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(fieldBorderGreen)
            }
        }
    }
    
    // MARK: - Real-time Auto-Filtering Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(fieldBorderGreen)
            
            TextField(
                "",
                text: $searchText,
                prompt: Text("Search items, categories, or locations in Sri Lanka...").foregroundColor(Color.gray.opacity(0.65))
            )
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .onChange(of: searchText) { _, newValue in
                // Automatically syncs to shared ItemStore query without waiting for button press
                itemStore.searchQuery = newValue
            }
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    itemStore.searchQuery = ""
                    AppTheme.triggerHaptic(style: .light)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.gray.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(fieldDarkBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(fieldBorderGreen, lineWidth: 1.5)
        )
    }
    
    // MARK: - Categories Section at the TOP
    
    private var categoriesTopSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Categories")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                if selectedCategoryFilter != .all {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategoryFilter = .all
                            itemStore.selectedCategory = .all
                        }
                        AppTheme.triggerHaptic(style: .light)
                    } label: {
                        Text("Reset to All")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(fieldBorderGreen)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Horizontal scroll of categories for quick one-tap filtering
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(displayCategories) { category in
                        let isSelected = selectedCategoryFilter == category
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategoryFilter = category
                                itemStore.selectedCategory = category
                            }
                            AppTheme.triggerHaptic(style: .light)
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: category.systemIcon)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(isSelected ? .black : fieldBorderGreen)
                                
                                Text(category.chipTitle)
                                    .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                                    .foregroundColor(isSelected ? .black : .white)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(isSelected ? fieldBorderGreen : fieldDarkBackground)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? Color.clear : fieldBorderGreen.opacity(0.4), lineWidth: 1.2)
                            )
                            .shadow(color: isSelected ? fieldBorderGreen.opacity(0.35) : Color.clear, radius: 6, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Recent Listings Section (Scrollable Downward List)
    
    private var recentListingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Recent Listings")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if !searchText.isEmpty {
                        Text("Filtered by: \"\(searchText)\"")
                            .font(.system(size: 12))
                            .foregroundColor(fieldBorderGreen)
                    } else if selectedCategoryFilter != .all {
                        Text("Category: \(selectedCategoryFilter.rawValue)")
                            .font(.system(size: 12))
                            .foregroundColor(fieldBorderGreen)
                    }
                }
                
                Spacer()
                
                Text("\(filteredRecentItems.count) items")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(fieldBorderGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(fieldBorderGreen.opacity(0.12))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            
            // Vertical Scrollable List of Recent Added Items
            if filteredRecentItems.isEmpty {
                emptyRecentListingsView
                    .padding(.horizontal, 20)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredRecentItems) { item in
                        recentListingCard(item: item)
                            .onTapGesture {
                                AppTheme.triggerHaptic(style: .light)
                                selectedItemForDetail = item
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // High-fidelity Recent Listing Card tailored for vertical scroll
    private func recentListingCard(item: Item) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Left Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0.12, green: 0.15, blue: 0.18))
                    .frame(width: 90, height: 90)
                
                itemImageVisual(item: item)
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            
            // Right Details
            VStack(alignment: .leading, spacing: 5) {
                // Title & Condition
                HStack(alignment: .top) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if item.isOwnedBy(user: userStore.currentUser) {
                        HStack(spacing: 3) {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .font(.system(size: 10, weight: .bold))
                            Text("Your Listing")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2.5)
                        .background(Color.blue.opacity(0.18))
                        .clipShape(Capsule())
                    } else {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.2.squarepath")
                                .font(.system(size: 9, weight: .bold))
                            Text("Barter")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(fieldBorderGreen)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2.5)
                        .background(fieldBorderGreen.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
                
                // Category & Sri Lanka Location
                HStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: item.category.systemIcon)
                            .font(.system(size: 10))
                        Text(item.category.chipTitle)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(Color.gray.opacity(0.85))
                    
                    Text("•")
                        .foregroundColor(Color.gray.opacity(0.5))
                        .font(.system(size: 10))
                    
                    HStack(spacing: 3) {
                        Image(systemName: "mappin")
                            .font(.system(size: 9))
                        Text(item.ownerLocation)
                            .font(.system(size: 11, weight: .medium))
                            .lineLimit(1)
                    }
                    .foregroundColor(Color.gray.opacity(0.85))
                }
                
                // LKR Estimated Value & Preferred Trade
                HStack(alignment: .lastTextBaseline) {
                    Text(item.formattedValue)
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(fieldBorderGreen)
                    
                    Spacer()
                    
                    Text(item.condition.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(item.condition.color)
                }
                .padding(.top, 2)
                
                // Trade Barter Pitch
                if !item.preferredTrades.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color.gray)
                        Text(item.preferredTrades)
                            .font(.system(size: 11))
                            .foregroundColor(Color.gray.opacity(0.8))
                            .lineLimit(1)
                    }
                    .padding(.top, 1)
                }
            }
        }
        .padding(12)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 6, y: 3)
    }
    
    // Image visual resolution for camera photos, assets, or symbols
    @ViewBuilder
    private func itemImageVisual(item: Item) -> some View {
        if let firstImage = item.images.first, !firstImage.isEmpty {
            if let customImg = PersistenceService.shared.resolveImage(nameOrPath: firstImage) {
                Image(uiImage: customImg)
                    .resizable()
                    .scaledToFill()
            } else if UIImage(named: firstImage) != nil {
                Image(firstImage)
                    .resizable()
                    .scaledToFill()
            } else if UIImage(systemName: firstImage) != nil {
                ZStack {
                    Color(red: 0.14, green: 0.18, blue: 0.20)
                    Image(systemName: firstImage)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(fieldBorderGreen)
                }
            } else {
                Image(firstImage)
                    .resizable()
                    .scaledToFill()
            }
        } else {
            ZStack {
                Color(red: 0.14, green: 0.18, blue: 0.20)
                Image(systemName: item.category.systemIcon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(fieldBorderGreen)
            }
        }
    }
    
    // Empty state when search or category filter yields no matches
    private var emptyRecentListingsView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(fieldBorderGreen.opacity(0.12))
                    .frame(width: 54, height: 54)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(fieldBorderGreen)
            }
            
            Text("No recent listings found")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text("No items match \"\(searchText.isEmpty ? selectedCategoryFilter.rawValue : searchText)\" in Sri Lanka.")
                .font(.system(size: 13))
                .foregroundColor(Color.gray.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button {
                withAnimation {
                    searchText = ""
                    itemStore.searchQuery = ""
                    selectedCategoryFilter = .all
                    itemStore.selectedCategory = .all
                }
                AppTheme.triggerHaptic(style: .light)
            } label: {
                Text("Clear All Filters")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(fieldBorderGreen)
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    // MARK: - My Active Listings Section
    
    private var myActiveListingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My Active Listings")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    onAddListing?()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(fieldBorderGreen)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(myActiveItems) { item in
                        Button {
                            AppTheme.triggerHaptic(style: .light)
                            selectedItemForDetail = item
                        } label: {
                            HStack(spacing: 10) {
                                itemImageVisual(item: item)
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    Text(item.formattedValue)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(fieldBorderGreen)
                                }
                                
                                Spacer(minLength: 4)
                            }
                            .padding(8)
                            .frame(width: 190, height: 64)
                            .background(cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Custom Corner Shape for Top Header

private struct UnevenRoundedCornerShape: Shape {
    var bottomLeading: CGFloat = 0
    var bottomTrailing: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: bottomLeading, height: bottomTrailing)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    HomeLandingView()
        .environmentObject(UserStore())
        .environmentObject(ItemStore())
}
