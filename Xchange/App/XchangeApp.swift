//
//  XchangeApp.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter & Trade App
//  Adheres to SLIIT SE4041 MADD Assignment 02 Specification
//

import SwiftUI

@main
public struct XchangeApp: App {
    @StateObject private var userStore = UserStore()
    @StateObject private var itemStore = ItemStore()
    @StateObject private var tradeStore = TradeProposalStore()
    @StateObject private var chatStore = ChatStore()
    @StateObject private var safeZoneStore = SafeZoneStore()
    
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("userColorScheme") private var userColorScheme: String = "system"
    
    @State private var showSplash: Bool = true
    
    public init() {
        // Support UI testing launch arguments
        if ProcessInfo.processInfo.arguments.contains("--uitesting-logged-in") {
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            _showSplash = State(initialValue: false)
        }
        if ProcessInfo.processInfo.arguments.contains("--skip-splash") {
            _showSplash = State(initialValue: false)
        }
    }
    
    public var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView(duration: 4.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(10)
                } else {
                    Group {
                        if isLoggedIn {
                            MainTabView()
                        } else {
                            LoginView(isLoggedIn: $isLoggedIn)
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .environmentObject(userStore)
            .environmentObject(itemStore)
            .environmentObject(tradeStore)
            .environmentObject(chatStore)
            .environmentObject(safeZoneStore)
            .preferredColorScheme(resolvedColorScheme)
        }
    }
    
    private var resolvedColorScheme: ColorScheme? {
        switch userColorScheme {
        case "dark": return .dark
        case "light": return .light
        default: return nil // System default
        }
    }
}

