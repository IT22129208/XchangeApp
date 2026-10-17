//
//  ProposalDetailView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Trade Negotiation Details with Interactive Barter Gauge & Safe Zone MapKit Integration
//

import SwiftUI

public struct ProposalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tradeStore: TradeProposalStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var safeZoneStore: SafeZoneStore
    
    let proposalId: UUID
    
    @State private var showCounterOfferSheet = false
    @State private var showChatView = false
    @State private var showAcceptAlert = false
    @State private var showDeclineAlert = false
    @State private var showCompleteAlert = false
    @State private var showSafeZonePicker = false
    @State private var showConfetti = false
    @State private var copiedFeedbackText: String? = nil
    
    private var proposal: TradeProposal? {
        tradeStore.getProposal(byId: proposalId)
    }
    
    private var isIncoming: Bool {
        guard let p = proposal else { return false }
        return p.isIncoming(for: userStore.currentUser)
    }
    
    private var partnerName: String {
        guard let p = proposal else { return "" }
        return isIncoming ? p.initiatorName : p.receiverName
    }
    
    public var body: some View {
        ZStack {
            Group {
                if let p = proposal {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            // Status Card Banner
                            statusBanner(p)
                            
                            // Accepted Trader & Contact Details (when deal is accepted or completed)
                            if p.status == .accepted || p.status == .completed {
                                acceptedTraderContactSection(p)
                            }
                            
                            // Trade Items Comparison
                            tradeItemsSection(p)
                            
                            // Interactive Barter Parity Scale Gauge with DragGesture
                            InteractiveBarterScaleGauge(
                                offeredValue: p.totalOfferedValue,
                                requestedValue: p.totalRequestedValue,
                                isInteractive: true
                            )
                            
                            // Safe Meetup Zone Info with Apple Maps Integration
                            meetupLocationSection(p)
                            
                            // Counter-Offer History if multiple rounds
                            if !p.counterHistory.isEmpty {
                                counterHistorySection(p)
                            }
                            
                            // In-Trade Chat Teaser Card
                            chatTeaserCard(p)
                        }
                        .padding(20)
                        .padding(.bottom, 100)
                    }
                    .safeAreaInset(edge: .bottom) {
                        actionButtonsBar(p)
                    }
                } else {
                    Text("Trade proposal not found.")
                        .foregroundColor(.secondary)
                }
            }
            
            // Celebratory Confetti Burst
            if showConfetti {
                ConfettiView()
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Trade Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCounterOfferSheet) {
            if let p = proposal {
                CounterOfferModalView(proposal: p)
            }
        }
        .sheet(isPresented: $showSafeZonePicker) {
            SafeZoneMapView { zone in
                tradeStore.setMeetingLocation(proposalId: proposalId, location: "\(zone.name) (\(zone.subtitle))")
            }
        }
        .navigationDestination(isPresented: $showChatView) {
            if let p = proposal {
                TradeChatView(proposal: p)
            }
        }
        .alert("Accept Barter Deal?", isPresented: $showAcceptAlert) {
            Button("Confirm & Accept", role: .none) {
                if let p = proposal {
                    tradeStore.acceptProposal(proposalId: p.id, acceptedBy: userStore.currentUser)
                    withAnimation {
                        showConfetti = true
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("By accepting, you agree to exchange the selected items without cash. Both parties can coordinate the meetup location.")
        }
        .alert("Decline Proposal?", isPresented: $showDeclineAlert) {
            Button("Decline", role: .destructive) {
                if let p = proposal {
                    tradeStore.declineProposal(proposalId: p.id)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to decline this trade proposal?")
        }
        .alert("Complete Trade?", isPresented: $showCompleteAlert) {
            if let p = proposal {
                let userConfirmed = p.hasUserConfirmedCompletion(user: userStore.currentUser)
                let partnerConfirmed = p.hasPartnerConfirmedCompletion(user: userStore.currentUser)
                
                if userConfirmed {
                    Button("Simulate \(partnerName)'s Confirmation (Demo)") {
                        tradeStore.completeTrade(proposalId: p.id)
                        withAnimation {
                            showConfetti = true
                        }
                    }
                    Button("OK, I'll Wait for Partner", role: .cancel) {}
                } else {
                    Button(partnerConfirmed ? "Finalize Deal (2/2)" : "Confirm My Handoff (1/2)") {
                        let result = tradeStore.confirmCompletion(proposalId: p.id, by: userStore.currentUser)
                        if result.bothCompleted {
                            withAnimation {
                                showConfetti = true
                            }
                        }
                    }
                    
                    if !partnerConfirmed {
                        Button("Simulate Both Confirmed (Demo)") {
                            tradeStore.completeTrade(proposalId: p.id)
                            withAnimation {
                                showConfetti = true
                            }
                        }
                    }
                    
                    Button("Cancel", role: .cancel) {}
                }
            }
        } message: {
            if let p = proposal {
                let userConfirmed = p.hasUserConfirmedCompletion(user: userStore.currentUser)
                let partnerConfirmed = p.hasPartnerConfirmedCompletion(user: userStore.currentUser)
                
                if userConfirmed {
                    Text("You have already confirmed your part (1/2). Both users must press the complete button for the trade to be completed. Waiting for \(partnerName) to confirm on their phone.")
                } else if partnerConfirmed {
                    Text("\(partnerName) has already confirmed the handoff (1/2)! Tap Finalize Deal to confirm your side and complete the trade.")
                } else {
                    Text("Confirm that you have safely met with \(partnerName) and exchanged your items. Both users must press the complete button for the trade to be completed.")
                }
            } else {
                Text("Both users must press the complete button for the trade to be completed.")
            }
        }
    }
    
    // MARK: - Subviews
    
    private func statusBanner(_ p: TradeProposal) -> some View {
        HStack(spacing: 12) {
            Image(systemName: p.status.iconName)
                .font(.system(size: 24))
                .foregroundColor(p.status.badgeColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(p.status.rawValue)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(p.status.badgeColor)
                
                Text(statusSubtitle(for: p))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(14)
        .background(p.status.badgeColor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Accepted Trade & Contact Details Section
    
    @ViewBuilder
    private func acceptedTraderContactSection(_ p: TradeProposal) -> some View {
        let accepted = p.acceptedTrader(currentUser: userStore.currentUser)
        let partner = p.partnerContact(currentUser: userStore.currentUser)
        
        VStack(alignment: .leading, spacing: 14) {
            // Header with Accepted Status
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    if accepted.isCurrentUser {
                        Text("You Accepted This Trade Deal")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Agreement confirmed with \(partner.name). Contact them to arrange handoff.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(accepted.name) Accepted Your Offer!")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                        Text("Trade deal accepted on \(p.acceptedAt?.formatted(date: .abbreviated, time: .shortened) ?? "recent date"). Contact \(accepted.name) below.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.bottom, 2)
            
            Divider()
            
            // Accepted Person / Partner Profile Banner
            HStack(spacing: 12) {
                UserAvatarView(
                    avatar: partner.avatar,
                    size: 48,
                    showBorder: true,
                    borderColor: Color.green.opacity(0.5),
                    borderWidth: 2
                )
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(partner.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                    
                    HStack(spacing: 6) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", partner.rating))
                                .font(.system(size: 11, weight: .bold))
                        }
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("Verified Trader")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.primary)
                        Text("\(partner.district) District • \(partner.location)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
            
            // Contact Channels
            VStack(spacing: 10) {
                // 1. Phone Card with Direct Action Buttons
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(AppTheme.primary)
                        Text("Phone / WhatsApp")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button {
                            copyToClipboard(text: partner.phone, label: "Phone number")
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName: copiedFeedbackText == "Phone number" ? "checkmark" : "doc.on.doc")
                                Text(copiedFeedbackText == "Phone number" ? "Copied!" : "Copy")
                            }
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(copiedFeedbackText == "Phone number" ? .green : AppTheme.primary)
                        }
                    }
                    
                    Text(partner.phone)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    // One-Tap Quick Actions
                    HStack(spacing: 8) {
                        // Call
                        Button {
                            makePhoneCall(phone: partner.phone)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "phone.fill")
                                Text("Call")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        // WhatsApp
                        Button {
                            openWhatsApp(phone: partner.phone, partnerName: partner.name)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "message.fill")
                                Text("WhatsApp")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.15, green: 0.68, blue: 0.38))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        // SMS
                        Button {
                            sendSMS(phone: partner.phone)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "ellipsis.message.fill")
                                Text("SMS")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(12)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // 2. Email Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(AppTheme.tradeAccent)
                        Text("Email Address")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button {
                            copyToClipboard(text: partner.email, label: "Email")
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName: copiedFeedbackText == "Email" ? "checkmark" : "doc.on.doc")
                                Text(copiedFeedbackText == "Email" ? "Copied!" : "Copy")
                            }
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(copiedFeedbackText == "Email" ? .green : AppTheme.tradeAccent)
                        }
                    }
                    
                    HStack {
                        Text(partner.email)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button {
                            sendEmail(email: partner.email, partnerName: partner.name, proposal: p)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "paperplane.fill")
                                Text("Email")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.tradeAccent)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(12)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // 3. Meetup coordination note & in-app chat button
                HStack(spacing: 10) {
                    Button {
                        showChatView = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                            Text("Open In-Trade Chat")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppTheme.primary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        showSafeZonePicker = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "map.fill")
                            Text("Safe Zones")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.tradeAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppTheme.tradeAccent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.green.opacity(0.4), lineWidth: 1.5)
        )
        .shadow(color: Color.green.opacity(0.08), radius: 10, y: 4)
    }
    
    private func makePhoneCall(phone: String) {
        let clean = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "tel://\(clean)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendSMS(phone: String) {
        let clean = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "sms:\(clean)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openWhatsApp(phone: String, partnerName: String) {
        var clean = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if clean.hasPrefix("0") {
            clean = "94" + clean.dropFirst()
        }
        let message = "Hi \(partnerName), this is regarding our accepted trade on Xchange!".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://wa.me/\(clean)?text=\(message)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendEmail(email: String, partnerName: String, proposal: TradeProposal) {
        let subject = "Xchange Trade Agreement: \(proposal.offeredItems.first?.title ?? "Items")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = "Hi \(partnerName),\n\nOur trade offer on Xchange has been accepted! Let's coordinate our meetup at the safe barter zone.\n\nThanks!".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:\(email)?subject=\(subject)&body=\(body)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func copyToClipboard(text: String, label: String) {
        UIPasteboard.general.string = text
        copiedFeedbackText = label
        AppTheme.triggerNotificationHaptic(type: .success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedFeedbackText = nil
        }
    }
    
    private func statusSubtitle(for p: TradeProposal) -> String {
        switch p.status {
        case .pending:
            return isIncoming ? "Awaiting your decision or counter-offer" : "Awaiting response from \(p.receiverName)"
        case .countered:
            return "Active counter-offer proposal under review"
        case .accepted:
            let userConfirmed = p.hasUserConfirmedCompletion(user: userStore.currentUser)
            let partnerConfirmed = p.hasPartnerConfirmedCompletion(user: userStore.currentUser)
            if userConfirmed {
                return "You confirmed (1/2) • Awaiting \(partnerName) confirmation"
            } else if partnerConfirmed {
                return "\(partnerName) confirmed (1/2)! Tap Complete to finalize"
            } else {
                return "Deal confirmed! Both traders must press Complete after meetup (0/2)"
            }
        case .declined:
            return "This proposal was declined"
        case .completed:
            return "Items exchanged and trade finalized"
        case .cancelled:
            return "Trade proposal cancelled"
        }
    }
    
    private func tradeItemsSection(_ p: TradeProposal) -> some View {
        VStack(spacing: 14) {
            // Offered Block
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(isIncoming ? "\(p.initiatorName.uppercased()) OFFERS" : "YOU OFFER")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Total: LKR \(Int(p.totalOfferedValue))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                }
                
                ForEach(p.offeredItems) { item in
                    itemRow(item: item, accentColor: AppTheme.primary)
                }
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Exchange Icon Divider
            HStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 1)
                
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.tradeAccent)
                
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 1)
            }
            
            // Requested Block
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(isIncoming ? "IN EXCHANGE FOR YOUR" : "\(p.receiverName.uppercased()) GIVES")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Total: LKR \(Int(p.totalRequestedValue))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.tradeAccent)
                }
                
                ForEach(p.requestedItems) { item in
                    itemRow(item: item, accentColor: AppTheme.tradeAccent)
                }
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private func itemRow(item: Item, accentColor: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.systemIcon)
                .font(.system(size: 18))
                .foregroundColor(accentColor)
                .frame(width: 36, height: 36)
                .background(accentColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(item.condition.rawValue)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(item.formattedValue)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(accentColor)
        }
    }
    
    private func meetupLocationSection(_ p: TradeProposal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "shield.checkered")
                        .foregroundColor(AppTheme.tradeAccent)
                    Text("Designated Safe Meetup Zone")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                
                Spacer()
                
                Button {
                    showSafeZonePicker = true
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "map.fill")
                        Text("Change on Map")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                }
            }
            
            HStack(spacing: 10) {
                SafeZoneRadarBadge(zoneName: p.meetingLocation ?? "SLIIT Safe Trade Hub", isVerified: true)
                Spacer()
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    private func counterHistorySection(_ p: TradeProposal) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(AppTheme.counterAccent)
                Text("Negotiation History (\(p.counterHistory.count) Rounds)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            
            ForEach(Array(p.counterHistory.enumerated()), id: \.offset) { index, counter in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Round \(index + 1): \(counter.proposedByName)")
                            .font(.system(size: 12, weight: .bold))
                        Spacer()
                        Text(counter.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    if !counter.note.isEmpty {
                        Text("\"\(counter.note)\"")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding(10)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private func chatTeaserCard(_ p: TradeProposal) -> some View {
        Button {
            showChatView = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("In-Trade Discussion")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Chat directly with \(partnerName) to clarify condition or meetup times")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func actionButtonsBar(_ p: TradeProposal) -> some View {
        VStack(spacing: 0) {
            Divider()
            
            Group {
                if p.status == .pending || p.status == .countered {
                    negotiationActionButtons(p)
                } else if p.status == .accepted {
                    activeDealCompletionBar(p)
                } else {
                    Text("Trade is \(p.status.rawValue.lowercased())")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .background(.ultraThinMaterial)
        }
    }
    
    private func negotiationActionButtons(_ p: TradeProposal) -> some View {
        HStack(spacing: 10) {
            // Decline
            Button {
                showDeclineAlert = true
            } label: {
                Text("Decline")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            // Counter
            Button {
                showCounterOfferSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.2.squarepath")
                    Text("Counter")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.counterAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(AppTheme.counterAccent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            // Accept
            Button {
                showAcceptAlert = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                    Text("Accept")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(AppTheme.tradeGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
    
    private func activeDealCompletionBar(_ p: TradeProposal) -> some View {
        let userConfirmed = p.hasUserConfirmedCompletion(user: userStore.currentUser)
        let partnerConfirmed = p.hasPartnerConfirmedCompletion(user: userStore.currentUser)
        
        return VStack(spacing: 8) {
            // Two-Party Completion Status
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: userConfirmed ? "checkmark.circle.fill" : "circle.dashed")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(userConfirmed ? .green : .secondary)
                    Text("You (1/2)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(userConfirmed ? .primary : .secondary)
                }
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.6))
                
                HStack(spacing: 4) {
                    Image(systemName: partnerConfirmed ? "checkmark.circle.fill" : "circle.dashed")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(partnerConfirmed ? .green : .secondary)
                    Text("\(partnerName) (2/2)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(partnerConfirmed ? .primary : .secondary)
                }
                
                Spacer()
                
                Text(userConfirmed ? "Waiting for Partner" : (partnerConfirmed ? "Partner Confirmed!" : "Both Must Confirm"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(partnerConfirmed && !userConfirmed ? Color(red: 0.95, green: 0.35, blue: 0.2) : (userConfirmed ? Color.orange : .secondary))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Button
            Button {
                showCompleteAlert = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: userConfirmed ? "clock.badge.checkmark.fill" : "checkmark.seal.fill")
                    Text(userConfirmed ? "Awaiting \(partnerName) Confirmation (1/2)" : (partnerConfirmed ? "Partner Confirmed! Finalize Trade (2/2)" : "Complete Deal (Both Must Confirm)"))
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(completeButtonGradient(userConfirmed: userConfirmed, partnerConfirmed: partnerConfirmed))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
    
    private func completeButtonGradient(userConfirmed: Bool, partnerConfirmed: Bool) -> LinearGradient {
        if userConfirmed {
            return LinearGradient(
                colors: [Color.orange.opacity(0.9), Color.orange.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else if partnerConfirmed {
            return LinearGradient(
                colors: [Color(red: 0.15, green: 0.75, blue: 0.40), Color(red: 0.10, green: 0.58, blue: 0.30)],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return AppTheme.tradeGradient
        }
    }
}

#Preview {
    NavigationStack {
        ProposalDetailView(proposalId: TradeProposalStore.sampleIncomingProposalId)
            .environmentObject(TradeProposalStore())
            .environmentObject(UserStore())
            .environmentObject(ChatStore())
            .environmentObject(SafeZoneStore())
    }
}
