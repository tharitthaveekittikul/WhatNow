//
//  SpinSessionTracker.swift
//  WhatNow
//
//  Tracks spin statistics per session for interstitial ad logic
//

import Foundation

/// Protocol for tracking spin session state
protocol SpinSessionTracker: Sendable {
    /// Get current spin count in this session
    var spinCount: Int { get async }

    /// Check if this is the first app launch ever
    var isFirstLaunch: Bool { get async }

    /// Increment spin counter
    func incrementSpinCount() async

    /// Reset spin counter (called when session ends)
    func resetSpinCount() async

    /// Mark app as launched (first time setup)
    func markAppLaunched() async
}

/// Implementation of SpinSessionTracker
actor DefaultSpinSessionTracker: SpinSessionTracker {

    private var sessionSpinCount: Int = 0
    private let settingsStore: SettingsStore
    private let logger: Logger

    nonisolated var spinCount: Int {
        get async {
            await getSpinCount()
        }
    }

    nonisolated var isFirstLaunch: Bool {
        get async {
            await checkIsFirstLaunch()
        }
    }

    init(settingsStore: SettingsStore, logger: Logger) {
        self.settingsStore = settingsStore
        self.logger = logger
    }

    private func getSpinCount() -> Int {
        sessionSpinCount
    }

    private func checkIsFirstLaunch() async -> Bool {
        let settings = await settingsStore.settings
        return settings.hasLaunchedBefore == false
    }

    func incrementSpinCount() async {
        sessionSpinCount += 1
        logger.debug("Spin count incremented to \(sessionSpinCount)", category: .business)
    }

    func resetSpinCount() async {
        sessionSpinCount = 0
        logger.debug("Spin count reset", category: .business)
    }

    func markAppLaunched() async {
        var settings = await settingsStore.settings
        if !settings.hasLaunchedBefore {
            settings.hasLaunchedBefore = true
            try? await settingsStore.update(settings)
            logger.info("First launch marked", category: .business)
        }
    }
}
