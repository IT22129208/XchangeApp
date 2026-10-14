//
//  AboutMissionView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Purpose, Target Audience & Circular Economy Mission (Rubric Section 1)
//

import SwiftUI

public struct AboutMissionView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    // Hero Brand Header
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            XChangeBrandLogo(size: 32, showText: true)
                            Spacer()
                            Text("v1.0.0 (Build 1)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Peer-to-Peer Cashless Barter & Sustainable Circular Trade")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.primaryGradient)
                    }
                    .padding(.top, 8)
                    
                    Divider()
                    
                    // 1. Real-World Problem Solved
                    missionSection(
                        title: "1. The Problem We Solve",
                        icon: "exclamationmark.triangle.fill",
                        color: AppTheme.warningAccent,
                        bodyText: "In modern consumer markets, millions of perfectly functional electronics, cameras, music equipment, gaming consoles, and apparel sit unused in closets. Selling through traditional second-hand apps imposes hefty seller fees (10-15%), shipping risks, chargeback scams, and cash depreciation. XChange solves this by reviving 100% cashless barter trades powered by algorithmic value parity balancing."
                    )
                    
                    // 2. Clear Purpose & Core Value Proposition
                    missionSection(
                        title: "2. Clear Purpose & Service",
                        icon: "leaf.fill",
                        color: AppTheme.tradeAccent,
                        bodyText: "XChange provides an intuitive, trustworthy ecosystem where community members trade physical gear directly without spending currency. We champion the zero-waste circular economy, minimizing electronic waste while enabling creators, students, and collectors to upgrade their gear seamlessly."
                    )
                    
                    // 3. Target Audience & Needs Justification
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(AppTheme.primary)
                            Text("3. Target Audience & Personas")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        
                        VStack(spacing: 10) {
                            personaCard(
                                title: "University Students & Tech Learners",
                                subtitle: "SLIIT Computing & Engineering Undergraduates",
                                desc: "Budget-conscious students who need gear upgrades (monitors, keyboards, audio interfaces) without spending disposable income."
                            )
                            
                            personaCard(
                                title: "Creative Professionals & Gearheads",
                                subtitle: "Photographers, Beatmakers & Audio Engineers",
                                desc: "Creators who frequently cycle lenses, synthesizers, and microphones seeking fair 1-to-1 parity trades."
                            )
                            
                            personaCard(
                                title: "Retro Collectors & Enthusiasts",
                                subtitle: "Vintage Console & Vinyl Devotees",
                                desc: "Traders seeking rare items that cannot easily be priced with fiat currency."
                            )
                        }
                    }
                    
                    // 4. Emerging Tech Pillars
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "cpu.fill")
                                .foregroundColor(.purple)
                            Text("4. Technical Innovation Stack")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        
                        VStack(spacing: 8) {
                            techPillarRow(
                                title: "Apple Vision & CoreML",
                                subtitle: "AI camera-based item identification, wear analysis & fair value range estimation."
                            )
                            techPillarRow(
                                title: "MapKit Safe Exchange Zones",
                                subtitle: "Police lots & campus-verified safe barter meetup hubs with GPS distance calculations."
                            )
                            techPillarRow(
                                title: "ARKit 3D Item Inspection",
                                subtitle: "Simulated augmented reality 1:1 physical item inspection before accepting trades."
                            )
                        }
                    }
                    
                    // Academic Credits
                    VStack(spacing: 6) {
                        Text("Developed for SLIIT Faculty of Computing")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                        Text("BSc (Hons) in Information Technology — MADD SE4041")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                }
                .padding(20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("About XChange")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func missionSection(title: String, icon: String, color: Color, bodyText: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            
            Text(bodyText)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(14)
        .modernCard()
    }
    
    private func personaCard(title: String, subtitle: String, desc: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
            Text(subtitle)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppTheme.primary)
            Text(desc)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func techPillarRow(title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.tradeAccent)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

#Preview {
    AboutMissionView()
}
