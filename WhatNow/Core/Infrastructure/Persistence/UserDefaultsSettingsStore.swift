//
//  UserDefaultsSettingsStore.swift
//  WhatNow
//
//  Infrastructure - UserDefaults-based Settings Store
//

import Foundation

/// UserDefaults-based settings persistence
final class UserDefaultsSettingsStore: SettingsStore {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let appearanceMode = "app.settings.appearanceMode"
        static let language = "app.settings.language"
    }

    var appearanceMode: AppearanceMode {
        get {
            guard let rawValue = defaults.string(forKey: Keys.appearanceMode),
                  let mode = AppearanceMode(rawValue: rawValue) else {
                return .system
            }
            return mode
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.appearanceMode)
        }
    }

    var language: Language {
        get {
            guard let rawValue = defaults.string(forKey: Keys.language),
                  let lang = Language(rawValue: rawValue) else {
                return .thai  // Default to Thai
            }
            return lang
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.language)
            // Post notification to update the environment
            NotificationCenter.default.post(name: .languageDidChange, object: newValue)
        }
    }
}

extension Notification.Name {
    static let languageDidChange = Notification.Name("app.languageDidChange")
}
