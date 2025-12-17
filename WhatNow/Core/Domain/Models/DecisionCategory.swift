//
//  DecisionCategory.swift
//  WhatNow
//
//  Domain Model - Decision Categories
//

import Foundation

/// Top-level decision categories
enum DecisionCategory: String, CaseIterable, Identifiable {
    case food = "กินอะไรดี"
    case activity = "ทำอะไรดี"

    var id: String { rawValue }

    var title: String {
        rawValue
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
    case mall = "ร้านในห้าง"
    case famous = "ร้านดัง"

    var id: String { rawValue }

    var title: String {
        rawValue
    }

    var emoji: String {
        switch self {
        case .mall: return "🏬"
        case .famous: return "⭐"
        }
    }
}
