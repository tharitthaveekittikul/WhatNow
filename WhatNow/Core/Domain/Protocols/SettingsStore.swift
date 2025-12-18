//
//  SettingsStore.swift
//  WhatNow
//
//  Domain Protocol - Settings Store
//

import Foundation

/// Protocol for persisting app settings
protocol SettingsStore {
    var appearanceMode: AppearanceMode { get set }
    var language: Language { get set }
}
