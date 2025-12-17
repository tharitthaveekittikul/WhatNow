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
}
