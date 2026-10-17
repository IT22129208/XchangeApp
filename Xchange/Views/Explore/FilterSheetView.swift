//
//  FilterSheetView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//

import SwiftUI

public struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var itemStore: ItemStore
    
    @State private var tempCategory: ItemCategory
    @State private var tempCondition: ItemCondition?
    @State private var tempMaxPrice: Double
    @State private var tempSort: ItemStore.ItemSortOption
    @State private var tempDistrict: SriLankaDistrict
    
    public init(itemStore: ItemStore) {
        self.itemStore = itemStore
        _tempCategory = State(initialValue: itemStore.selectedCategory)
        _tempCondition = State(initialValue: itemStore.selectedConditionFilter)
        _tempMaxPrice = State(initialValue: itemStore.maxPriceFilter)
        _tempSort = State(initialValue: itemStore.sortBy)
        _tempDistrict = State(initialValue: itemStore.selectedDistrictFilter)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Category Section
                Section(header: Text("Category")) {
                    Picker("Category", selection: $tempCategory) {
                        ForEach(ItemCategory.allCases) { category in
                            HStack {
                                Image(systemName: category.systemIcon)
                                Text(category.rawValue)
                            }.tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // District / Region Section
                Section(header: Text("District / Location")) {
                    Picker("District", selection: $tempDistrict) {
                        Text("🇱🇰 All Sri Lanka (Entire Country)").tag(SriLankaDistrict.all)
                        ForEach(SriLankaDistrict.allDistricts, id: \.self) { district in
                            Text("\(district.rawValue) (\(district.province))").tag(district)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Condition Filter Section
                Section(header: Text("Item Condition")) {
                    Picker("Condition", selection: $tempCondition) {
                        Text("Any Condition").tag(ItemCondition?.none)
                        ForEach(ItemCondition.allCases) { condition in
                            HStack {
                                Image(systemName: condition.iconName)
                                Text(condition.rawValue)
                            }.tag(ItemCondition?.some(condition))
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Maximum Estimated Value Slider
                Section(header: Text("Maximum Estimated Value")) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Up to")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("LKR \(Int(tempMaxPrice))")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.primary)
                        }
                        
                        Slider(value: $tempMaxPrice, in: 5000...500000, step: 5000)
                            .tint(AppTheme.primary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Sort Order
                Section(header: Text("Sort By")) {
                    Picker("Sort By", selection: $tempSort) {
                        ForEach(ItemStore.ItemSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Reset Filters
                Section {
                    Button(role: .destructive) {
                        tempCategory = .all
                        tempCondition = nil
                        tempMaxPrice = 500000
                        tempSort = .newest
                        tempDistrict = .all
                        AppTheme.triggerHaptic(style: .light)
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset All Filters")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        itemStore.selectedCategory = tempCategory
                        itemStore.selectedConditionFilter = tempCondition
                        itemStore.maxPriceFilter = tempMaxPrice
                        itemStore.sortBy = tempSort
                        itemStore.selectedDistrictFilter = tempDistrict
                        AppTheme.triggerNotificationHaptic(type: .success)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primary)
                }
            }
        }
    }
}
