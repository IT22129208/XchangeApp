//
//  HomeLandingView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Pixel-perfect implementation of the official Xchange Home Landing Interface
//  greets authenticated users with Featured Exchanges, Categories & Active Listings
//

import SwiftUI

public struct HomeLandingView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var itemStore: ItemStore
    
    var onNavigateToBrowse: (() -> Void)? = nil
    var onAddListing: (() -> Void)? = nil
    
    @State private var searchText: String = ""
    @State private var selectedItemForDetail: Item? = nil
    @State private var selectedCategoryFilter: ItemCategory? = nil
    
    // Official theme brand colors
    private let fieldBorderGreen = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let fieldDarkBackground = Color(red: 0.08, green: 0.11, blue: 0.13)
    private let cardBackground = Color(red: 0.09, green: 0.12, blue: 0.14)
    
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
        let emailPrefix = userStore.currentUser.email.components(separatedBy: "@").first ?? ""
        if !emailPrefix.isEmpty {
            let formatted = emailPrefix.replacingOccurrences(of: ".", with: " ").capitalized
            return formatted.components(separatedBy: " ").first ?? formatted
        }
        return "Trader"
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
                        // 1. Welcome Greeting Header
                        Text("Welcome, \(greetingName)!")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.top, 18)
                        
                        // 2. Search Bar
                        searchBar
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                        
                        // 3. Featured Exchanges Section
                        featuredExchangesSection
                            .padding(.top, 22)
                        
                        // 4. Categories Section
                        categoriesSection
                            .padding(.top, 22)
                        
                        // 5. My Active Listings Section
                        myActiveListingsSection
                            .padding(.top, 22)
                            .padding(.bottom, 90) // Extra padding for custom floating tab bar
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
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            TextField(
                "",
                text: $searchText,
                prompt: Text("Search").foregroundColor(Color.gray.opacity(0.7))
            )
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            
            Button {
                if !searchText.isEmpty {
                    itemStore.searchQuery = searchText
                    onNavigateToBrowse?()
                }
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(fieldBorderGreen)
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 48)
        .background(fieldDarkBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(fieldBorderGreen, lineWidth: 1.5)
        )
    }
    
    // MARK: - Featured Exchanges Section
    
    private var featuredExchangesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Featured Exchanges")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    // Card 1: Vintage Bike
                    featuredCard(
                        title: "Vintage Bike",
                        itemLookupTitle: "Vintage Bike"
                    ) {
                        VintageBikeArtworkView()
                    }
                    
                    // Card 2: DSLR Camera
                    featuredCard(
                        title: "DSLR Camera",
                        itemLookupTitle: "DSLR Camera"
                    ) {
                        DSLRCameraArtworkView()
                    }
                    
                    // Card 3: Rare Book
                    featuredCard(
                        title: "Rare Book",
                        itemLookupTitle: "Rare Book"
                    ) {
                        RareBookArtworkView()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func featuredCard<Art: View>(
        title: String,
        itemLookupTitle: String,
        @ViewBuilder artwork: () -> Art
    ) -> some View {
        Button {
            AppTheme.triggerHaptic(style: .light)
            if let item = itemStore.items.first(where: { $0.title.localizedCaseInsensitiveContains(itemLookupTitle) }) {
                selectedItemForDetail = item
            } else if let firstItem = itemStore.items.first {
                selectedItemForDetail = firstItem
            }
        } label: {
            ZStack(alignment: .bottomLeading) {
                // Card Background & Artwork
                ZStack {
                    LinearGradient(
                        colors: [Color(white: 0.16), Color(white: 0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    artwork()
                }
                .frame(width: 154, height: 185)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
                // Top-Left Verified Badge
                VStack {
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(fieldBorderGreen)
                            
                            Text("Verified")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(fieldBorderGreen)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.75))
                        .clipShape(Capsule())
                        
                        Spacer()
                    }
                    .padding(10)
                    
                    Spacer()
                }
                
                // Bottom Gradient Scrim & Item Title
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 55)
                    .overlay(
                        HStack {
                            Text(title)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 10),
                        alignment: .bottomLeading
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .frame(width: 154, height: 185)
            .shadow(color: Color.black.opacity(0.4), radius: 8, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Categories Section
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Categories")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            HStack(spacing: 0) {
                // 1. Electronics
                categoryButton(
                    title: "Electronics",
                    icon: "laptopcomputer.and.iphone",
                    category: .electronics
                )
                
                // 2. Vehicles
                categoryButton(
                    title: "Vehicles",
                    icon: "car.fill",
                    category: .vehicles
                )
                
                // 3. Collectibles
                categoryButton(
                    title: "Collectibles",
                    icon: "shield.fill",
                    category: .collectibles
                )
                
                // 4. Services
                categoryButton(
                    title: "Services",
                    icon: "wrench.and.screwdriver.fill",
                    category: .services
                )
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func categoryButton(
        title: String,
        icon: String,
        category: ItemCategory
    ) -> some View {
        Button {
            AppTheme.triggerHaptic(style: .light)
            itemStore.selectedCategory = category
            onNavigateToBrowse?()
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(fieldDarkBackground)
                        .frame(width: 66, height: 66)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(fieldBorderGreen, lineWidth: 1.5)
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(fieldBorderGreen)
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - My Active Listings Section
    
    private var myActiveListingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("My Active Listings")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
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
                HStack(spacing: 14) {
                    // Card 1: MacBook Pro
                    activeListingCard(
                        title: "MacBook Pro",
                        itemLookupTitle: "MacBook Pro"
                    ) {
                        MacBookProArtworkView()
                    }
                    
                    // Card 2: Graphic Tablet
                    activeListingCard(
                        title: "Graphic Tablet",
                        itemLookupTitle: "Graphic Tablet"
                    ) {
                        GraphicTabletArtworkView()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func activeListingCard<Art: View>(
        title: String,
        itemLookupTitle: String,
        @ViewBuilder artwork: () -> Art
    ) -> some View {
        Button {
            AppTheme.triggerHaptic(style: .light)
            if let item = itemStore.items.first(where: { $0.title.localizedCaseInsensitiveContains(itemLookupTitle) }) {
                selectedItemForDetail = item
            }
        } label: {
            HStack(spacing: 14) {
                // Left thumbnail artwork in clean rounded box
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .frame(width: 58, height: 58)
                    
                    artwork()
                        .frame(width: 48, height: 48)
                }
                
                // Right title & status
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 5) {
                        Circle()
                            .fill(fieldBorderGreen)
                            .frame(width: 6, height: 6)
                        Text("Active Barter")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color.gray.opacity(0.85))
                    }
                }
                
                Spacer(minLength: 8)
            }
            .padding(10)
            .frame(width: 210, height: 78)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 6, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Specialized High-Fidelity Artwork Views

private struct VintageBikeArtworkView: View {
    var body: some View {
        ZStack {
            Color(red: 0.14, green: 0.18, blue: 0.20)
            
            VStack(spacing: 4) {
                Image(systemName: "bicycle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 105, height: 68)
                    .foregroundColor(Color(red: 0.38, green: 0.76, blue: 0.72)) // Vintage Mint
                    .shadow(color: Color.black.opacity(0.4), radius: 4, y: 2)
            }
            .padding(.bottom, 20)
        }
    }
}

private struct DSLRCameraArtworkView: View {
    var body: some View {
        ZStack {
            Color(red: 0.16, green: 0.18, blue: 0.21)
            
            VStack(spacing: 4) {
                Image(systemName: "camera.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 85, height: 68)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(white: 0.85), Color(white: 0.45)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color(red: 0.24, green: 0.65, blue: 0.38), lineWidth: 2)
                            .frame(width: 32, height: 32)
                            .offset(y: 4)
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 6, y: 3)
            }
            .padding(.bottom, 20)
        }
    }
}

private struct RareBookArtworkView: View {
    var body: some View {
        ZStack {
            Color(red: 0.20, green: 0.16, blue: 0.14) // Warm antique tone
            
            VStack(spacing: 4) {
                Image(systemName: "books.vertical.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 78, height: 70)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.82, green: 0.68, blue: 0.42), Color(red: 0.55, green: 0.40, blue: 0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 6, y: 3)
            }
            .padding(.bottom, 20)
        }
    }
}

private struct MacBookProArtworkView: View {
    var body: some View {
        ZStack {
            Color.white
            Image(systemName: "laptopcomputer")
                .resizable()
                .scaledToFit()
                .frame(width: 38, height: 26)
                .foregroundColor(Color(red: 0.20, green: 0.22, blue: 0.25))
        }
    }
}

private struct GraphicTabletArtworkView: View {
    var body: some View {
        ZStack {
            Color.white
            Image(systemName: "ipad.and.iphone")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 26)
                .foregroundColor(Color(red: 0.25, green: 0.28, blue: 0.32))
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
