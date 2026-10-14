//
//  ProfileView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Pixel-perfect Profile interface matching user reference design with the official dark Xchange theme
//

import SwiftUI

public struct ProfileView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var safeZoneStore: SafeZoneStore
    
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("userLanguage") private var userLanguage: String = "English (US)"
    @AppStorage("userCurrency") private var userCurrency: String = "USD ($)"
    @AppStorage("userColorScheme") private var userColorScheme: String = "dark"
    
    @State private var showEditProfileSheet = false
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
                        
                        // 3. Settings Group 1: Preferences
                        groupOneCard
                            .padding(.horizontal, 20)
                        
                        // 4. Settings Group 2: Security & Devices
                        groupTwoCard
                            .padding(.horizontal, 20)
                        
                        // 5. Settings Group 3: Xchange Safety & Trust
                        groupThreeCard
                            .padding(.horizontal, 20)
                        
                        // 6. Log Out Button
                        logoutButton
                            .padding(.horizontal, 20)
                            .padding(.top, 6)
                    }
                    .padding(.bottom, 120) // Space for bottom custom tab bar
                }
            }
            .navigationBarHidden(true)
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
            // Circular Avatar
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 92, height: 92)
                
                if UIImage(named: "user_avatar_profile") != nil {
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
                    .stroke(accentGreen.opacity(0.35), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.25), radius: 6, y: 3)
            
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
    @State private var location: String = ""
    @State private var bio: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Full Name", text: $displayName)
                    TextField("Location", text: $location)
                }
                
                Section(header: Text("Bio & Trading Interests")) {
                    TextEditor(text: $bio)
                        .frame(height: 80)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                displayName = user.displayName
                location = user.location
                bio = user.bio
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        userStore.updateProfile(
                            displayName: displayName,
                            bio: bio,
                            location: location
                        )
                        AppTheme.triggerNotificationHaptic(type: .success)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium, .large])
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
