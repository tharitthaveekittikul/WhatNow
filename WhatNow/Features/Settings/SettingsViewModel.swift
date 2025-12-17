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
        settingsStore: SettingsStore = DependencyContainer.shared.settingsStore,
        appEnvironment: AppEnvironment? = nil
    ) {
        self.settingsStore = settingsStore
        self.appEnvironment = appEnvironment
        self.selectedAppearance = settingsStore.appearanceMode
    }
}
