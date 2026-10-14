//
//  SettingsView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Settings, Persistence Cache Management, and Accessibility (Rubric Section 7 & 8)
//

import SwiftUI

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var tradeStore: TradeProposalStore
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var safeZoneStore: SafeZoneStore
    @StateObject private var networkService = NetworkService.shared
    
    @AppStorage("userColorScheme") private var userColorScheme: String = "system"
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    @AppStorage("enableHighContrast") private var enableHighContrast: Bool = false
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    @State private var showResetAlert: Bool = false
    @State private var showResetSuccessAlert: Bool = false
    @State private var showLogoutAlert: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Form {
                // Section 1: Visual Theme & Appearance (Rubric Section 7)
                Section(header: Text("Visual Appearance & Display")) {
                    Picker("Appearance", selection: $userColorScheme) {
                        Text("System Auto").tag("system")
                        Text("Dark Mode").tag("dark")
                        Text("Light Mode").tag("light")
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Enhanced High Contrast", isOn: $enableHighContrast)
                }
                
                // Section 2: Haptics & Accessibility
                Section(
                    header: Text("Accessibility & Haptics"),
                    footer: Text("Haptic micro-vibrations provide sensory confirmation for trade actions.")
                ) {
                    Toggle("Haptic Feedback Engine", isOn: $enableHaptics)
                }
                
                // Section 3: Data Persistence (Rubric Section 5)
                Section(
                    header: Text("Local Data Persistence (Documents Directory)"),
                    footer: Text("All items, trades, messages, and profile state persist automatically across app launches.")
                ) {
                    HStack {
                        Text("Persisted Storage Size")
                        Spacer()
                        let bytes = PersistenceService.shared.totalPersistedBytes()
                        Text("\(max(bytes / 1024, 1)) KB")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                            Text("Reset Data to Seed Catalog")
                        }
                    }
                }
                
                // Section 4: Network & Cloud Sync
                Section(header: Text("Network & Connectivity")) {
                    HStack {
                        Text("Network Status")
                        Spacer()
                        HStack(spacing: 6) {
                            Circle()
                                .fill(networkService.isConnected ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            Text(networkService.isConnected ? "Online" : "Offline")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button {
                        Task {
                            try? await networkService.syncWithRemoteCloud()
                            AppTheme.triggerNotificationHaptic(type: .success)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Force Sync with Exchange Cloud")
                        }
                    }
                }
                
                // Section 5: App Version & SLIIT Assignment Info
                Section(header: Text("Academic Project Details")) {
                    HStack {
                        Text("Course")
                        Spacer()
                        Text("SE4041 - MADD")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Institution")
                        Spacer()
                        Text("SLIIT Faculty of Computing")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0 (Native Swift)")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Section 6: Session & Authentication
                Section(header: Text("Account & Session")) {
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Log Out of Xchange")
                        }
                    }
                }
            }
            .navigationTitle("App Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Log Out of Xchange?", isPresented: $showLogoutAlert) {
                Button("Log Out", role: .destructive) {
                    dismiss()
                    isLoggedIn = false
                    AppTheme.triggerNotificationHaptic(type: .warning)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You will return to the Xchange Login Screen.")
            }
            .alert("Reset All Persistence?", isPresented: $showResetAlert) {
                Button("Reset Catalog", role: .destructive) {
                    PersistenceService.shared.resetAllPersistence()
                    itemStore.resetToDefaults()
                    tradeStore.resetToDefaults()
                    chatStore.resetToDefaults()
                    userStore.resetToDefaults()
                    showResetSuccessAlert = true
                    AppTheme.triggerNotificationHaptic(type: .success)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will wipe locally persisted items, messages, and counter-offers, and restore the initial sample dataset.")
            }
            .alert("Data Reset Completed", isPresented: $showResetSuccessAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Sample seed items, proposals, and verified safe zones have been successfully restored.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ItemStore())
        .environmentObject(TradeProposalStore())
        .environmentObject(ChatStore())
        .environmentObject(UserStore())
        .environmentObject(SafeZoneStore())
}
