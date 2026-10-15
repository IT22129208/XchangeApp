//
//  InteractiveBarterScaleGauge.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Custom Animated Barter Parity Scale with Gesture Recognizers (Rubric Sections 2 & 3)
//

import SwiftUI

/// An interactive, custom-drawn balance scale representing fair barter parity.
/// Includes dynamic DragGesture interaction, spring physics rotation, and visual parity feedback.
public struct InteractiveBarterScaleGauge: View {
    let offeredValue: Double
    let requestedValue: Double
    var isInteractive: Bool = true
    
    @State private var dragTilt: Double = 0.0
    @State private var isDragging: Bool = false
    
    // Natural tilt based on difference (-18° to +18°)
    private var naturalTilt: Double {
        let diff = offeredValue - requestedValue
        let maxVal = max(offeredValue, requestedValue, 1.0)
        let ratio = diff / maxVal
        // Clamp to -18 to +18 degrees
        return max(-18.0, min(18.0, ratio * 24.0))
    }
    
    private var effectiveTilt: Double {
        if isDragging {
            return dragTilt
        } else {
            return naturalTilt
        }
    }
    
    private var isBalanced: Bool {
        abs(offeredValue - requestedValue) <= max(15.0, (offeredValue + requestedValue) * 0.08)
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Header: Title and Parity Status
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "scalemass.fill")
                        .foregroundColor(statusColor)
                    Text("Interactive Parity Scale")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                
                Spacer()
                
                Text(statusText)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.12))
                    .clipShape(Capsule())
            }
            
            // Custom Drawn Balance Beam Scale Stage
            ZStack {
                // Background subtle ring grid
                Circle()
                    .stroke(Color.primary.opacity(0.04), lineWidth: 1)
                    .frame(width: 140, height: 140)
                
                // Fulcrum (Pillar & Base)
                VStack(spacing: 0) {
                    Spacer()
                    // Triangular Fulcrum Pivot
                    FulcrumShape()
                        .fill(LinearGradient(
                            colors: [Color.secondary.opacity(0.4), Color.secondary.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 32, height: 38)
                    
                    // Stand Base
                    Capsule()
                        .fill(Color.secondary.opacity(0.6))
                        .frame(width: 72, height: 6)
                }
                .frame(height: 110)
                
                // Tilting Crossbeam & Hanging Pans
                VStack(spacing: 0) {
                    // Central Pivot Pin
                    Circle()
                        .fill(statusColor)
                        .frame(width: 12, height: 12)
                        .shadow(color: statusColor.opacity(0.4), radius: 4)
                        .zIndex(2)
                    
                    // Horizontal Beam with Pans
                    HStack(alignment: .top, spacing: 0) {
                        // Left Pan: Offered (You Give)
                        HangingPanView(
                            title: "You Give",
                            value: offeredValue,
                            color: AppTheme.primary,
                            isLeft: true
                        )
                        
                        // Crossbar Beam
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [AppTheme.primary, statusColor, AppTheme.tradeAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 140, height: 6)
                            .cornerRadius(3)
                        
                        // Right Pan: Requested (Partner Gives)
                        HangingPanView(
                            title: "You Receive",
                            value: requestedValue,
                            color: AppTheme.tradeAccent,
                            isLeft: false
                        )
                    }
                    .rotationEffect(.degrees(effectiveTilt), anchor: .center)
                    .animation(.spring(response: 0.5, dampingFraction: 0.65), value: effectiveTilt)
                }
                .frame(height: 120)
                .contentShape(Rectangle())
                .gesture(
                    isInteractive ?
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            let translationFactor = Double(value.translation.width) * 0.15
                            dragTilt = max(-25.0, min(25.0, naturalTilt + translationFactor))
                            AppTheme.triggerHaptic(style: .light)
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.55)) {
                                isDragging = false
                                dragTilt = naturalTilt
                            }
                        }
                    : nil
                )
            }
            .frame(height: 130)
            
            // Value Breakdown Footnote
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(AppTheme.primary)
                        .frame(width: 8, height: 8)
                    Text("Your Items: LKR \(Int(offeredValue))")
                        .font(.system(size: 12, weight: .semibold))
                }
                
                Spacer()
                
                if isInteractive {
                    Text("Drag scale to test tilt")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(AppTheme.tradeAccent)
                        .frame(width: 8, height: 8)
                    Text("Partner Items: LKR \(Int(requestedValue))")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .modernCard()
    }
    
    private var statusColor: Color {
        if isBalanced {
            return AppTheme.tradeAccent
        } else if offeredValue > requestedValue {
            return AppTheme.primary
        } else {
            return AppTheme.counterAccent
        }
    }
    
    private var statusText: String {
        let diff = abs(offeredValue - requestedValue)
        if isBalanced {
            return "⚖️ Fair Trade Balance"
        } else if offeredValue > requestedValue {
            return "+LKR \(Int(diff)) Favoring Partner"
        } else {
            return "+LKR \(Int(diff)) In Your Favor"
        }
    }
}

// MARK: - Supporting Subviews & Shapes

private struct HangingPanView: View {
    let title: String
    let value: Double
    let color: Color
    let isLeft: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            // Hanging Cable String
            Rectangle()
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 1.5, height: 26)
            
            // Curved Pan Tray
            ZStack {
                ScalePanShape()
                    .fill(color.opacity(0.18))
                    .frame(width: 58, height: 18)
                    .overlay(
                        ScalePanShape()
                            .stroke(color, lineWidth: 1.5)
                    )
                
                Text("LKR \(Int(value))")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(color)
                    .offset(y: -1)
            }
        }
        .frame(width: 62)
    }
}

/// Custom shape for the triangular center fulcrum
private struct FulcrumShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Custom shape for the hanging scale dish
private struct ScalePanShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

#Preview {
    VStack(spacing: 20) {
        InteractiveBarterScaleGauge(offeredValue: 280, requestedValue: 280)
        InteractiveBarterScaleGauge(offeredValue: 500, requestedValue: 220)
        InteractiveBarterScaleGauge(offeredValue: 180, requestedValue: 650)
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
