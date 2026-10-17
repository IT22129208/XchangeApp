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
import AVFoundation

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
    @State private var selectedDistrict: SriLankaDistrict = .colombo
    @State private var itemCondition: ItemCondition = .likeNew
    @State private var itemDescription: String = ""
    
    // Modals and Sheets
    @State private var showSmartAppraisal: Bool = false
    @State private var showCategoryPickerSheet: Bool = false
    @State private var showNoImageForAppraisalAlert: Bool = false
    
    // Photo & Camera Picker State
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var showPhotoActionSheet: Bool = false
    @State private var showCameraPicker: Bool = false
    @State private var showPhotosPicker: Bool = false
    @State private var showCameraPermissionAlert: Bool = false
    @State private var showCameraUnavailableAlert: Bool = false
    @State private var isPublishing: Bool = false
    @State private var showSuccessAlert: Bool = false
    
    // Validation State
    @State private var attemptedPublish: Bool = false
    @State private var showValidationAlert: Bool = false
    @State private var validationErrorMessage: String = ""
    
    // Brand Colors matching official dark theme & screenshot
    private let accentGreen = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let fieldGreenBorder = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let fieldDarkBg = Color(red: 0.08, green: 0.10, blue: 0.12)
    private let photoBoxBg = Color(red: 0.11, green: 0.12, blue: 0.14)
    private let errorRed = Color(red: 0.95, green: 0.32, blue: 0.32)
    
    // MARK: - Validation Checkers
    
    private var isPhotoMissing: Bool {
        attemptedPublish && selectedImage == nil
    }
    
    private var isItemNameMissing: Bool {
        attemptedPublish && itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isCategoryMissing: Bool {
        attemptedPublish && selectedCategory == nil
    }
    
    private var isValueMissing: Bool {
        attemptedPublish && valueOrTradeAmount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isDescriptionMissing: Bool {
        attemptedPublish && itemDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func getMissingFields() -> [String] {
        var missing: [String] = []
        
        if selectedImage == nil {
            missing.append("Photo (Please upload or take a photo of the item)")
        }
        if itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            missing.append("Item Name (Please enter the name/title of your item)")
        }
        if selectedCategory == nil {
            missing.append("Category (Please select an item category)")
        }
        if valueOrTradeAmount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            missing.append("Value / Trade Amount (Please enter estimated value or trade offer)")
        }
        if itemDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            missing.append("Item Description (Please provide details about condition or trades)")
        }
        
        return missing
    }
    
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
                        
                        // C. "Category" Selector Field
                        categorySelectorField
                        
                        // D. "Value / Trade Amount" Field
                        valueTradeAmountField
                        
                        // E. "District / Location" Field
                        districtSelectorField
                        
                        // F. "Item Condition" Field
                        itemConditionField
                        
                        // G. "Item Description" Field
                        itemDescriptionField
                        
                        // H. AI Smart Appraisal Assistant Card
                        smartAppraisalCard
                            .padding(.top, 2)
                        
                        // I. Incomplete Listing Alert Banner (if user attempted publish with missing details)
                        if attemptedPublish && !getMissingFields().isEmpty {
                            missingFieldsSummaryBanner
                                .padding(.top, 4)
                        }
                        
                        // J. "Publish Listing" Green Button
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
            SmartAppraisalModalView(
                initialTitle: itemName,
                initialCategory: selectedCategory,
                initialCondition: itemCondition,
                initialImage: selectedImage,
                initialEstimatedValue: parseEstimatedValue(from: valueOrTradeAmount)
            ) { result in
                applyAppraisalResult(result)
            }
        }
        .sheet(isPresented: $showCameraPicker) {
            CameraPickerView(selectedImage: $selectedImage)
                .ignoresSafeArea()
        }
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotoItem, matching: .images)
        .confirmationDialog("Add Item Photo", isPresented: $showPhotoActionSheet, titleVisibility: .visible) {
            Button {
                checkAndOpenCamera()
            } label: {
                Label("Open Camera & Take Photo", systemImage: "camera.fill")
            }
            
            Button {
                AppTheme.triggerHaptic(style: .light)
                showPhotosPicker = true
            } label: {
                Label("Choose from Photo Library", systemImage: "photo.on.rectangle")
            }
            
            if selectedImage != nil {
                Button("Remove Photo", role: .destructive) {
                    withAnimation {
                        selectedImage = nil
                        selectedPhotoItem = nil
                    }
                    AppTheme.triggerHaptic(style: .light)
                }
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .alert("Picture Required for AI Appraise", isPresented: $showNoImageForAppraisalAlert) {
            Button("Take Photo") {
                checkAndOpenCamera()
            }
            Button("Choose from Library") {
                AppTheme.triggerHaptic(style: .light)
                showPhotosPicker = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please upload or take a picture of your item to use AI Smart Auto-Appraise. The AI searches Google Data using your photo to calculate the average market price.")
        }
        .alert("Missing Information", isPresented: $showValidationAlert) {
            Button("Fill Missing Details", role: .cancel) {}
        } message: {
            Text(validationErrorMessage)
        }
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
            Text("XChange needs access to your camera so you can take photos of your items to list them for barter. Please enable Camera in iOS Settings.")
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
        .onAppear {
            if let userDist = SriLankaDistrict.allDistricts.first(where: { $0.rawValue.caseInsensitiveCompare(userStore.currentUser.district) == .orderedSame }) {
                selectedDistrict = userDist
            } else if let detected = SriLankaDistrict.detectDistrict(from: userStore.currentUser.location),
                      let userDist = SriLankaDistrict.allDistricts.first(where: { $0.rawValue.caseInsensitiveCompare(detected) == .orderedSame }) {
                selectedDistrict = userDist
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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Item Photos")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("* Required")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isPhotoMissing ? errorRed : (selectedImage != nil ? accentGreen : Color.gray.opacity(0.6)))
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(photoBoxBg)
                    .frame(height: 210)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                isPhotoMissing ? errorRed : (selectedImage != nil ? accentGreen : Color.white.opacity(0.08)),
                                lineWidth: (isPhotoMissing || selectedImage != nil) ? 1.6 : 1
                            )
                    )
                
                if let selectedImage = selectedImage {
                    // Show Selected / Attached Image
                    ZStack {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 210)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        
                        VStack {
                            // Top Badges & Remove Button
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(accentGreen)
                                    Text("Photo Attached")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.black.opacity(0.72))
                                .clipShape(Capsule())
                                
                                Spacer()
                                
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        self.selectedImage = nil
                                        self.selectedPhotoItem = nil
                                    }
                                    AppTheme.triggerHaptic(style: .light)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.65).clipShape(Circle()))
                                }
                            }
                            .padding(12)
                            
                            Spacer()
                            
                            // Bottom Action Controls: Retake with Camera OR Pick from Library
                            HStack(spacing: 10) {
                                Button {
                                    checkAndOpenCamera()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 12, weight: .bold))
                                        Text("Retake Photo")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.black.opacity(0.75))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button {
                                    AppTheme.triggerHaptic(style: .light)
                                    showPhotosPicker = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "photo.on.rectangle")
                                            .font(.system(size: 12, weight: .bold))
                                        Text("Change from Library")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.black.opacity(0.75))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.bottom, 12)
                        }
                    }
                } else {
                    // Empty state with explicit, prominent "Open Camera" and "Photo Library" options
                    VStack(spacing: 12) {
                        // Pulsing camera icon badge
                        ZStack {
                            Circle()
                                .fill(isPhotoMissing ? errorRed.opacity(0.15) : accentGreen.opacity(0.12))
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(isPhotoMissing ? errorRed : accentGreen)
                        }
                        
                        VStack(spacing: 3) {
                            Text("Add Item Photo")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Snap a picture with your camera or select from library")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Color.gray.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                        
                        // Two prominent action buttons: 1) Open Camera, 2) Photo Library
                        HStack(spacing: 12) {
                            // Open Camera Button
                            Button {
                                checkAndOpenCamera()
                            } label: {
                                HStack(spacing: 7) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 13, weight: .bold))
                                    Text("Open Camera")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 9)
                                .background(accentGreen)
                                .clipShape(Capsule())
                                .shadow(color: accentGreen.opacity(0.35), radius: 6, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Photo Library Button
                            Button {
                                AppTheme.triggerHaptic(style: .light)
                                showPhotosPicker = true
                            } label: {
                                HStack(spacing: 7) {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text("Photo Library")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.top, 2)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showPhotoActionSheet = true
                    }
                }
            }
            
            if isPhotoMissing {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(errorRed)
                    Text("Photo is required. Please capture or select a photo of the item.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(errorRed)
                }
                .padding(.top, 2)
            }
        }
    }
    
    // MARK: - Field 1: Item Name
    
    private var itemNameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Item Name")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("* Required")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isItemNameMissing ? errorRed : accentGreen.opacity(0.8))
            }
            
            TextField("", text: $itemName, prompt: Text("e.g., Vintage Leather Jacket").foregroundColor(Color.gray.opacity(0.6)))
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(fieldDarkBg)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isItemNameMissing ? errorRed : fieldGreenBorder, lineWidth: 1.2)
                )
            
            if isItemNameMissing {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(errorRed)
                    Text("Item name is required. Please enter a name or title.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(errorRed)
                }
            }
        }
    }
    
    // MARK: - Field 2: Category
    
    private var categorySelectorField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Category")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("* Required")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isCategoryMissing ? errorRed : accentGreen.opacity(0.8))
            }
            
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
                        .foregroundColor(isCategoryMissing ? errorRed : fieldGreenBorder)
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(fieldDarkBg)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isCategoryMissing ? errorRed : fieldGreenBorder, lineWidth: 1.2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            if isCategoryMissing {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(errorRed)
                    Text("Category is required. Please select a category for your item.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(errorRed)
                }
            }
        }
    }
    
    // MARK: - Field 3: Value / Trade Amount
    
    private var valueTradeAmountField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Value / Trade Amount")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("* Required")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isValueMissing ? errorRed : accentGreen.opacity(0.8))
            }
            
            TextField("", text: $valueOrTradeAmount, prompt: Text("e.g., LKR 45,000 or Trade").foregroundColor(Color.gray.opacity(0.6)))
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(fieldDarkBg)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isValueMissing ? errorRed : fieldGreenBorder, lineWidth: 1.2)
                )
            
            if isValueMissing {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(errorRed)
                    Text("Value or trade amount is required. Please enter an amount or trade item.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(errorRed)
                }
            }
        }
    }
    
    // MARK: - Field 4: District / Location
    
    private var districtSelectorField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("District (Location)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("🇱🇰 Sri Lanka")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(accentGreen)
            }
            
            Menu {
                Picker("District", selection: $selectedDistrict) {
                    ForEach(SriLankaDistrict.allDistricts, id: \.self) { district in
                        Text("\(district.rawValue) (\(district.province))")
                            .tag(district)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(accentGreen)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(selectedDistrict.rawValue) District")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                        Text(selectedDistrict.province)
                            .font(.system(size: 11))
                            .foregroundColor(Color.gray.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(fieldGreenBorder)
                }
                .padding(.horizontal, 16)
                .frame(height: 52)
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
    
    // MARK: - Field 5: Item Condition
    
    private var itemConditionField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Item Condition")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("* Required")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(accentGreen)
            }
            
            Picker("Condition", selection: $itemCondition) {
                ForEach(ItemCondition.allCases) { cond in
                    Text(cond.rawValue).tag(cond)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(4)
            .background(fieldDarkBg)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(fieldGreenBorder, lineWidth: 1.2)
            )
        }
    }
    
    // MARK: - Field 6: Item Description
    
    private var itemDescriptionField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Item Description")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("* Required")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isDescriptionMissing ? errorRed : accentGreen.opacity(0.8))
            }
            
            ZStack(alignment: .topLeading) {
                if itemDescription.isEmpty {
                    Text("Describe condition, specifications, accessories included, and barter preferences...")
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $itemDescription)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 85)
                    .padding(10)
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
            }
            .background(fieldDarkBg)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isDescriptionMissing ? errorRed : fieldGreenBorder, lineWidth: 1.2)
            )
            
            if isDescriptionMissing {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(errorRed)
                    Text("Description is required. Please fill in details about your item.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(errorRed)
                }
            }
        }
    }
    
    // MARK: - AI Smart Appraisal Assistant Card
    
    private var smartAppraisalCard: some View {
        Button {
            if selectedImage == nil {
                AppTheme.triggerNotificationHaptic(type: .warning)
                showNoImageForAppraisalAlert = true
            } else {
                AppTheme.triggerHaptic(style: .medium)
                showSmartAppraisal = true
            }
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
                    HStack(spacing: 6) {
                        Text("AI Smart Auto-Appraise")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("GOOGLE DATA")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(accentGreen)
                            .clipShape(Capsule())
                    }
                    Text("Searches image in Google to calculate average market price")
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
                    .stroke(accentGreen.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Missing Fields Summary Banner
    
    private var missingFieldsSummaryBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.octagon.fill")
                .foregroundColor(errorRed)
                .font(.system(size: 20))
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Incomplete Listing Details")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Please fill in the \(getMissingFields().count) required detail\(getMissingFields().count > 1 ? "s" : "") marked in red before publishing.")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.85))
            }
            
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.32, green: 0.08, blue: 0.08).opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(errorRed.opacity(0.7), lineWidth: 1.2)
        )
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
        .disabled(isPublishing)
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
        valueOrTradeAmount = "LKR \(Int(result.googleAveragePrice))"
        itemDescription = "Condition: \(result.predictedCondition.rawValue). Market average based on Google Data: LKR \(Int(result.googleAveragePrice)). Auto-appraised tags: \(result.suggestedTags.joined(separator: ", "))"
    }
    
    private func publishListing() {
        let missing = getMissingFields()
        if !missing.isEmpty {
            attemptedPublish = true
            let listText = missing.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n\n")
            validationErrorMessage = """
            All details must be filled in order to publish your listing.
            
            The following information is missing:
            
            \(listText)
            
            Please fill in all the required details above before publishing.
            """
            showValidationAlert = true
            AppTheme.triggerNotificationHaptic(type: .warning)
            return
        }
        
        guard let selectedImage = selectedImage,
              let selectedCategory = selectedCategory else { return }
        
        isPublishing = true
        AppTheme.triggerHaptic(style: .medium)
        
        // 1. Save photo to local persistence
        var imageFilenames: [String] = []
        let photoFilename = "item_\(UUID().uuidString).jpg"
        if PersistenceService.shared.saveImage(selectedImage, filename: photoFilename) {
            imageFilenames.append(photoFilename)
        } else {
            imageFilenames.append(selectedCategory.systemIcon)
        }
        
        // 2. Parse value from text field (e.g. "LKR 45,000 or Trade" -> 45000)
        let parsedValue = parseEstimatedValue(from: valueOrTradeAmount)
        
        let newItem = Item(
            title: itemName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: itemDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            condition: itemCondition,
            estimatedValue: parsedValue,
            preferredTrades: valueOrTradeAmount.trimmingCharacters(in: .whitespacesAndNewlines),
            images: imageFilenames,
            ownerId: userStore.currentUser.id,
            ownerName: userStore.currentUser.displayName,
            ownerEmail: userStore.currentUser.email,
            ownerPhone: userStore.currentUser.phoneNumber,
            ownerAvatar: userStore.currentUser.avatar,
            ownerRating: userStore.currentUser.rating,
            ownerLocation: "\(selectedDistrict.rawValue), Sri Lanka",
            district: selectedDistrict.rawValue,
            status: .available,
            tags: [selectedCategory.rawValue, "Barter", selectedDistrict.rawValue, "Verified"],
            createdAt: Date()
        )
        
        itemStore.addItem(newItem)
        
        // Synchronize new item with image to Firebase Realtime Database
        let itemToPublish = newItem
        let imageToPublish = selectedImage
        Task { @MainActor in
            await FirebaseDatabaseService.shared.publishItem(itemToPublish, image: imageToPublish)
        }
        
        AppTheme.triggerNotificationHaptic(type: .success)
        isPublishing = false
        showSuccessAlert = true
    }
    
    private func parseEstimatedValue(from text: String) -> Double {
        let digits = text.filter { "0123456789.".contains($0) }
        return Double(digits) ?? 25000.0
    }
    
    private func checkAndOpenCamera() {
        AppTheme.triggerHaptic(style: .medium)
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showCameraUnavailableAlert = true
            return
        }
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
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
            showCameraPicker = true
        }
    }
    
    private func resetForm() {
        itemName = ""
        valueOrTradeAmount = ""
        selectedCategory = nil
        selectedImage = nil
        selectedPhotoItem = nil
        itemDescription = ""
        itemCondition = .likeNew
        attemptedPublish = false
        showValidationAlert = false
        validationErrorMessage = ""
        if let userDist = SriLankaDistrict.allDistricts.first(where: { $0.rawValue.caseInsensitiveCompare(userStore.currentUser.district) == .orderedSame }) {
            selectedDistrict = userDist
        }
    }
}

// MARK: - Camera Picker View (UIViewControllerRepresentable)

public struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    public init(selectedImage: Binding<UIImage?>) {
        self._selectedImage = selectedImage
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.cameraDevice = .rear
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            AppTheme.triggerNotificationHaptic(type: .success)
            parent.dismiss()
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
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
