//
//  Language.swift
//  WhatNow
//
//  Domain Model - Language
//

import Foundation

/// App language
enum Language: String, CaseIterable, Identifiable, Codable {
    case thai = "th"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .thai: return String(localized: "Thai")
        case .english: return String(localized: "English")
        }
    }

    var flag: String {
        switch self {
        case .thai: return "🇹🇭"
        case .english: return "🇺🇸"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }
}
