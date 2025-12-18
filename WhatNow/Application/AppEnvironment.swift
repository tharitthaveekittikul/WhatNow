//
//  AppEnvironment.swift
//  WhatNow
//
//  App Environment - Global app state
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class AppEnvironment: ObservableObject {
    // Dependency container
    let container: DependencyContainer

    // Appearance mode
    @Published var colorScheme: ColorScheme?

    // Language
    @Published var locale: Locale
    @Published var currentLanguage: Language
    @Published var languageDidChange = UUID() // For triggering view updates

    private var cancellables = Set<AnyCancellable>()

    init(container: DependencyContainer? = nil) {
        let cont = container ?? DependencyContainer.shared
        self.container = cont

        // Load initial appearance mode
        let savedMode = cont.settingsStore.appearanceMode
        self.colorScheme = savedMode.colorScheme

        // Load initial language
        let savedLanguage = cont.settingsStore.language
        self.locale = savedLanguage.locale
        self.currentLanguage = savedLanguage

        // Listen for language changes
        NotificationCenter.default.publisher(for: .languageDidChange)
            .compactMap { $0.object as? Language }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] language in
                self?.locale = language.locale
                self?.currentLanguage = language
                self?.languageDidChange = UUID() // Trigger view refresh
            }
            .store(in: &cancellables)
    }
}
