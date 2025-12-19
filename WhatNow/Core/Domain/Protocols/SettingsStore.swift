//
//  SettingsStore.swift
//  WhatNow
//
//  Domain Protocol - Settings Store
//

import Foundation

/// App settings model
struct Settings: Sendable, Codable {
    var appearanceMode: AppearanceMode
    var language: Language
    var hasLaunchedBefore: Bool
    var lastInterstitialAdTime: Date?

    static let `default` = Settings(
        appearanceMode: .system,
        language: .thai,
        hasLaunchedBefore: false,
        lastInterstitialAdTime: nil
    )
}

/// Protocol for persisting app settings
protocol SettingsStore: Sendable {
    var appearanceMode: AppearanceMode { get set }
    var language: Language { get set }

    /// Get current settings
    var settings: Settings { get async }

    /// Update settings
    func update(_ settings: Settings) async throws
}
