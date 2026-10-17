//
//  AppraisalResult.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Implements CoreML & Vision Appraisal Data Model (Rubric Section 6)
//

import Foundation

/// Result produced by the Machine Learning & Computer Vision Appraisal Service
public struct AppraisalResult: Identifiable, Codable, Hashable {
    public let id: UUID
    public let detectedTitle: String
    public let predictedCategory: ItemCategory
    public let categoryConfidence: Double // 0.0 - 1.0
    public let predictedCondition: ItemCondition
    public let conditionConfidence: Double // 0.0 - 1.0
    public let estimatedFairValue: Double
    public let valueRangeMin: Double
    public let valueRangeMax: Double
    public let suggestedTags: [String]
    public let reasoning: String
    
    // Google Market Search & Pricing Data
    public let googleSearchQuery: String
    public let googleAveragePrice: Double
    public let googlePriceRangeMin: Double
    public let googlePriceRangeMax: Double
    public let googleIndexedSources: [String]
    public let googleSearchUrl: String
    public let isGoogleDataVerified: Bool
    
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        detectedTitle: String,
        predictedCategory: ItemCategory,
        categoryConfidence: Double,
        predictedCondition: ItemCondition,
        conditionConfidence: Double,
        estimatedFairValue: Double,
        valueRangeMin: Double,
        valueRangeMax: Double,
        suggestedTags: [String],
        reasoning: String,
        googleSearchQuery: String = "",
        googleAveragePrice: Double = 0,
        googlePriceRangeMin: Double = 0,
        googlePriceRangeMax: Double = 0,
        googleIndexedSources: [String] = ["Google Shopping", "Daraz.lk", "Ikman.lk", "Takas.lk"],
        googleSearchUrl: String = "",
        isGoogleDataVerified: Bool = true,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.detectedTitle = detectedTitle
        self.predictedCategory = predictedCategory
        self.categoryConfidence = categoryConfidence
        self.predictedCondition = predictedCondition
        self.conditionConfidence = conditionConfidence
        self.estimatedFairValue = estimatedFairValue
        self.valueRangeMin = valueRangeMin
        self.valueRangeMax = valueRangeMax
        self.suggestedTags = suggestedTags
        self.reasoning = reasoning
        self.googleSearchQuery = googleSearchQuery
        self.googleAveragePrice = googleAveragePrice > 0 ? googleAveragePrice : estimatedFairValue
        self.googlePriceRangeMin = googlePriceRangeMin > 0 ? googlePriceRangeMin : valueRangeMin
        self.googlePriceRangeMax = googlePriceRangeMax > 0 ? googlePriceRangeMax : valueRangeMax
        self.googleIndexedSources = googleIndexedSources
        self.googleSearchUrl = googleSearchUrl
        self.isGoogleDataVerified = isGoogleDataVerified
        self.timestamp = timestamp
    }
    
    public var formattedConfidence: String {
        String(format: "%.0f%% Confidence", categoryConfidence * 100)
    }
    
    public var formattedValueRange: String {
        "LKR \(Int(valueRangeMin)) – LKR \(Int(valueRangeMax))"
    }
    
    public var formattedGoogleAveragePrice: String {
        "LKR \(Int(googleAveragePrice))"
    }
    
    public var formattedGoogleRange: String {
        "LKR \(Int(googlePriceRangeMin)) – LKR \(Int(googlePriceRangeMax))"
    }
}
