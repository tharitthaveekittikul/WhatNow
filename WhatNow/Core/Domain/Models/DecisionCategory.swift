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

    var title: String {
        switch self {
        case .food: return String(localized: "What to Eat?")
        case .activity: return String(localized: "What to Do?")
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

    var title: String {
        switch self {
        case .mall: return String(localized: "Mall Stores")
        case .famous: return String(localized: "Famous Stores")
        }
    }

    var emoji: String {
        switch self {
        case .mall: return "🏬"
        case .famous: return "⭐"
        }
    }
}
