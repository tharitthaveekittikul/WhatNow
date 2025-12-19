//
//  DecisionCategory.swift
//  WhatNow
//
//  Domain Model - Decision Categories
//

import Foundation

/// Top-level decision categories
enum DecisionCategory: String, CaseIterable, Identifiable {
    case food = "What to Eat?"
    case activity = "What to Do?"

    var id: String { rawValue }

    func title(for language: Language) -> String {
        switch self {
        case .food: return "What to Eat?".localized(for: language)
        case .activity: return "What to Do?".localized(for: language)
        }
    }

    var emoji: String {
        switch self {
        case .food: return "🍽️"
        case .activity: return "🎯"
        }
    }
}

/// Food source type
enum FoodSourceType: String, CaseIterable, Identifiable {
    case mall = "Mall Stores"
    case famous = "Famous Stores"

    var id: String { rawValue }

    func title(for language: Language) -> String {
        switch self {
        case .mall: return "Mall Stores".localized(for: language)
        case .famous: return "Famous Stores".localized(for: language)
        }
    }

    var emoji: String {
        switch self {
        case .mall: return "🏬"
        case .famous: return "⭐"
        }
    }
}

/// Activity source type
enum ActivitySourceType: String, CaseIterable, Identifiable {
    case indoor = "Indoor Activities"
    case outdoor = "Outdoor Activities"
    case entertainment = "Entertainment"

    var id: String { rawValue }

    func title(for language: Language) -> String {
        switch self {
        case .indoor: return "Indoor Activities".localized(for: language)
        case .outdoor: return "Outdoor Activities".localized(for: language)
        case .entertainment: return "Entertainment".localized(for: language)
        }
    }

    var emoji: String {
        switch self {
        case .indoor: return "🏢"
        case .outdoor: return "🏞️"
        case .entertainment: return "🎬"
        }
    }
}
