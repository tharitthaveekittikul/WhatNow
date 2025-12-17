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
    }
}
