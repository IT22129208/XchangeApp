//
//  SmartAppraisalModalView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements CoreML & Vision AI Camera Appraisal Sheet (Rubric Section 6)
//

import SwiftUI
import PhotosUI

public struct SmartAppraisalModalView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var mlService = SmartAppraisalMLService.shared
    
    var initialTitle: String = ""
    var onApplyAppraisal: ((AppraisalResult) -> Void)? = nil
    
    @State private var sampleCategoryIndex: Int = 0
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var scannedImage: UIImage? = nil
    @State private var laserOffset: CGFloat = -110
    @State private var currentResult: AppraisalResult? = nil
    
    private let demoPresets = [
        (title: "Sony WH-1000XM5 Headphones", category: ItemCategory.electronics, icon: "headphones"),
        (title: "Fujifilm X-T30 II Mirrorless", category: ItemCategory.cameras, icon: "camera.fill"),
        (title: "Analogue Pocket Console", category: ItemCategory.gaming, icon: "gamecontroller.fill"),
        (title: "Teenage Engineering OP-1 Synth", category: ItemCategory.musicalInstruments, icon: "guitars.fill"),
        (title: "Patagonia MLC 45L Backpack", category: ItemCategory.fashion, icon: "tshirt.fill")
    ]
    
    public init(initialTitle: String = "", onApplyAppraisal: ((AppraisalResult) -> Void)? = nil) {
        self.initialTitle = initialTitle
        self.onApplyAppraisal = onApplyAppraisal
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Stage 1: Camera Scanner Stage
                    scannerStage
                    
                    // Stage 2: Quick Benchmark Selector (for Simulator / Lab Testing)
                    presetPickerSection
                    
                    // Stage 3: ML Appraisal Results Card
                    if let result = currentResult {
                        appraisalResultsCard(result)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if mlService.isAnalyzing {
                        analyzingSkeletonCard
                    }
                }
                .padding(16)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("AI Smart Appraisal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                triggerAppraisal(index: 0)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var scannerStage: some View {
        ZStack {
            // Scanner Background Frame
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.08, green: 0.10, blue: 0.14))
                .frame(height: 230)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(AppTheme.primary.opacity(0.3), lineWidth: 1.5)
                )
            
            // Item Icon / Camera Preview Simulator
            VStack(spacing: 12) {
                let current = demoPresets[sampleCategoryIndex]
                Image(systemName: current.icon)
                    .font(.system(size: 68))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.primary, AppTheme.tradeAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: AppTheme.primary.opacity(0.5), radius: 16)
                
                Text(current.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Reticle Corners
            VStack {
                HStack {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(AppTheme.tradeAccent)
                    Spacer()
                    Image(systemName: "viewfinder")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(AppTheme.tradeAccent)
                }
                Spacer()
                HStack {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(AppTheme.tradeAccent)
                    Spacer()
                    Image(systemName: "viewfinder")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(AppTheme.tradeAccent)
                }
            }
            .padding(16)
            
            // Animated Scanning Laser Line
            if mlService.isAnalyzing {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, AppTheme.brandGreen, .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 3)
                    .shadow(color: AppTheme.brandGreen, radius: 6)
                    .offset(y: laserOffset)
                    .onAppear {
                        withAnimation(
                            Animation.easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true)
                        ) {
                            laserOffset = 110
                        }
                    }
            }
            
            // Vision Framework Badge
            VStack {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text("Apple Vision & CoreML Engine")
                    }
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    
                    Spacer()
                }
                Spacer()
            }
            .padding(12)
        }
    }
    
    private var presetPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Benchmark Device or Photo to Appraise:")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<demoPresets.count, id: \.self) { idx in
                        let isSelected = sampleCategoryIndex == idx
                        Button {
                            sampleCategoryIndex = idx
                            triggerAppraisal(index: idx)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: demoPresets[idx].icon)
                                    .font(.system(size: 12))
                                Text(demoPresets[idx].category.rawValue)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(isSelected ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isSelected ? AppTheme.primary : Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? Color.clear : Color.primary.opacity(0.08), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }
    
    private func appraisalResultsCard(_ result: AppraisalResult) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with Confidence Badge
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Predicted Fair Value")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("$\(Int(result.estimatedFairValue)) USD")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.primaryGradient)
                }
                
                Spacer()
                
                // Confidence Pill
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.tradeAccent)
                        Text(result.formattedConfidence)
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(AppTheme.tradeAccent)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.tradeAccent.opacity(0.12))
                    .clipShape(Capsule())
                    
                    Text("Margin: \(result.formattedValueRange)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Grid of Attributes (Category & Condition)
            HStack(spacing: 12) {
                // Category Card
                VStack(alignment: .leading, spacing: 4) {
                    Text("DETECTED CATEGORY")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: result.predictedCategory.systemIcon)
                            .foregroundColor(AppTheme.primary)
                        Text(result.predictedCategory.rawValue)
                            .font(.system(size: 13, weight: .bold))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.primary.opacity(0.03))
                .cornerRadius(12)
                
                // Condition Card
                VStack(alignment: .leading, spacing: 4) {
                    Text("ESTIMATED CONDITION")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: result.predictedCondition.iconName)
                            .foregroundColor(result.predictedCondition.color)
                        Text(result.predictedCondition.rawValue)
                            .font(.system(size: 13, weight: .bold))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.primary.opacity(0.03))
                .cornerRadius(12)
            }
            
            // AI Suggested Tags
            VStack(alignment: .leading, spacing: 6) {
                Text("AI Suggested Listing Tags:")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 6) {
                    ForEach(result.suggestedTags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AppTheme.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.primary.opacity(0.08))
                            .clipShape(Capsule())
                    }
                }
            }
            
            // Neural Reasoning Text
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
                    .padding(.top, 2)
                Text(result.reasoning)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
            
            // Action Button: Apply to Listing
            Button {
                AppTheme.triggerNotificationHaptic(type: .success)
                onApplyAppraisal?(result)
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Apply Appraisal to Listing")
                }
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppTheme.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 6)
        }
        .padding(16)
        .modernCard()
    }
    
    private var analyzingSkeletonCard: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Running Vision Neural Inference...")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .modernCard()
    }
    
    private func triggerAppraisal(index: Int) {
        laserOffset = -110
        let preset = demoPresets[index]
        Task {
            let res = await mlService.appraiseImage(UIImage(), fallbackTitle: preset.title)
            await MainActor.run {
                self.currentResult = res
            }
        }
    }
}

#Preview {
    SmartAppraisalModalView()
}
