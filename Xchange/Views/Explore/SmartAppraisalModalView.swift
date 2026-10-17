//
//  SmartAppraisalModalView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements CoreML, Apple Vision & Google Market Data Appraisal (Rubric Section 6)
//

import SwiftUI
import PhotosUI
import AVFoundation

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
    
    // Photo & Camera states
    @State private var showCameraPicker: Bool = false
    @State private var showPhotosPicker: Bool = false
    @State private var showCameraUnavailableAlert: Bool = false
    @State private var showCameraPermissionAlert: Bool = false
    
    private var effectiveImage: UIImage? {
        scannedImage ?? initialImage
    }
    
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
                    
                    // Stage 2: Empty Image State OR Appraisal Content
                    if effectiveImage == nil {
                        noImageUploadedCard
                    } else {
                        // Category Selector
                        categorySelectorSection
                        
                        // ML Appraisal Results Card
                        if let result = currentResult {
                            appraisalResultsCard(result)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else if mlService.isAnalyzing {
                            analyzingSkeletonCard
                        }
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
            .sheet(isPresented: $showCameraPicker) {
                CameraPickerView(selectedImage: $scannedImage)
                    .ignoresSafeArea()
            }
            .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotoItem, matching: .images)
            .alert("Camera Unavailable", isPresented: $showCameraUnavailableAlert) {
                Button("Choose from Library") {
                    showPhotosPicker = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("The camera is not available on this device or simulator. Would you like to select an image from your photo library instead?")
            }
            .alert("Camera Permission Required", isPresented: $showCameraPermissionAlert) {
                Button("Open Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("XChange needs access to your camera to capture item photos for Google AI Appraise. Please enable Camera in iOS Settings.")
            }
            .onAppear {
                initializeAndScan()
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let item = newItem,
                       let data = try? await item.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        await MainActor.run {
                            self.scannedImage = img
                            runAppraisal()
                        }
                    }
                }
            }
            .onChange(of: scannedImage) { _, newImg in
                if newImg != nil {
                    runAppraisal()
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
                        .stroke(effectiveImage != nil ? AppTheme.primary.opacity(0.3) : Color.yellow.opacity(0.3), lineWidth: 1.5)
                )
            
            // Item Image or No Image Prompt
            if let imageToDisplay = effectiveImage {
                Image(uiImage: imageToDisplay)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 230)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(
                        Color.black.opacity(0.18)
                    )
                
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
            } else {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.12))
                            .frame(width: 70, height: 70)
                        Image(systemName: "photo.badge.exclamationmark")
                            .font(.system(size: 32))
                            .foregroundColor(.yellow)
                    }
                    
                    Text("No Picture Uploaded")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Upload or take a photo below to appraise with Google Data")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
            }
            
            // Reticle Corners
            VStack {
                HStack {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(effectiveImage != nil ? AppTheme.tradeAccent : Color.yellow.opacity(0.7))
                    Spacer()
                    Image(systemName: "viewfinder")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(effectiveImage != nil ? AppTheme.tradeAccent : Color.yellow.opacity(0.7))
                }
                Spacer()
                HStack {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(effectiveImage != nil ? AppTheme.tradeAccent : Color.yellow.opacity(0.7))
                    Spacer()
                    Image(systemName: "viewfinder")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(effectiveImage != nil ? AppTheme.tradeAccent : Color.yellow.opacity(0.7))
                }
            }
            .padding(16)
            
            // Top Framework Badge & Photo Selector Button
            VStack {
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                        Text(effectiveImage != nil ? "Apple Vision & Google Search" : "Google AI Appraise")
                    }
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    if effectiveImage != nil {
                        Button {
                            showPhotosPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Change")
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
                }
                Spacer()
            }
            .padding(12)
        }
    }
    
    // MARK: - No Image Uploaded Guidance Card
    
    private var noImageUploadedCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 18))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Picture Required for AI Appraise")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Upload an image to unlock Google Market pricing")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            Text("Google AI Appraise needs a picture of your item to inspect logos, text, brand identifiers, and physical wear. It searches Google Data across Sri Lankan marketplaces to calculate the real average price.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                Button {
                    AppTheme.triggerHaptic(style: .medium)
                    checkAndOpenCamera()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "camera.fill")
                        Text("Take Photo")
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(AppTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    AppTheme.triggerHaptic(style: .medium)
                    showPhotosPicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle")
                        Text("Choose from Library")
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(AppTheme.primary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.primary.opacity(0.35), lineWidth: 1)
                    )
                }
            }
        }
        .padding(16)
        .modernCard()
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
            // Header: Google Average Price & Google Data Verified Pill
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.26, green: 0.52, blue: 0.96))
                        Text("Average Price with Google Data")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(result.formattedGoogleAveragePrice)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.primaryGradient)
                    
                    Text("Market Range: \(result.formattedGoogleRange)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Google Verified Pill
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.white)
                        Text("Google Verified")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.26, green: 0.52, blue: 0.96))
                    .clipShape(Capsule())
                    
                    Text(result.formattedConfidence)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Google Search Query Box
            VStack(alignment: .leading, spacing: 6) {
                Text("GOOGLE MARKET SEARCH QUERY")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(red: 0.26, green: 0.52, blue: 0.96))
                        .font(.system(size: 13, weight: .bold))
                    
                    Text(result.googleSearchQuery)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(10)
                .background(Color.primary.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // Live Google Search Link
            if let searchUrl = URL(string: result.googleSearchUrl) {
                Link(destination: searchUrl) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.right.square.fill")
                            .font(.system(size: 12))
                        Text("View Live Listings on Google Search")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(Color(red: 0.26, green: 0.52, blue: 0.96))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.26, green: 0.52, blue: 0.96).opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            // Indexed Sources Chips
            VStack(alignment: .leading, spacing: 6) {
                Text("INDEXED MARKETPLACES")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(result.googleIndexedSources, id: \.self) { source in
                            Text(source)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.primary.opacity(0.06))
                                .clipShape(Capsule())
                        }
                    }
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
            Text("Searching Google Data & Calculating Market Average...")
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
            runAppraisal()
        }
        // Notice: If no image is provided, do NOT run appraisal automatically.
    }
    
    private func runAppraisal() {
        guard let imageToAnalyze = effectiveImage else { return }
        
        laserOffset = -100
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
            await MainActor.run {
                self.currentResult = res
            }
        }
    }
    
    private func checkAndOpenCamera() {
        #if targetEnvironment(simulator)
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            showCameraUnavailableAlert = true
            return
        }
        #endif
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCameraPicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.showCameraPicker = true
                    } else {
                        self.showCameraPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showCameraPermissionAlert = true
        @unknown default:
            break
        }
    }
}

#Preview {
    SmartAppraisalModalView()
}
