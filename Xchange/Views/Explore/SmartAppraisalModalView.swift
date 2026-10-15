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
    var initialCategory: ItemCategory? = nil
    var initialCondition: ItemCondition? = nil
    var initialImage: UIImage? = nil
    var initialEstimatedValue: Double? = nil
    var onApplyAppraisal: ((AppraisalResult) -> Void)? = nil
    
    @State private var itemTitle: String = ""
    @State private var selectedCategory: ItemCategory = .electronics
    @State private var selectedCondition: ItemCondition = .likeNew
    @State private var scannedImage: UIImage? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var laserOffset: CGFloat = -100
    @State private var currentResult: AppraisalResult? = nil
    
    public init(
        initialTitle: String = "",
        initialCategory: ItemCategory? = nil,
        initialCondition: ItemCondition? = nil,
        initialImage: UIImage? = nil,
        initialEstimatedValue: Double? = nil,
        onApplyAppraisal: ((AppraisalResult) -> Void)? = nil
    ) {
        self.initialTitle = initialTitle
        self.initialCategory = initialCategory
        self.initialCondition = initialCondition
        self.initialImage = initialImage
        self.initialEstimatedValue = initialEstimatedValue
        self.onApplyAppraisal = onApplyAppraisal
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Stage 1: Camera Scanner Stage
                    scannerStage
                    
                    // Stage 2: Category Selector
                    categorySelectorSection
                    
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
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                initializeAndScan()
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let item = newItem,
                       let data = try? await item.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        self.scannedImage = img
                        runAppraisal()
                    }
                }
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
            
            // Item Image or Category Icon Display
            if let imageToDisplay = scannedImage ?? initialImage {
                Image(uiImage: imageToDisplay)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 230)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(
                        Color.black.opacity(0.2)
                    )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: selectedCategory.systemIcon)
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.primary, AppTheme.tradeAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: AppTheme.primary.opacity(0.5), radius: 16)
                    
                    Text(itemTitle.isEmpty ? "Inspecting \(selectedCategory.rawValue)" : itemTitle)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(.horizontal, 24)
                }
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
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, AppTheme.brandGreen, Color.clear],
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
                        laserOffset = 100
                    }
                }
            
            // Top Framework Badge & Photo Selector Button
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
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack(spacing: 4) {
                            Image(systemName: "camera.fill")
                            Text("Scan Photo")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                Spacer()
            }
            .padding(12)
        }
    }
    
    private var categorySelectorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Classified Category (Tap to adjust):")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ItemCategory.allCases.filter { $0 != .all }) { cat in
                        let isSelected = selectedCategory == cat
                        Button {
                            selectedCategory = cat
                            AppTheme.triggerHaptic(style: .light)
                            runAppraisal()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: cat.systemIcon)
                                    .font(.system(size: 12))
                                Text(cat.rawValue)
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
                    Text("Predicted Fair Barter Value")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("LKR \(Int(result.estimatedFairValue))")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.primaryGradient)
                }
                
                Spacer()
                
                // Confidence Pill
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(AppTheme.tradeAccent)
                        Text(result.formattedConfidence)
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(AppTheme.tradeAccent)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.tradeAccent.opacity(0.12))
                    .clipShape(Capsule())
                    
                    Text("Range: \(result.formattedValueRange)")
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
                    Text("CONDITION RATING")
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
            if !result.suggestedTags.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("AI Suggested Listing Tags:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
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
            
            // Context Action Button
            if let onApply = onApplyAppraisal {
                Button {
                    AppTheme.triggerNotificationHaptic(type: .success)
                    onApply(result)
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
            } else {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(UIColor.label))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 6)
            }
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
    
    // MARK: - Appraisal Execution
    
    private func initializeAndScan() {
        itemTitle = initialTitle
        if let cat = initialCategory {
            selectedCategory = cat
        }
        if let cond = initialCondition {
            selectedCondition = cond
        }
        if let img = initialImage {
            scannedImage = img
        }
        runAppraisal()
    }
    
    private func runAppraisal() {
        laserOffset = -100
        let imageToAnalyze = scannedImage ?? initialImage
        let titleToAnalyze = itemTitle.isEmpty ? initialTitle : itemTitle
        let cat = selectedCategory
        let cond = selectedCondition
        let baseVal = initialEstimatedValue
        
        Task {
            let res = await mlService.appraise(
                title: titleToAnalyze,
                category: cat,
                condition: cond,
                image: imageToAnalyze,
                baseValue: baseVal
            )
            self.currentResult = res
        }
    }
}

#Preview {
    SmartAppraisalModalView()
}
