//
//  SettingsViewModel.swift
//  WhatNow
//
//  ViewModel for Settings
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var selectedAppearance: AppearanceMode {
        didSet {
            settingsStore.appearanceMode = selectedAppearance
            // Update app environment directly
            appEnvironment?.colorScheme = selectedAppearance.colorScheme
        }
    }

    @Published var selectedLanguage: Language {
        didSet {
            settingsStore.language = selectedLanguage
        }
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var settingsStore: SettingsStore
    var appEnvironment: AppEnvironment?

    init(
        settingsStore: SettingsStore? = nil,
        appEnvironment: AppEnvironment? = nil
    ) {
        let store = settingsStore ?? DependencyContainer.shared.settingsStore
        self.settingsStore = store
        self.appEnvironment = appEnvironment
        self.selectedAppearance = store.appearanceMode
        self.selectedLanguage = store.language
    }
}
