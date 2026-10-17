//
//  EditItemView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Enables owners to edit item details including location, price, description, condition, category, photo & status
//

import SwiftUI
import PhotosUI
import AVFoundation

public struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var userStore: UserStore
    
    let item: Item
    var onUpdateSuccess: ((Item) -> Void)? = nil
    
    // Form Inputs pre-populated from item
    @State private var itemName: String
    @State private var valueOrTradeAmount: String
    @State private var selectedCategory: ItemCategory
    @State private var selectedDistrict: SriLankaDistrict
    @State private var specificLocation: String
    @State private var itemCondition: ItemCondition
    @State private var itemStatus: ItemStatus
    @State private var preferredTrades: String
    @State private var itemDescription: String
    @State private var tagsString: String
    
    // Photo & Camera State
    @State private var selectedImage: UIImage?
    @State private var hasChangedPhoto: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var showPhotoActionSheet: Bool = false
    @State private var showCameraPicker: Bool = false
    @State private var showPhotosPicker: Bool = false
    @State private var showCameraPermissionAlert: Bool = false
    @State private var showCameraUnavailableAlert: Bool = false
    
    // Modals and Alerts
    @State private var showCategoryPickerSheet: Bool = false
    @State private var showSmartAppraisal: Bool = false
    @State private var showNoImageForAppraisalAlert: Bool = false
    @State private var isSaving: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var showDeleteConfirmAlert: Bool = false
    @State private var showValidationAlert: Bool = false
    @State private var validationErrorMessage: String = ""
    
    // Styling Colors matching AddItemView dark aesthetic
    private let accentGreen = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let fieldGreenBorder = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let fieldDarkBg = Color(red: 0.08, green: 0.10, blue: 0.12)
    private let photoBoxBg = Color(red: 0.11, green: 0.12, blue: 0.14)
    private let errorRed = Color(red: 0.95, green: 0.32, blue: 0.32)
    
    public init(item: Item, onUpdateSuccess: ((Item) -> Void)? = nil) {
        self.item = item
        self.onUpdateSuccess = onUpdateSuccess
        
        _itemName = State(initialValue: item.title)
        _valueOrTradeAmount = State(initialValue: "LKR \(Int(item.estimatedValue))")
        _selectedCategory = State(initialValue: item.category)
        
        let initialDist = SriLankaDistrict.allDistricts.first(where: {
            $0.rawValue.caseInsensitiveCompare(item.district ?? "") == .orderedSame
        }) ?? SriLankaDistrict.detectDistrict(from: item.ownerLocation).flatMap { detected in
            SriLankaDistrict.allDistricts.first(where: { $0.rawValue.caseInsensitiveCompare(detected) == .orderedSame })
        } ?? .colombo
        _selectedDistrict = State(initialValue: initialDist)
        
        _specificLocation = State(initialValue: item.ownerLocation)
        _itemCondition = State(initialValue: item.condition)
        _itemStatus = State(initialValue: item.status)
        _preferredTrades = State(initialValue: item.preferredTrades)
        _itemDescription = State(initialValue: item.description)
        _tagsString = State(initialValue: item.tags.joined(separator: ", "))
        
        let initialImg: UIImage?
        if let first = item.images.first, !first.isEmpty {
            initialImg = PersistenceService.shared.resolveImage(nameOrPath: first)
        } else {
            initialImg = nil
        }
        _selectedImage = State(initialValue: initialImg)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Header
                    topHeaderBanner
                    
                    // Form Content
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            // A. Photo Section
                            photoSection
                                .padding(.top, 14)
                            
                            // B. Item Title Field
                            itemNameField
                            
                            // C. Category Selector
                            categorySelectorField
                            
                            // D. Value / Price Field
                            valuePriceField
                            
                            // E. District & Location Field
                            locationDistrictSection
                            
                            // F. Item Condition
                            itemConditionField
                            
                            // G. Listing Status
                            itemStatusField
                            
                            // H. Owner Wishlist / Preferred Trades
                            preferredTradesField
                            
                            // I. Item Description
                            itemDescriptionField
                            
                            // J. Tags Field
                            tagsField
                            
                            // K. AI Smart Auto-Appraise Card
                            smartAppraisalCard
                                .padding(.top, 2)
                            
                            // L. Action Buttons: Save Changes & Delete
                            actionButtonsSection
                                .padding(.top, 6)
                                .padding(.bottom, 60)
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
            .confirmationDialog("Edit Item Photo", isPresented: $showPhotoActionSheet, titleVisibility: .visible) {
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
                            hasChangedPhoto = true
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
                    showPhotosPicker = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please upload or take a picture of your item to use AI Smart Auto-Appraise. The AI searches Google Data using your photo to calculate the average market price.")
            }
            .alert("Missing Information", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationErrorMessage)
            }
            .alert("Delete Listing?", isPresented: $showDeleteConfirmAlert) {
                Button("Delete", role: .destructive) {
                    performDelete()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to permanently delete '\(item.title)'? This will remove it from the barter marketplace.")
            }
            .alert("Listing Updated!", isPresented: $showSuccessAlert) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your listing details have been updated successfully and synced with the marketplace.")
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let item = newItem,
                       let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            self.selectedImage = uiImage
                            self.hasChangedPhoto = true
                            AppTheme.triggerNotificationHaptic(type: .success)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var topHeaderBanner: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Edit Listing")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    saveChanges()
                } label: {
                    if isSaving {
                        ProgressView()
                            .tint(accentGreen)
                    } else {
                        Text("Save")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(accentGreen)
                    }
                }
                .disabled(isSaving)
            }
            .padding(.horizontal, 20)
            .frame(height: 54)
            
            Divider()
                .background(Color.white.opacity(0.12))
        }
        .background(Color(red: 0.08, green: 0.10, blue: 0.12))
    }
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ITEM PHOTO")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(accentGreen)
            
            Button {
                AppTheme.triggerHaptic(style: .medium)
                showPhotoActionSheet = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(photoBoxBg)
                        .frame(height: 190)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(accentGreen.opacity(0.4), lineWidth: 1.5)
                        )
                    
                    if let img = selectedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                VStack {
                                    Spacer()
                                    HStack {
                                        Image(systemName: "camera.fill")
                                        Text("Tap to Change Photo")
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.black.opacity(0.65))
                                    .clipShape(Capsule())
                                    .padding(.bottom, 10)
                                }
                            )
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 34))
                                .foregroundColor(accentGreen)
                            
                            Text("Upload a Photo")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Take photo or select from camera roll")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Title Field
    
    private var itemNameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ITEM TITLE")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(accentGreen)
            
            TextField("", text: $itemName, prompt: Text("e.g. Sony A7 III Mirrorless Camera").foregroundColor(Color.gray.opacity(0.6)))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(fieldDarkBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Category Field
    
    private var categorySelectorField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("CATEGORY")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(accentGreen)
            
            Button {
                AppTheme.triggerHaptic(style: .light)
                showCategoryPickerSheet = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: selectedCategory.systemIcon)
                        .foregroundColor(accentGreen)
                        .font(.system(size: 15))
                    
                    Text(selectedCategory.rawValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(fieldDarkBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Value / Price Field
    
    private var valuePriceField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("ESTIMATED PRICE / VALUE (LKR)")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(accentGreen)
                Spacer()
                Text("Reference value for fair barter")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 8) {
                Text("LKR")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(accentGreen)
                
                TextField("", text: $valueOrTradeAmount, prompt: Text("e.g. 185000").foregroundColor(Color.gray.opacity(0.6)))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .keyboardType(.numberPad)
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(fieldDarkBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Location & District Section
    
    private var locationDistrictSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LOCATION & DISTRICT")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(accentGreen)
            
            // District Picker Menu
            Menu {
                ForEach(SriLankaDistrict.allDistricts, id: \.self) { district in
                    Button {
                        selectedDistrict = district
                        AppTheme.triggerHaptic(style: .light)
                    } label: {
                        HStack {
                            Text(district.rawValue)
                            if selectedDistrict == district {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "map.fill")
                        .foregroundColor(accentGreen)
                        .font(.system(size: 14))
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Administrative District")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                        Text(selectedDistrict.displayLabel)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(fieldDarkBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
            }
            
            // Specific Location Field (e.g. Colombo 07, Cinnamon Gardens)
            HStack(spacing: 10) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(accentGreen)
                    .font(.system(size: 14))
                
                TextField("", text: $specificLocation, prompt: Text("e.g. Colombo 07, Cinnamon Gardens").foregroundColor(Color.gray.opacity(0.6)))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(fieldDarkBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Condition Field
    
    private var itemConditionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ITEM CONDITION")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(accentGreen)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ItemCondition.allCases, id: \.self) { cond in
                        let isSelected = itemCondition == cond
                        Button {
                            itemCondition = cond
                            AppTheme.triggerHaptic(style: .light)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: cond.iconName)
                                    .font(.system(size: 11))
                                Text(cond.rawValue)
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(isSelected ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isSelected ? accentGreen : fieldDarkBg)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? accentGreen : Color.white.opacity(0.12), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Listing Status Field
    
    private var itemStatusField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LISTING STATUS")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(accentGreen)
            
            HStack(spacing: 8) {
                ForEach([ItemStatus.available, ItemStatus.inTradeNegotiation, ItemStatus.traded], id: \.self) { status in
                    let isSelected = itemStatus == status
                    Button {
                        itemStatus = status
                        AppTheme.triggerHaptic(style: .light)
                    } label: {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(status.color)
                                .frame(width: 7, height: 7)
                            Text(status.rawValue)
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(isSelected ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(isSelected ? status.color.opacity(0.25) : fieldDarkBg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? status.color : Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Preferred Trades Field
    
    private var preferredTradesField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("BARTER WISHLIST (WANTED IN TRADE)")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(accentGreen)
                Spacer()
                Text("What would you accept?")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            
            TextField("", text: $preferredTrades, prompt: Text("e.g. Looking for iPad Air, Sony Lens, or Electric Guitar").foregroundColor(Color.gray.opacity(0.6)))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(fieldDarkBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Description Field
    
    private var itemDescriptionField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ITEM DESCRIPTION")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(accentGreen)
            
            ZStack(alignment: .topLeading) {
                if itemDescription.isEmpty {
                    Text("Describe item condition, accessories included, or specific trade terms...")
                        .font(.system(size: 13))
                        .foregroundColor(Color.gray.opacity(0.6))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $itemDescription)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
            .frame(minHeight: 100)
            .background(fieldDarkBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Tags Field
    
    private var tagsField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("TAGS (COMMA SEPARATED)")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(accentGreen)
                Spacer()
                Text("Helps search discovery")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            
            TextField("", text: $tagsString, prompt: Text("e.g. Sony, Camera, 4K, FullFrame").foregroundColor(Color.gray.opacity(0.6)))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(fieldDarkBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
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
                    Text("Re-evaluate with Google Data average pricing & auto-fill")
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
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(accentGreen.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Action Buttons
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button {
                saveChanges()
            } label: {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("Save Changes")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(accentGreen)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: accentGreen.opacity(0.4), radius: 8, x: 0, y: 3)
            }
            .disabled(isSaving)
            
            Button {
                AppTheme.triggerNotificationHaptic(type: .warning)
                showDeleteConfirmAlert = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 13))
                    Text("Delete Listing")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundColor(errorRed)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(errorRed.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(errorRed.opacity(0.25), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Category Selection Sheet
    
    private var categorySelectionSheet: some View {
        NavigationStack {
            List {
                ForEach(ItemCategory.allCases.filter { $0 != .all }) { cat in
                    Button {
                        selectedCategory = cat
                        AppTheme.triggerHaptic(style: .light)
                        showCategoryPickerSheet = false
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: cat.systemIcon)
                                .foregroundColor(accentGreen)
                                .font(.system(size: 18))
                                .frame(width: 28)
                            
                            Text(cat.rawValue)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedCategory == cat {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(accentGreen)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        showCategoryPickerSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Logic & Actions
    
    private func parseEstimatedValue(from input: String) -> Double {
        let clean = input
            .replacingOccurrences(of: "LKR", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(clean) ?? 0.0
    }
    
    private func applyAppraisalResult(_ result: AppraisalResult) {
        if itemName.isEmpty {
            itemName = result.detectedTitle
        }
        selectedCategory = result.predictedCategory
        itemCondition = result.predictedCondition
        valueOrTradeAmount = "LKR \(Int(result.googleAveragePrice))"
        itemDescription = "Condition: \(result.predictedCondition.rawValue). Average market price based on Google Data: LKR \(Int(result.googleAveragePrice)). Auto-appraised tags: \(result.suggestedTags.joined(separator: ", "))"
        tagsString = result.suggestedTags.joined(separator: ", ")
    }
    
    private func saveChanges() {
        let trimmedTitle = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDesc = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = specificLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        let parsedVal = parseEstimatedValue(from: valueOrTradeAmount)
        
        var errors: [String] = []
        if trimmedTitle.isEmpty {
            errors.append("• Item Title cannot be empty.")
        }
        if parsedVal <= 0 {
            errors.append("• Please enter a valid estimated price / value.")
        }
        if trimmedLocation.isEmpty {
            errors.append("• Location details cannot be empty.")
        }
        if trimmedDesc.isEmpty {
            errors.append("• Item Description cannot be empty.")
        }
        
        if !errors.isEmpty {
            validationErrorMessage = errors.joined(separator: "\n")
            showValidationAlert = true
            AppTheme.triggerNotificationHaptic(type: .error)
            return
        }
        
        isSaving = true
        AppTheme.triggerHaptic(style: .medium)
        
        // Handle image saving if changed or updated
        var updatedImages = item.images
        if hasChangedPhoto, let newImg = selectedImage {
            let filename = "item_\(item.id.uuidString)_\(Int(Date().timeIntervalSince1970)).jpg"
            if PersistenceService.shared.saveImage(newImg, filename: filename) {
                updatedImages = [filename]
            }
        } else if selectedImage == nil {
            updatedImages = []
        }
        
        // Parse tags
        let parsedTags = tagsString
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "") }
            .filter { !$0.isEmpty }
        
        var updatedItem = item
        updatedItem.title = trimmedTitle
        updatedItem.description = trimmedDesc
        updatedItem.category = selectedCategory
        updatedItem.condition = itemCondition
        updatedItem.estimatedValue = parsedVal
        updatedItem.preferredTrades = preferredTrades.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedItem.ownerLocation = trimmedLocation
        updatedItem.district = selectedDistrict.rawValue
        updatedItem.status = itemStatus
        updatedItem.images = updatedImages
        updatedItem.tags = parsedTags.isEmpty ? item.tags : parsedTags
        
        itemStore.updateItem(updatedItem, image: selectedImage)
        
        onUpdateSuccess?(updatedItem)
        AppTheme.triggerNotificationHaptic(type: .success)
        
        isSaving = false
        showSuccessAlert = true
    }
    
    private func performDelete() {
        AppTheme.triggerNotificationHaptic(type: .success)
        itemStore.deleteItem(byId: item.id)
        dismiss()
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
