//
//  ProfileView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements User Trust Profile, Wishlist Management, Settings & Mission Link
//

import SwiftUI

public struct ProfileView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var safeZoneStore: SafeZoneStore
    
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var newWishlistItem: String = ""
    @State private var showAddWishlistAlert = false
    @State private var showSettingsSheet = false
    @State private var showAboutMissionSheet = false
    @State private var showSafeZoneMap = false
    @State private var showLogoutAlert = false
    
    private var user: User {
        userStore.currentUser
    }
    
    private var myItemsCount: Int {
        itemStore.userItems(for: user.id).count
    }
    
    private var totalValuation: Double {
        itemStore.userItems(for: user.id).reduce(0) { $0 + $1.estimatedValue }
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Profile Header Card
                    profileHeaderCard
                    
                    // Stats Grid
                    statsGrid
                    
                    // Mission & Safe Zone Action Cards
                    quickHubActionCards
                    
                    // Badges Section
                    badgesSection
                    
                    // User's Wishlist ("Looking For")
                    wishlistSection
                    
                    // Trade Feedback & Reviews
                    reviewsSection
                    
                    // App Branding Footer
                    appFooter
                }
                .padding(.vertical, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Profile & Trust")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showLogoutAlert = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Log Out")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettingsSheet = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .alert("Log Out of Xchange?", isPresented: $showLogoutAlert) {
                Button("Log Out", role: .destructive) {
                    isLoggedIn = false
                    AppTheme.triggerNotificationHaptic(type: .warning)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out and return to the Xchange Login Screen?")
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsView()
            }
            .sheet(isPresented: $showAboutMissionSheet) {
                AboutMissionView()
            }
            .sheet(isPresented: $showSafeZoneMap) {
                SafeZoneMapView()
            }
            .alert("Add Wishlist Item", isPresented: $showAddWishlistAlert) {
                TextField("e.g. Vintage Camera Lens", text: $newWishlistItem)
                Button("Add") {
                    userStore.addWishlistItem(newWishlistItem)
                    newWishlistItem = ""
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    // MARK: - Subviews
    
    private var profileHeaderCard: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: user.avatar)
                    .font(.system(size: 64))
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 88, height: 88)
                    .background(AppTheme.primary.opacity(0.12))
                    .clipShape(Circle())
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            
            VStack(spacing: 4) {
                Text(user.displayName)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                Text("@\(user.username)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Text(user.bio)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.tradeAccent)
                    Text(user.location)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Text("•")
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.primary)
                    Text("Member since \(user.memberSince)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .padding(.horizontal)
    }
    
    private var statsGrid: some View {
        HStack(spacing: 12) {
            statCard(title: "Rating", value: String(format: "%.2f", user.rating), icon: "star.fill", iconColor: .yellow)
            statCard(title: "Trades Done", value: "\(user.tradesCompleted)", icon: "arrow.triangle.2.circlepath", iconColor: AppTheme.tradeAccent)
            statCard(title: "Barter Capital", value: "$\(Int(totalValuation))", icon: "banknote", iconColor: AppTheme.primary)
        }
        .padding(.horizontal)
    }
    
    private func statCard(title: String, value: String, icon: String, iconColor: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var quickHubActionCards: some View {
        HStack(spacing: 12) {
            Button {
                showAboutMissionSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.primary)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("About & Mission")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Target Audience & Purpose")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(14)
            }
            
            Button {
                showSafeZoneMap = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.tradeAccent)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Safe Zones")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Verified Meetup Hubs")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(14)
            }
        }
        .padding(.horizontal)
    }
    
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trust & Reputation Badges")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(user.badges) { badge in
                        HStack(spacing: 6) {
                            Image(systemName: badge.icon)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.primary)
                            
                            Text(badge.title)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppTheme.primary.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var wishlistSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Trader's Wishlist (Looking For)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                
                Spacer()
                
                Button {
                    showAddWishlistAlert = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(Array(user.wishlist.enumerated()), id: \.offset) { index, item in
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.tradeAccent)
                        
                        Text(item)
                            .font(.system(size: 13, weight: .medium))
                        
                        Spacer()
                        
                        Button {
                            userStore.removeWishlistItem(at: index)
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trade Feedback (\(user.reviews.count))")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                ForEach(user.reviews) { review in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: review.reviewerAvatar)
                                .foregroundColor(AppTheme.primary)
                            Text(review.reviewerName)
                                .font(.system(size: 13, weight: .bold))
                            
                            Spacer()
                            
                            HStack(spacing: 2) {
                                ForEach(0..<5) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 9))
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        
                        Text(review.comment)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Traded: \(review.tradedItemName)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(AppTheme.tradeAccent)
                            
                            Spacer()
                            
                            Text(review.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(14)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var appFooter: some View {
        VStack(spacing: 6) {
            XChangeBrandLogo(size: 22)
            Text("XChange v1.0.0 • SLIIT MADD SE4041")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserStore())
        .environmentObject(ItemStore())
        .environmentObject(SafeZoneStore())
}
