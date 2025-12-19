//
//  InterstitialAdManager.swift
//  WhatNow
//
//  Manages interstitial ad display logic for spin screens
//

import Foundation

/// Protocol for managing interstitial ads
protocol InterstitialAdManager: Sendable {
    /// Check if an interstitial ad should be shown after a spin
    /// - Returns: True if ad should be shown
    func shouldShowInterstitialAfterSpin() async -> Bool

    /// Record that a spin occurred
    func recordSpin() async

    /// Record that an interstitial ad was shown
    func recordInterstitialShown() async

    /// Preload the next interstitial ad
    func preloadInterstitial() async

    /// Show the interstitial ad
    /// - Returns: True if ad was shown successfully
    func showInterstitial() async -> Bool
}

/// Implementation of InterstitialAdManager
actor DefaultInterstitialAdManager: InterstitialAdManager {

    // MARK: - Properties

    private let spinTracker: SpinSessionTracker
    private let adsService: AdsService
    private let settingsStore: SettingsStore
    private let logger: Logger

    // Configuration
    private let spinsBeforeAd = 2  // Show ad on 3rd spin (after 2 free spins)
    private let minimumAdInterval: TimeInterval = 10 * 60  // 10 minutes

    // MARK: - Initialization

    init(
        spinTracker: SpinSessionTracker,
        adsService: AdsService,
        settingsStore: SettingsStore,
        logger: Logger
    ) {
        self.spinTracker = spinTracker
        self.adsService = adsService
        self.settingsStore = settingsStore
        self.logger = logger
    }

    // MARK: - InterstitialAdManager

    func shouldShowInterstitialAfterSpin() async -> Bool {
        // Check if ads are disabled (Pro user)
        let adsDisabled = await adsService.areAdsDisabled
        if adsDisabled {
            logger.debug("Interstitial skipped: Ads disabled (Pro user)", category: .business)
            return false
        }

        // Check if first launch
        let isFirstLaunch = await spinTracker.isFirstLaunch
        if isFirstLaunch {
            logger.debug("Interstitial skipped: First launch", category: .business)
            return false
        }

        // Check spin count (need at least 3 spins: 0, 1, 2 free -> show on 3rd)
        let spinCount = await spinTracker.spinCount
        if spinCount <= spinsBeforeAd {
            logger.debug("Interstitial skipped: Only \(spinCount) spins (need >\(spinsBeforeAd))", category: .business)
            return false
        }

        // Check if enough time has passed since last ad
        let settings = await settingsStore.settings
        if let lastAdTime = settings.lastInterstitialAdTime {
            let timeSinceLastAd = Date().timeIntervalSince(lastAdTime)
            if timeSinceLastAd < minimumAdInterval {
                let remaining = minimumAdInterval - timeSinceLastAd
                logger.debug("Interstitial skipped: Last ad was \(Int(timeSinceLastAd))s ago (need \(Int(minimumAdInterval))s, \(Int(remaining))s remaining)", category: .business)
                return false
            }
        }

        logger.info("Interstitial should show: spinCount=\(spinCount), conditions met", category: .business)
        return true
    }

    func recordSpin() async {
        await spinTracker.incrementSpinCount()
        let count = await spinTracker.spinCount
        logger.debug("Spin recorded: total=\(count)", category: .business)
    }

    func recordInterstitialShown() async {
        var settings = await settingsStore.settings
        settings.lastInterstitialAdTime = Date()
        try? await settingsStore.update(settings)
        logger.info("Interstitial ad shown and recorded", category: .business)
    }

    func preloadInterstitial() async {
        do {
            try await adsService.loadAd(for: .interstitial)
            logger.debug("Interstitial ad preloaded", category: .business)
        } catch {
            logger.error("Failed to preload interstitial ad", category: .business, error: error)
        }
    }

    func showInterstitial() async -> Bool {
        let shown = await adsService.showAd(for: .interstitial)
        if shown {
            await recordInterstitialShown()
        }
        return shown
    }
}
