//
//  LocalizationHelper.swift
//  WhatNow
//
//  Localization Helper - Custom localization that respects app language setting
//

import Foundation

/// Helper for localizing strings based on app language setting (not system language)
struct LocalizationHelper {
    static func localized(_ key: String, language: Language, comment: String = "") -> String {
        // Get the bundle for the selected language
        guard let bundlePath = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: bundlePath) else {
            // Fallback to main bundle
            return NSLocalizedString(key, comment: comment)
        }

        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}

/// String extension for convenient localization
extension String {
    /// Get localized string for the given language
    func localized(for language: Language) -> String {
        LocalizationHelper.localized(self, language: language)
    }
}
