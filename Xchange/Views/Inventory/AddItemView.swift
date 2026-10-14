//
//  AddItemView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Pixel-perfect Add Listing Interface matching the reference design with dark theme
//

import SwiftUI
import PhotosUI
import UIKit

public typealias AddListingView = AddItemView

public struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var userStore: UserStore
    
    var isPresentedAsModal: Bool = false
    var onPublishSuccess: (() -> Void)? = nil
    
    // Form Inputs matching reference design
    @State private var itemName: String = ""
    @State private var valueOrTradeAmount: String = ""
    @State private var selectedCategory: ItemCategory? = nil
    
    // Optional Expanded details
    @State private var showAdditionalDetails: Bool = false
    @State private var itemDescription: String = ""
    @State private var itemCondition: ItemCondition = .likeNew
    @State private var showSmartAppraisal: Bool = false
    @State private var showCategoryPickerSheet: Bool = false
    
    // Photo Picker State
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isPublishing: Bool = false
    @State private var showSuccessAlert: Bool = false
    
    // Brand Colors matching official dark theme & screenshot
    private let accentGreen = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let fieldGreenBorder = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let fieldDarkBg = Color(red: 0.08, green: 0.10, blue: 0.12)
    private let photoBoxBg = Color(red: 0.11, green: 0.12, blue: 0.14)
    
    public init(isPresentedAsModal: Bool = false, onPublishSuccess: (() -> Void)? = nil) {
        self.isPresentedAsModal = isPresentedAsModal
        self.onPublishSuccess = onPublishSuccess
    }
    
    public var body: some View {
        ZStack {
            // Full Screen Background: Pure Pitch Black
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Top White Header Banner with "Add Listing"
                topWhiteHeaderBanner
                
                // 2. Scrollable Form Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // A. Photo Upload Box ("Tap to Add Photos")
                        photoUploadBox
                            .padding(.top, 14)
                        
                        // B. "Item Name" Field
                        itemNameField
                        
                        // C. "Value / Trade Amount" Field
                        valueTradeAmountField
                        
                        // D. "Category" Selector Field
                        categorySelectorField
                        
                        // E. Optional Additional Details (Expandable)
                        additionalDetailsSection
                        
                        // F. "Publish Listing" Green Button
                        publishListingButton
                            .padding(.top, 6)
                            .padding(.bottom, 120) // Clearance for bottom navigation bar
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCategoryPickerSheet) {
            categorySelectionSheet
        }
        .sheet(isPresented: $showSmartAppraisal) {
            SmartAppraisalModalView(initialTitle: itemName) { result in
                applyAppraisalResult(result)
            }
        }
        .alert("Listing Published!", isPresented: $showSuccessAlert) {
            Button("View in Marketplace") {
                if isPresentedAsModal {
                    dismiss()
                }
                onPublishSuccess?()
            }
            Button("List Another Item", role: .cancel) {
                resetForm()
            }
        } message: {
            Text("Your item is now live and ready for barter proposals from the community.")
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let newItem = newItem,
                   let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        self.selectedImage = uiImage
                        AppTheme.triggerNotificationHaptic(type: .success)
                    }
                }
            }
        }
    }
    
    // MARK: - Top Header White Banner
    
    private var topWhiteHeaderBanner: some View {
        HStack {
            if isPresentedAsModal {
                Button {
                    AppTheme.triggerHaptic(style: .light)
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                }
                .padding(.leading, 12)
            } else {
                Spacer()
                    .frame(width: 48)
            }
            
            Spacer()
            
            Text("Add Listing")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .tracking(0.3)
            
            Spacer()
            
            Spacer()
                .frame(width: 48)
        }
        .frame(height: 52)
        .background(Color.white)
        .clipShape(UnevenRoundedCornerShape(bottomLeading: 22, bottomTrailing: 22))
        .shadow(color: Color.black.opacity(0.3), radius: 8, y: 4)
    }
    
    // MARK: - Photo Upload Box
    
    private var photoUploadBox: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(photoBoxBg)
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(selectedImage != nil ? accentGreen : Color.white.opacity(0.06), lineWidth: selectedImage != nil ? 1.5 : 1)
                    )
                
                if let selectedImage = selectedImage {
                    // Show Selected Image
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    
                    // Overlay "Change Photo" / Clear control
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                self.selectedImage = nil
                                self.selectedPhotoItem = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.6).clipShape(Circle()))
                            }
                            .padding(10)
                        }
                        Spacer()
                        
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12, weight: .bold))
                            Text("Tap to change photo")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Capsule())
                        .padding(.bottom, 10)
                    }
                } else {
                    // Empty state matching user reference screenshot
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 44, weight: .regular))
                            .foregroundColor(accentGreen)
                        
                        Text("Tap to Add Photos")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Field 1: Item Name
    
    private var itemNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Item Name")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            TextField("", text: $itemName, prompt: Text("e.g., Vintage Leather Jacket").foregroundColor(Color.gray.opacity(0.6)))
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(fieldDarkBg)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(fieldGreenBorder, lineWidth: 1.2)
                )
        }
    }
    
    // MARK: - Field 2: Value / Trade Amount
    
    private var valueTradeAmountField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Value / Trade Amount")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            TextField("", text: $valueOrTradeAmount, prompt: Text("e.g., $300 or Trade").foregroundColor(Color.gray.opacity(0.6)))
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(fieldDarkBg)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(fieldGreenBorder, lineWidth: 1.2)
                )
        }
    }
    
    // MARK: - Field 3: Category
    
    private var categorySelectorField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Button {
                AppTheme.triggerHaptic(style: .light)
                showCategoryPickerSheet = true
            } label: {
                HStack {
                    if let category = selectedCategory {
                        HStack(spacing: 8) {
                            Image(systemName: category.systemIcon)
                                .font(.system(size: 14))
                                .foregroundColor(accentGreen)
                            
                            Text(category.rawValue)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                        }
                    } else {
                        Text("Select Category")
                            .font(.system(size: 15))
                            .foregroundColor(Color.gray.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(fieldGreenBorder)
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(fieldDarkBg)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(fieldGreenBorder, lineWidth: 1.2)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Additional Details (Expandable)
    
    private var additionalDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    showAdditionalDetails.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: showAdditionalDetails ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundColor(accentGreen)
                        .font(.system(size: 14))
                    
                    Text("Additional Details & AI Appraisal (Optional)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.gray.opacity(0.85))
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(PlainButtonStyle())
            
            if showAdditionalDetails {
                VStack(alignment: .leading, spacing: 14) {
                    // AI Smart Auto-Appraisal Assistant Button
                    Button {
                        showSmartAppraisal = true
                        AppTheme.triggerHaptic(style: .medium)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(accentGreen.opacity(0.15))
                                    .frame(width: 38, height: 38)
                                Image(systemName: "sparkles")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(accentGreen)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("AI Auto-Appraise Item")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Predicts fair value & category with Vision & CoreML")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.gray.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(accentGreen)
                        }
                        .padding(12)
                        .background(fieldDarkBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(accentGreen.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Item Condition
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Condition")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                        
                        Picker("Condition", selection: $itemCondition) {
                            ForEach(ItemCondition.allCases) { cond in
                                Text(cond.rawValue).tag(cond)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Item Description")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                        
                        TextEditor(text: $itemDescription)
                            .scrollContentBackground(.hidden)
                            .frame(height: 70)
                            .padding(10)
                            .background(fieldDarkBg)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    }
                }
                .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Publish Listing Button
    
    private var publishListingButton: some View {
        Button {
            publishListing()
        } label: {
            HStack(spacing: 8) {
                if isPublishing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Publish Listing")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(accentGreen)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: accentGreen.opacity(0.4), radius: 8, y: 3)
        }
        .disabled(isPublishing || itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Category Selection Sheet
    
    private var categorySelectionSheet: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                List {
                    ForEach(ItemCategory.allCases.filter { $0 != .all }) { cat in
                        Button {
                            selectedCategory = cat
                            AppTheme.triggerHaptic(style: .light)
                            showCategoryPickerSheet = false
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: cat.systemIcon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(accentGreen)
                                    .frame(width: 26)
                                
                                Text(cat.rawValue)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if selectedCategory == cat {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(accentGreen)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(fieldDarkBg)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        showCategoryPickerSheet = false
                    }
                    .foregroundColor(accentGreen)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Action Methods
    
    private func applyAppraisalResult(_ result: AppraisalResult) {
        if itemName.isEmpty || itemName == "Item Title" {
            itemName = result.detectedTitle
        }
        selectedCategory = result.predictedCategory
        itemCondition = result.predictedCondition
        valueOrTradeAmount = "$\(Int(result.estimatedFairValue))"
        itemDescription = "Condition: \(result.predictedCondition.rawValue). Auto-appraised tags: \(result.suggestedTags.joined(separator: ", "))"
    }
    
    private func publishListing() {
        guard !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isPublishing = true
        AppTheme.triggerHaptic(style: .medium)
        
        // 1. Save photo to local persistence if selected
        var imageFilenames: [String] = []
        if let selectedImage = selectedImage {
            let photoFilename = "item_\(UUID().uuidString).jpg"
            if PersistenceService.shared.saveImage(selectedImage, filename: photoFilename) {
                imageFilenames.append(photoFilename)
            }
        }
        
        // If no photo was selected, use category system icon
        if imageFilenames.isEmpty {
            let cat = selectedCategory ?? .electronics
            imageFilenames.append(cat.systemIcon)
        }
        
        // 2. Parse value from text field (e.g. "$300 or Trade" -> 300)
        let parsedValue = parseEstimatedValue(from: valueOrTradeAmount)
        let cat = selectedCategory ?? .electronics
        
        let newItem = Item(
            title: itemName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: itemDescription.isEmpty ? "Listed via Xchange Barter. Open to offers and trades." : itemDescription,
            category: cat,
            condition: itemCondition,
            estimatedValue: parsedValue,
            preferredTrades: valueOrTradeAmount.isEmpty ? "Open to fair trades" : valueOrTradeAmount,
            images: imageFilenames,
            ownerId: userStore.currentUser.id,
            ownerName: userStore.currentUser.displayName,
            ownerAvatar: userStore.currentUser.avatar,
            ownerRating: userStore.currentUser.rating,
            ownerLocation: userStore.currentUser.location,
            status: .available,
            tags: [cat.rawValue, "Barter", "Verified"],
            createdAt: Date()
        )
        
        itemStore.addItem(newItem)
        AppTheme.triggerNotificationHaptic(type: .success)
        isPublishing = false
        showSuccessAlert = true
    }
    
    private func parseEstimatedValue(from text: String) -> Double {
        let digits = text.filter { "0123456789.".contains($0) }
        return Double(digits) ?? 150.0
    }
    
    private func resetForm() {
        itemName = ""
        valueOrTradeAmount = ""
        selectedCategory = nil
        selectedImage = nil
        selectedPhotoItem = nil
        itemDescription = ""
        itemCondition = .likeNew
    }
}

// MARK: - Custom Corner Shape for Top Header

private struct UnevenRoundedCornerShape: Shape {
    var bottomLeading: CGFloat = 0
    var bottomTrailing: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: bottomLeading, height: bottomTrailing)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    AddItemView()
        .environmentObject(ItemStore())
        .environmentObject(UserStore())
}
