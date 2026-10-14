//
//  ProfileView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Pixel-perfect Profile interface matching user reference design with the official dark Xchange theme
//

import SwiftUI
import PhotosUI
import UIKit


public struct ProfileView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var safeZoneStore: SafeZoneStore
    
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("userLanguage") private var userLanguage: String = "English (US)"
    @AppStorage("userCurrency") private var userCurrency: String = "USD ($)"
    @AppStorage("userColorScheme") private var userColorScheme: String = "dark"
    
    @State private var showEditProfileSheet = false
    @State private var showAddItemSheet = false
    @State private var selectedItemForDetail: Item? = nil
    @State private var showLanguageSheet = false
    @State private var showCurrenciesSheet = false
    @State private var showAppearanceSheet = false
    @State private var showSecuritySheet = false
    @State private var showDevicesSheet = false
    @State private var showPasswordSheet = false
    @State private var showSafeZoneMap = false
    @State private var showAboutMissionSheet = false
    @State private var showLogoutAlert = false
    
    var onNavigateBack: (() -> Void)? = nil
    
    private let accentGreen = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let cardDarkBg = Color(red: 0.08, green: 0.10, blue: 0.12)
    private let cardBorder = Color.white.opacity(0.08)
    
    private var user: User {
        userStore.currentUser
    }
    
    private var userItems: [Item] {
        itemStore.userItems(for: user.id)
    }

    
    public init(onNavigateBack: (() -> Void)? = nil) {
        self.onNavigateBack = onNavigateBack
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background: Pitch Black matching app theme
                Color.black
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // 1. Navigation Header with Back Arrow Circle
                        headerSection
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        // 2. Large Profile Card
                        mainProfileCard
                            .padding(.horizontal, 20)
                        
                        // 3. User's Items Placed for Barter
                        userBarterItemsSection
                            .padding(.horizontal, 20)
                        
                        // 4. Settings Group 1: Preferences
                        groupOneCard
                            .padding(.horizontal, 20)
                        
                        // 5. Settings Group 2: Security & Devices
                        groupTwoCard
                            .padding(.horizontal, 20)
                        
                        // 6. Settings Group 3: Xchange Safety & Trust
                        groupThreeCard
                            .padding(.horizontal, 20)
                        
                        // 7. Log Out Button
                        logoutButton
                            .padding(.horizontal, 20)
                            .padding(.top, 6)
                    }
                    .padding(.bottom, 120) // Space for bottom custom tab bar
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedItemForDetail) { item in
                ItemDetailView(item: item)
            }
            .sheet(isPresented: $showAddItemSheet) {
                AddItemView(isPresentedAsModal: true)
            }
            .sheet(isPresented: $showEditProfileSheet) {
                EditProfileModalView(user: user, userStore: userStore)
            }

            .sheet(isPresented: $showLanguageSheet) {
                LanguageSelectionSheet(selectedLanguage: $userLanguage)
            }
            .sheet(isPresented: $showCurrenciesSheet) {
                CurrencySelectionSheet(selectedCurrency: $userCurrency)
            }
            .sheet(isPresented: $showAppearanceSheet) {
                AppearanceSelectionSheet(selectedScheme: $userColorScheme)
            }
            .sheet(isPresented: $showSecuritySheet) {
                SecurityModalView()
            }
            .sheet(isPresented: $showDevicesSheet) {
                DevicesModalView()
            }
            .sheet(isPresented: $showPasswordSheet) {
                ChangePasswordModalView()
            }
            .sheet(isPresented: $showSafeZoneMap) {
                SafeZoneMapView()
            }
            .sheet(isPresented: $showAboutMissionSheet) {
                AboutMissionView()
            }
            .alert("Log Out of Xchange?", isPresented: $showLogoutAlert) {
                Button("Log Out", role: .destructive) {
                    AppTheme.triggerNotificationHaptic(type: .warning)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isLoggedIn = false
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out and return to the login screen?")
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Circular Back Arrow Button
            Button {
                AppTheme.triggerHaptic(style: .light)
                onNavigateBack?()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Bold "Profile" Title
            Text("Profile")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Main Profile Card
    
    private var mainProfileCard: some View {
        VStack(spacing: 12) {
            // Circular Avatar (Tappable to Edit Profile / Upload Photo)
            Button {
                AppTheme.triggerHaptic(style: .medium)
                showEditProfileSheet = true
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 92, height: 92)
                        
                        if let customImg = PersistenceService.shared.resolveImage(nameOrPath: user.avatar) {
                            Image(uiImage: customImg)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 88, height: 88)
                                .clipShape(Circle())
                        } else if UIImage(named: user.avatar) != nil {
                            Image(user.avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 88, height: 88)
                                .clipShape(Circle())
                        } else if UIImage(named: "user_avatar_profile") != nil {
                            Image("user_avatar_profile")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 88, height: 88)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: user.avatar)
                                .font(.system(size: 52))
                                .foregroundColor(accentGreen)
                                .frame(width: 88, height: 88)
                                .background(accentGreen.opacity(0.15))
                                .clipShape(Circle())
                        }
                    }
                    .overlay(
                        Circle()
                            .stroke(accentGreen.opacity(0.4), lineWidth: 1.5)
                    )
                    
                    // Subtle Camera Icon Badge
                    Circle()
                        .fill(accentGreen)
                        .frame(width: 26, height: 26)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 2, y: 2)
                }
                .shadow(color: Color.black.opacity(0.3), radius: 6, y: 3)
            }
            .buttonStyle(PlainButtonStyle())

            
            // Name
            Text(user.displayName)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Email
            Text(user.email)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.gray.opacity(0.9))
            
            // Role & Location Subtitle
            HStack(spacing: 6) {
                Text(user.bio.isEmpty ? "Tech Trader & Barterer" : user.bio)
                    .lineLimit(1)
                
                Text("•")
                
                HStack(spacing: 3) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11))
                        .foregroundColor(accentGreen)
                    Text(user.location)
                }
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color.gray.opacity(0.75))
            .padding(.horizontal, 16)
            
            // "Edit Profile" Capsule Button
            Button {
                AppTheme.triggerHaptic(style: .medium)
                showEditProfileSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .bold))
                    Text("Edit Profile")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .frame(height: 42)
                .background(accentGreen)
                .clipShape(Capsule())
                .shadow(color: accentGreen.opacity(0.35), radius: 8, y: 3)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity)
        .background(cardDarkBg)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }
    
    // MARK: - User's Items Placed for Barter Section
    
    private var userBarterItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(accentGreen)
                    
                    Text("Items for Barter")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("\(userItems.count)")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(accentGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(accentGreen.opacity(0.15))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Button {
                    AppTheme.triggerHaptic(style: .medium)
                    showAddItemSheet = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                        Text("List Item")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(accentGreen)
                    .clipShape(Capsule())
                    .shadow(color: accentGreen.opacity(0.35), radius: 5, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Items List or Empty State
            if userItems.isEmpty {
                emptyBarterItemsView
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(userItems) { item in
                            userBarterItemCard(item: item)
                        }
                        
                        addNewItemCarouselCard
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }
    
    // MARK: - Individual Barter Item Card
    
    private func userBarterItemCard(item: Item) -> some View {
        Button {
            AppTheme.triggerHaptic(style: .light)
            selectedItemForDetail = item
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Top Thumbnail Image with Badges
                ZStack(alignment: .topLeading) {
                    // Item Visual
                    if let firstImage = item.images.first, !firstImage.isEmpty {
                        if let customImg = PersistenceService.shared.resolveImage(nameOrPath: firstImage) {
                            Image(uiImage: customImg)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 175, height: 115)
                                .clipped()
                        } else if UIImage(named: firstImage) != nil {
                            Image(firstImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 175, height: 115)
                                .clipped()
                        } else {
                            ZStack {
                                Color(red: 0.12, green: 0.15, blue: 0.18)
                                Image(systemName: firstImage)
                                    .font(.system(size: 38))
                                    .foregroundColor(accentGreen)
                            }
                            .frame(width: 175, height: 115)
                        }
                    } else {
                        ZStack {
                            Color(red: 0.12, green: 0.15, blue: 0.18)
                            Image(systemName: item.category.systemIcon)
                                .font(.system(size: 38))
                                .foregroundColor(accentGreen)
                        }
                        .frame(width: 175, height: 115)
                    }
                    
                    // Top Badges Overlay
                    HStack {
                        // Category Pill
                        HStack(spacing: 3) {
                            Image(systemName: item.category.systemIcon)
                                .font(.system(size: 9))
                            Text(item.category.chipTitle)
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.72))
                        .clipShape(Capsule())
                        
                        Spacer()
                        
                        // Active Status Dot
                        HStack(spacing: 4) {
                            Circle()
                                .fill(accentGreen)
                                .frame(width: 6, height: 6)
                            Text("Active")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.72))
                        .clipShape(Capsule())
                    }
                    .padding(8)
                }
                .frame(width: 175, height: 115)
                .background(Color.black.opacity(0.2))
                
                // Bottom Info Details
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text(item.formattedValue)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundColor(accentGreen)
                        
                        Text("•")
                            .foregroundColor(Color.gray.opacity(0.5))
                            .font(.system(size: 10))
                        
                        Text(item.condition.rawValue)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.gray.opacity(0.85))
                            .lineLimit(1)
                    }
                    
                    // Trade Preferences
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.system(size: 10))
                            .foregroundColor(accentGreen)
                        Text(item.preferredTrades)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color.gray.opacity(0.8))
                            .lineLimit(1)
                    }
                }
                .padding(10)
                .frame(width: 175, alignment: .leading)
            }
            .frame(width: 175, height: 195)
            .background(cardDarkBg)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(cardBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 6, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Add New Item Carousel Card
    
    private var addNewItemCarouselCard: some View {
        Button {
            AppTheme.triggerHaptic(style: .medium)
            showAddItemSheet = true
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(accentGreen.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(accentGreen)
                }
                
                Text("List Another\nItem")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color.gray.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .frame(width: 120, height: 195)
            .background(cardDarkBg.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(cardBorder, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Empty Barter Items View
    
    private var emptyBarterItemsView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accentGreen.opacity(0.12))
                    .frame(width: 52, height: 52)
                
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(accentGreen)
            }
            
            Text("No Items Placed for Barter Yet")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("List cameras, tech, instruments, or clothing to trade with barter partners in your area.")
                .font(.system(size: 12))
                .foregroundColor(Color.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button {
                AppTheme.triggerHaptic(style: .medium)
                showAddItemSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("Place Your First Item")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(accentGreen)
                .clipShape(Capsule())
                .shadow(color: accentGreen.opacity(0.3), radius: 5, y: 2)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity)
        .background(cardDarkBg)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Group 1: Preferences
    
    private var groupOneCard: some View {

        VStack(spacing: 0) {
            // 1. Language
            optionRow(
                icon: "character.book.closed.fill",
                title: "Language",
                value: userLanguage
            ) {
                showLanguageSheet = true
            }
            
            rowDivider
            
            // 2. Currencies
            optionRow(
                icon: "dollarsign.circle.fill",
                title: "Currencies",
                value: userCurrency
            ) {
                showCurrenciesSheet = true
            }
            
            rowDivider
            
            // 3. Appearance
            optionRow(
                icon: "circle.lefthalf.filled",
                title: "Appearance",
                value: userColorScheme.capitalized
            ) {
                showAppearanceSheet = true
            }
        }
        .background(cardDarkBg)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Group 2: Security & Devices
    
    private var groupTwoCard: some View {
        VStack(spacing: 0) {
            // 1. Application Security
            optionRow(
                icon: "lock.shield.fill",
                title: "Application Security",
                value: "Biometrics Active"
            ) {
                showSecuritySheet = true
            }
            
            rowDivider
            
            // 2. Manage Devices
            optionRow(
                icon: "iphone.gen3",
                title: "Manage Devices",
                value: "This iPhone"
            ) {
                showDevicesSheet = true
            }
            
            rowDivider
            
            // 3. Change Password
            optionRow(
                icon: "key.fill",
                title: "Change Password",
                value: nil
            ) {
                showPasswordSheet = true
            }
        }
        .background(cardDarkBg)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Group 3: Xchange Safety & Trust
    
    private var groupThreeCard: some View {
        VStack(spacing: 0) {
            // Safe Exchange Zones
            optionRow(
                icon: "shield.checkered",
                title: "Safe Exchange Zones",
                value: "Apple Maps Verified"
            ) {
                showSafeZoneMap = true
            }
            
            rowDivider
            
            // About Xchange Mission & Trust
            optionRow(
                icon: "info.circle.fill",
                title: "About Xchange & Community",
                value: "v1.0"
            ) {
                showAboutMissionSheet = true
            }
        }
        .background(cardDarkBg)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Log Out Button
    
    private var logoutButton: some View {
        Button {
            AppTheme.triggerNotificationHaptic(type: .warning)
            showLogoutAlert = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .bold))
                Text("Log Out")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(Color.red)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.red.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Reusable Row Component
    
    private func optionRow(
        icon: String,
        title: String,
        value: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            AppTheme.triggerHaptic(style: .light)
            action()
        } label: {
            HStack(spacing: 14) {
                // Left Icon with subtle green accent
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(accentGreen)
                    .frame(width: 24, height: 24)
                
                // Title
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Optional Value text
                if let value = value {
                    Text(value)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.gray.opacity(0.8))
                }
                
                // Chevron Right
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.gray.opacity(0.6))
            }
            .padding(.horizontal, 18)
            .frame(height: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var rowDivider: some View {
        Divider()
            .background(Color.white.opacity(0.06))
            .padding(.leading, 56)
    }
}

// MARK: - Edit Profile Modal Sheet

private struct EditProfileModalView: View {
    @Environment(\.dismiss) private var dismiss
    let user: User
    let userStore: UserStore
    
    @State private var displayName: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var location: String = ""
    @State private var bio: String = ""
    
    // Photo Picker State
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isSaving: Bool = false
    
    private let accentGreen = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let fieldBg = Color(red: 0.08, green: 0.10, blue: 0.12)
    private let fieldBorder = Color.white.opacity(0.12)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        // 1. Photo Upload / Avatar Header
                        photoUploadSection
                            .padding(.top, 16)
                        
                        // 2. Personal Information Fields
                        VStack(alignment: .leading, spacing: 16) {
                            inputField(
                                label: "Display Name",
                                placeholder: "e.g., Alex Rivera",
                                text: $displayName,
                                icon: "person.fill"
                            )
                            
                            inputField(
                                label: "Username",
                                placeholder: "e.g., alex_rivera",
                                text: $username,
                                icon: "at"
                            )
                            
                            inputField(
                                label: "Email Address",
                                placeholder: "e.g., alex@example.com",
                                text: $email,
                                icon: "envelope.fill",
                                keyboardType: .emailAddress
                            )
                            
                            inputField(
                                label: "Location",
                                placeholder: "e.g., San Francisco, CA",
                                text: $location,
                                icon: "mappin.circle.fill"
                            )
                            
                            // Bio & Interests Multi-line
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bio & Trading Interests")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.85))
                                
                                TextEditor(text: $bio)
                                    .scrollContentBackground(.hidden)
                                    .frame(height: 90)
                                    .padding(12)
                                    .background(fieldBg)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(fieldBorder, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 3. Save Button
                        Button {
                            saveProfile()
                        } label: {
                            HStack(spacing: 8) {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("Save Changes")
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(accentGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: accentGreen.opacity(0.35), radius: 8, y: 3)
                        }
                        .disabled(isSaving || displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveProfile() }
                        .fontWeight(.bold)
                        .foregroundColor(accentGreen)
                        .disabled(displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                displayName = user.displayName
                username = user.username
                email = user.email
                location = user.location
                bio = user.bio
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let newItem = newItem,
                       let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            self.selectedImage = uiImage
                            AppTheme.triggerNotificationHaptic(type: .success)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Photo Upload Section
    
    private var photoUploadSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    // Avatar Image Display
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 104, height: 104)
                        
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else if let customImg = PersistenceService.shared.resolveImage(nameOrPath: user.avatar) {
                            Image(uiImage: customImg)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else if UIImage(named: user.avatar) != nil {
                            Image(user.avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else if UIImage(named: "user_avatar_profile") != nil {
                            Image("user_avatar_profile")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: user.avatar)
                                .font(.system(size: 56))
                                .foregroundColor(accentGreen)
                                .frame(width: 100, height: 100)
                                .background(accentGreen.opacity(0.15))
                                .clipShape(Circle())
                        }
                    }
                    .overlay(
                        Circle()
                            .stroke(accentGreen, lineWidth: 2)
                    )
                    
                    // Camera Badge
                    Circle()
                        .fill(accentGreen)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 2, y: 2)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // "Change Photo" Button Label
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack(spacing: 6) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 13, weight: .semibold))
                    Text(selectedImage != nil ? "Photo Selected (Tap to Change)" : "Upload Profile Picture")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(accentGreen)
            }
        }
    }
    
    // MARK: - Input Field Helper
    
    private func inputField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        icon: String,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(accentGreen)
                    .frame(width: 20)
                
                TextField("", text: text, prompt: Text(placeholder).foregroundColor(Color.gray.opacity(0.6)))
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(fieldBg)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(fieldBorder, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Save Action
    
    private func saveProfile() {
        isSaving = true
        AppTheme.triggerHaptic(style: .medium)
        
        if let image = selectedImage {
            userStore.updateProfilePhoto(image)
        }
        
        userStore.updateProfile(
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            bio: bio.trimmingCharacters(in: .whitespacesAndNewlines),
            location: location.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            username: username.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        AppTheme.triggerNotificationHaptic(type: .success)
        dismiss()
    }
}


// MARK: - Language Selection Sheet

private struct LanguageSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLanguage: String
    
    let languages = ["English (US)", "English (UK)", "Spanish (Español)", "French (Français)", "German (Deutsch)", "Japanese (日本語)", "Sinhala (සිංහල)"]
    
    var body: some View {
        NavigationStack {
            List(languages, id: \.self) { lang in
                HStack {
                    Text(lang)
                        .foregroundColor(.primary)
                    Spacer()
                    if selectedLanguage == lang {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(red: 0.24, green: 0.65, blue: 0.38))
                            .fontWeight(.bold)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedLanguage = lang
                    AppTheme.triggerHaptic(style: .light)
                    dismiss()
                }
            }
            .navigationTitle("Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Currency Selection Sheet

private struct CurrencySelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency: String
    
    let currencies = ["USD ($)", "EUR (€)", "GBP (£)", "JPY (¥)", "CAD ($)", "AUD ($)", "LKR (Rs)"]
    
    var body: some View {
        NavigationStack {
            List(currencies, id: \.self) { curr in
                HStack {
                    Text(curr)
                        .foregroundColor(.primary)
                    Spacer()
                    if selectedCurrency == curr {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(red: 0.24, green: 0.65, blue: 0.38))
                            .fontWeight(.bold)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCurrency = curr
                    AppTheme.triggerHaptic(style: .light)
                    dismiss()
                }
            }
            .navigationTitle("Currencies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Appearance Selection Sheet

private struct AppearanceSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedScheme: String
    
    let schemes = [
        ("Dark Mode", "dark", "moon.fill"),
        ("Light Mode", "light", "sun.max.fill"),
        ("System Default", "system", "gearshape")
    ]
    
    var body: some View {
        NavigationStack {
            List(schemes, id: \.1) { name, key, icon in
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .foregroundColor(Color(red: 0.24, green: 0.65, blue: 0.38))
                        .frame(width: 24)
                    
                    Text(name)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if selectedScheme == key {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(red: 0.24, green: 0.65, blue: 0.38))
                            .fontWeight(.bold)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedScheme = key
                    AppTheme.triggerHaptic(style: .light)
                    dismiss()
                }
            }
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.height(260)])
    }
}

// MARK: - Security Modal View

private struct SecurityModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var biometricsEnabled = true
    @State private var twoFactorEnabled = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Biometrics & Access")) {
                    Toggle("Face ID / Touch ID Unlock", isOn: $biometricsEnabled)
                    Toggle("Two-Factor Authentication", isOn: $twoFactorEnabled)
                }
                
                Section(header: Text("Trade Protection")) {
                    HStack {
                        Text("Exchange Escrow Protection")
                        Spacer()
                        Text("Active")
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Application Security")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Devices Modal View

private struct DevicesModalView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Currently Active Devices")) {
                    HStack(spacing: 12) {
                        Image(systemName: "iphone.gen3")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0.24, green: 0.65, blue: 0.38))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("iPhone 16 Pro (This Device)")
                                .fontWeight(.semibold)
                            Text("Active Now • Colombo, Sri Lanka")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "laptopcomputer")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("MacBook Pro 14\"")
                                .fontWeight(.semibold)
                            Text("Active 2 hours ago • Safari")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Manage Devices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Change Password Modal View

private struct ChangePasswordModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPass = ""
    @State private var newPass = ""
    @State private var confirmPass = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Current Password")) {
                    SecureField("Enter current password", text: $currentPass)
                }
                
                Section(header: Text("New Password")) {
                    SecureField("Enter new password", text: $newPass)
                    SecureField("Confirm new password", text: $confirmPass)
                }
                
                Section {
                    Button("Update Password") {
                        showSuccessAlert = true
                        AppTheme.triggerNotificationHaptic(type: .success)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color(red: 0.24, green: 0.65, blue: 0.38))
                    .fontWeight(.bold)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Password Updated", isPresented: $showSuccessAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your account password has been successfully updated.")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserStore())
        .environmentObject(ItemStore())
        .environmentObject(SafeZoneStore())
}
