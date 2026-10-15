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
        self.timestamp = timestamp
    }
    
    public var formattedConfidence: String {
        String(format: "%.0f%% Confidence", categoryConfidence * 100)
    }
    
    public var formattedValueRange: String {
        "LKR \(Int(valueRangeMin)) – LKR \(Int(valueRangeMax))"
    }
}
