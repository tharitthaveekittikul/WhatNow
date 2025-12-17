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

    init(container: DependencyContainer? = nil) {
        let cont = container ?? DependencyContainer.shared
        self.container = cont

        // Load initial appearance mode
        let savedMode = cont.settingsStore.appearanceMode
        self.colorScheme = savedMode.colorScheme
    }
}
