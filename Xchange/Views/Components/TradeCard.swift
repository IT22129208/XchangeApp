//
//  TradeCard.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//

import SwiftUI

public struct TradeCard: View {
    let proposal: TradeProposal
    var currentUser: User? = nil
    let currentUserId: UUID
    var onAccept: (() -> Void)? = nil
    var onDecline: (() -> Void)? = nil
    var onCounter: (() -> Void)? = nil
    var onComplete: (() -> Void)? = nil
    
    private var isIncoming: Bool {
        if let user = currentUser {
            return proposal.isIncoming(for: user)
        }
        return proposal.receiverId == currentUserId
    }
    
    private var partnerName: String {
        isIncoming ? proposal.initiatorName : proposal.receiverName
    }
    
    private var partnerAvatar: String {
        isIncoming ? proposal.initiatorAvatar : proposal.receiverAvatar
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Partner Info & Status Badge
            HStack(spacing: 10) {
                UserAvatarView(avatar: partnerAvatar, size: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(partnerName)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                        
                        if isIncoming {
                            Text("wants to trade with you")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                        } else {
                            Text("trade proposal")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(proposal.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Badge
                HStack(spacing: 4) {
                    Image(systemName: proposal.status.iconName)
                        .font(.system(size: 9, weight: .bold))
                    Text(proposal.status.rawValue)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .foregroundColor(proposal.status.badgeColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(proposal.status.badgeColor.opacity(0.12))
                .clipShape(Capsule())
            }
            
            Divider()
                .opacity(0.6)
            
            // Trade Items Comparison Row
            HStack(spacing: 12) {
                // Side 1: Offered Items
                VStack(alignment: .leading, spacing: 6) {
                    Text(isIncoming ? "THEY OFFER" : "YOU OFFER")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    ForEach(proposal.offeredItems) { item in
                        HStack(spacing: 6) {
                            Image(systemName: item.category.systemIcon)
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.primary)
                                .frame(width: 22, height: 22)
                                .background(AppTheme.primary.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            
                            Text(item.title)
                                .font(.system(size: 12, weight: .semibold))
                                .lineLimit(1)
                        }
                    }
                    
                    Text("LKR \(Int(proposal.totalOfferedValue))")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Center Swap Arrow Icon
                ZStack {
                    Circle()
                        .fill(Color(UIColor.tertiarySystemGroupedBackground))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                }
                
                // Side 2: Requested Items
                VStack(alignment: .trailing, spacing: 6) {
                    Text(isIncoming ? "FOR YOUR" : "FOR THEIR")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    ForEach(proposal.requestedItems) { item in
                        HStack(spacing: 6) {
                            Text(item.title)
                                .font(.system(size: 12, weight: .semibold))
                                .lineLimit(1)
                            
                            Image(systemName: item.category.systemIcon)
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.tradeAccent)
                                .frame(width: 22, height: 22)
                                .background(AppTheme.tradeAccent.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    
                    Text("LKR \(Int(proposal.totalRequestedValue))")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.tradeAccent)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical, 4)
            
            // Note if present
            if !proposal.note.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Text(proposal.note)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // Counter Offers Notice
            if !proposal.counterHistory.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 10, weight: .bold))
                    Text("\(proposal.counterHistory.count) counter-offer rounds negotiated")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(AppTheme.counterAccent)
            }
            
            // Deal Accepted & Quick Contact Actions
            if proposal.status == .accepted || proposal.status == .completed {
                let accepted = proposal.acceptedTrader(currentUser: currentUser)
                let partner = currentUser != nil ? proposal.partnerContact(currentUser: currentUser!) : accepted
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text(accepted.isCurrentUser ? "You accepted this deal" : "Deal accepted by \(accepted.name)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(proposal.meetingLocation ?? "Safe Zone")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 8) {
                        // Call Button
                        Button {
                            let clean = partner.phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                            if let url = URL(string: "tel://\(clean)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "phone.fill")
                                Text(partner.phone)
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .clipShape(Capsule())
                        }
                        
                        // WhatsApp Button
                        Button {
                            var clean = partner.phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                            if clean.hasPrefix("0") { clean = "94" + clean.dropFirst() }
                            if let url = URL(string: "https://wa.me/\(clean)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "message.fill")
                                Text("WhatsApp")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.15, green: 0.68, blue: 0.38))
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                    }
                }
                .padding(10)
                .background(Color.green.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.25), lineWidth: 1)
                )
            }
            
            // Quick Action Buttons if Incoming & Actionable
            if isIncoming && (proposal.status == .pending || proposal.status == .countered) {
                HStack(spacing: 8) {
                    // Decline
                    Button(action: { onDecline?() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                            Text("Decline")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // Counter-Offer
                    Button(action: { onCounter?() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.2.squarepath")
                                .font(.system(size: 11, weight: .bold))
                            Text("Counter")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.counterAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppTheme.counterAccent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // Accept
                    Button(action: { onAccept?() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                            Text("Accept")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppTheme.tradeGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.top, 4)
            }
            
            // Complete Deal Action Section for Active Deals (Requires both users to confirm)
            if proposal.status == .accepted {
                let userConfirmed = currentUser != nil ? proposal.hasUserConfirmedCompletion(user: currentUser!) : false
                let partnerConfirmed = currentUser != nil ? proposal.hasPartnerConfirmedCompletion(user: currentUser!) : false
                
                VStack(spacing: 8) {
                    // Two-Party Completion Status Indicator
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
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Complete Action Button
                    if userConfirmed {
                        Button {
                            AppTheme.triggerHaptic(style: .light)
                            onComplete?()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.badge.checkmark.fill")
                                    .font(.system(size: 13, weight: .bold))
                                Text("Awaiting \(partnerName) Confirmation (1/2)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.orange.opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Button {
                            AppTheme.triggerHaptic(style: .medium)
                            onComplete?()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 13, weight: .bold))
                                Text(partnerConfirmed ? "Partner Confirmed! Complete Deal (2/2)" : "Complete Deal (Both Must Confirm)")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: partnerConfirmed
                                        ? [Color(red: 0.15, green: 0.75, blue: 0.40), Color(red: 0.10, green: 0.58, blue: 0.30)]
                                        : [Color(red: 0.20, green: 0.65, blue: 0.35), Color(red: 0.12, green: 0.52, blue: 0.28)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: Color.green.opacity(0.35), radius: 5, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(proposal.status == .accepted ? AppTheme.tradeAccent.opacity(0.3) : Color.primary.opacity(0.06), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    let proposalStore = TradeProposalStore()
    return VStack {
        TradeCard(
            proposal: proposalStore.proposals.first!,
            currentUserId: UserStore.currentUserId
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
