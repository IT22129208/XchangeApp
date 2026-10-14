//
//  MainTabView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Navigation Structure and Adaptive Layouts with Custom Bottom Navigation Bar
//

import SwiftUI

public struct MainTabView: View {
    @EnvironmentObject var tradeStore: TradeProposalStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var itemStore: ItemStore
    
    @State private var selectedTab: Tab = .home
    @State private var showAddItemSheet: Bool = false
    
    public enum Tab: String, CaseIterable {
        case home = "Home"
        case browse = "Browse"
        case messages = "Messages"
        case profile = "Profile"
    }
    
    private let activeGreen = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let inactiveGray = Color.gray.opacity(0.85)
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main Tab Viewport
            Group {
                switch selectedTab {
                case .home:
                    HomeLandingView(
                        onNavigateToBrowse: {
                            selectedTab = .browse
                        },
                        onAddListing: {
                            showAddItemSheet = true
                        }
                    )
                case .browse:
                    ExploreFeedView()
                case .messages:
                    ProposalsListView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom 5-Item Navigation Bar Matching Reference Design
            customBottomNavigationBar
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAddItemSheet) {
            AddItemView()
        }
    }
    
    // MARK: - Custom Bottom Navigation Bar
    
    private var customBottomNavigationBar: some View {
        HStack(alignment: .bottom, spacing: 0) {
            // 1. Home Tab (Active Landing Page)
            tabBarItem(tab: .home, icon: "house.fill", label: "Home")
            
            // 2. Browse Tab (Explore Marketplace)
            tabBarItem(tab: .browse, icon: "text.magnifyingglass", label: "Browse")
            
            // 3. Center Elevated "Add Listing" Button
            Button {
                AppTheme.triggerHaptic(style: .medium)
                showAddItemSheet = true
            } label: {
                VStack(spacing: 3) {
                    ZStack {
                        Circle()
                            .fill(activeGreen)
                            .frame(width: 52, height: 52)
                            .shadow(color: activeGreen.opacity(0.4), radius: 8, y: 3)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(y: -10)
                    
                    Text("Add Listing")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(inactiveGray)
                        .offset(y: -6)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 4. Messages / Trades Tab
            tabBarItem(tab: .messages, icon: "bubble.left.fill", label: "Messages")
            
            // 5. Profile & Trust Tab
            tabBarItem(tab: .profile, icon: "person.fill", label: "Profile")
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(
            Color(red: 0.04, green: 0.05, blue: 0.06)
                .ignoresSafeArea(edges: .bottom)
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color.white.opacity(0.08)),
                    alignment: .top
                )
        )
    }
    
    private func tabBarItem(tab: Tab, icon: String, label: String) -> some View {
        let isSelected = selectedTab == tab
        
        return Button {
            AppTheme.triggerHaptic(style: .light)
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? activeGreen : inactiveGray)
                    .frame(height: 24)
                
                Text(label)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? activeGreen : inactiveGray)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserStore())
        .environmentObject(ItemStore())
        .environmentObject(TradeProposalStore())
        .environmentObject(ChatStore())
        .environmentObject(SafeZoneStore())
}
