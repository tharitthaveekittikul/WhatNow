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
        case .thai: return "Thai".localized(for: self)
        case .english: return "English".localized(for: self)
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
