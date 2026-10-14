//
//  AddItemView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements Item Listing Form with AI CoreML Appraisal Assistant
//

import SwiftUI

public struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var userStore: UserStore
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: ItemCategory = .electronics
    @State private var condition: ItemCondition = .likeNew
    @State private var estimatedValueText: String = "250"
    @State private var preferredTrades: String = ""
    @State private var tagsText: String = "tech, gadget"
    @State private var selectedIcon: String = "laptopcomputer"
    @State private var showSmartAppraisal: Bool = false
    
    private let iconOptions = [
        "laptopcomputer", "gamecontroller.fill", "camera.fill", "headphones",
        "guitars.fill", "tshirt.fill", "figure.hiking", "books.vertical.fill",
        "house.fill", "watch.analog", "skateboard.fill", "bicycle"
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Form {
                // Section 0: Emerging Tech AI Smart Appraisal Assistant
                Section {
                    Button {
                        showSmartAppraisal = true
                        AppTheme.triggerHaptic(style: .medium)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primary.opacity(0.12))
                                    .frame(width: 42, height: 42)
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppTheme.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("AI Auto-Appraise Item")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                Text("Vision & CoreML predicts category, condition & fair value")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 18))
                                .foregroundColor(AppTheme.primary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Section 1: Basic Information
                Section(header: Text("Item Overview")) {
                    TextField("Item Title (e.g. Sony WH-1000XM5)", text: $title)
                        .font(.system(size: 15))
                    
                    Picker("Category", selection: $category) {
                        ForEach(ItemCategory.allCases.filter { $0 != .all }) { cat in
                            HStack {
                                Image(systemName: cat.systemIcon)
                                Text(cat.rawValue)
                            }.tag(cat)
                        }
                    }
                    
                    Picker("Condition", selection: $condition) {
                        ForEach(ItemCondition.allCases) { cond in
                            HStack {
                                Image(systemName: cond.iconName)
                                Text(cond.rawValue)
                            }.tag(cond)
                        }
                    }
                }
                
                // Section 2: Barter Valuation & Trade Preferences
                Section(
                    header: Text("Barter Valuation & What You Want"),
                    footer: Text("Estimated value gives barter partners a fair benchmark for cashless trades.")
                ) {
                    HStack {
                        Text("Estimated Value ($)")
                        Spacer()
                        TextField("250", text: $estimatedValueText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("What are you looking to trade this for?")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        TextField("e.g. Mirrorless lenses, mechanical keyboards, camping gear...", text: $preferredTrades, axis: .vertical)
                            .lineLimit(3...4)
                            .font(.system(size: 14))
                    }
                    .padding(.vertical, 4)
                }
                
                // Section 3: Description & Tags
                Section(header: Text("Detailed Description")) {
                    TextField("Describe wear, included accessories, box, serial number, etc.", text: $description, axis: .vertical)
                        .lineLimit(4...6)
                        .font(.system(size: 14))
                    
                    TextField("Tags (comma separated)", text: $tagsText)
                        .font(.system(size: 14))
                }
                
                // Section 4: Visual Icon Selection
                Section(header: Text("Visual Icon Badge")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(iconOptions, id: \.self) { icon in
                                let isSelected = selectedIcon == icon
                                Button {
                                    selectedIcon = icon
                                    AppTheme.triggerHaptic(style: .light)
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isSelected ? AppTheme.primary : Color(UIColor.tertiarySystemGroupedBackground))
                                            .frame(width: 48, height: 48)
                                        
                                        Image(systemName: icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(isSelected ? .white : .primary)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("List Item for Barter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("List Item") {
                        saveItem()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primary)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showSmartAppraisal) {
                SmartAppraisalModalView(initialTitle: title) { result in
                    applyAppraisalResult(result)
                }
            }
        }
    }
    
    private func applyAppraisalResult(_ result: AppraisalResult) {
        if title.isEmpty || title == "Item Title" {
            title = result.detectedTitle
        }
        category = result.predictedCategory
        condition = result.predictedCondition
        estimatedValueText = "\(Int(result.estimatedFairValue))"
        tagsText = result.suggestedTags.joined(separator: ", ")
        
        switch result.predictedCategory {
        case .electronics: selectedIcon = "laptopcomputer"
        case .gaming: selectedIcon = "gamecontroller.fill"
        case .cameras: selectedIcon = "camera.fill"
        case .fashion: selectedIcon = "tshirt.fill"
        case .musicalInstruments: selectedIcon = "guitars.fill"
        case .outdoorSports: selectedIcon = "figure.hiking"
        case .booksMedia: selectedIcon = "books.vertical.fill"
        case .homeGarden: selectedIcon = "house.fill"
        default: break
        }
    }
    
    private func saveItem() {
        let value = Double(estimatedValueText) ?? 100.0
        let tagList = tagsText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        
        let newItem = Item(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? "No description provided." : description,
            category: category,
            condition: condition,
            estimatedValue: value,
            preferredTrades: preferredTrades.isEmpty ? "Open to interesting tech and gear trades!" : preferredTrades,
            images: [selectedIcon],
            ownerId: userStore.currentUser.id,
            ownerName: userStore.currentUser.displayName,
            ownerAvatar: userStore.currentUser.avatar,
            ownerRating: userStore.currentUser.rating,
            ownerLocation: userStore.currentUser.location,
            status: .available,
            tags: tagList.isEmpty ? [category.rawValue] : tagList,
            createdAt: Date()
        )
        
        itemStore.addItem(newItem)
        dismiss()
    }
}

#Preview {
    AddItemView()
        .environmentObject(ItemStore())
        .environmentObject(UserStore())
}
