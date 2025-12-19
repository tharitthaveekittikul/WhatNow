//
//  UserDefaultsSettingsStore.swift
//  WhatNow
//
//  Infrastructure - UserDefaults-based Settings Store
//

import Foundation

/// UserDefaults-based settings persistence
actor UserDefaultsSettingsStore: SettingsStore {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let appearanceMode = "app.settings.appearanceMode"
        static let language = "app.settings.language"
        static let settings = "app.settings.all"
    }

    nonisolated var appearanceMode: AppearanceMode {
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

    nonisolated var language: Language {
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

    nonisolated var settings: Settings {
        get async {
            await loadSettings()
        }
    }

    private func loadSettings() -> Settings {
        if let data = defaults.data(forKey: Keys.settings),
           let settings = try? JSONDecoder().decode(Settings.self, from: data) {
            return settings
        }
        return Settings.default
    }

    func update(_ settings: Settings) async throws {
        let data = try JSONEncoder().encode(settings)
        defaults.set(data, forKey: Keys.settings)

        // Also update individual keys for backward compatibility
        defaults.set(settings.appearanceMode.rawValue, forKey: Keys.appearanceMode)
        defaults.set(settings.language.rawValue, forKey: Keys.language)

        // Post notification for language changes
        NotificationCenter.default.post(name: .languageDidChange, object: settings.language)
    }
}

extension Notification.Name {
    static let languageDidChange = Notification.Name("app.languageDidChange")
}
