//
//  DependencyContainer.swift
//  WhatNow
//
//  Dependency Injection Container
//

import Foundation

/// Simple dependency injection container
final class DependencyContainer: @unchecked Sendable {
    static let shared = DependencyContainer()

    // MARK: - Infrastructure

    let logger: Logger
    let cacheService: CacheService
    let settingsStore: SettingsStore

    // MARK: - Services

    let packsService: PacksService
    let adsService: AdsService
    let purchaseService: PurchaseService
    let spinSessionTracker: SpinSessionTracker
    let interstitialAdManager: InterstitialAdManager

    // MARK: - Use Cases

    let fetchMallsUseCase: FetchMallsUseCase
    let fetchMallStoresUseCase: FetchMallStoresUseCase

    private init() {
        // Initialize infrastructure
        self.logger = ConsoleLogger()
        self.cacheService = FileManagerCacheService(logger: logger)
        self.settingsStore = UserDefaultsSettingsStore()

        // Initialize services
        self.packsService = CachedAPIPacksService(
            cache: cacheService,
            logger: logger
        )
        self.purchaseService = StoreKitPurchaseService(logger: logger)
        self.adsService = GoogleMobileAdsService(
            logger: logger,
            purchaseService: purchaseService
        )
        self.spinSessionTracker = DefaultSpinSessionTracker(
            settingsStore: settingsStore,
            logger: logger
        )
        self.interstitialAdManager = DefaultInterstitialAdManager(
            spinTracker: spinSessionTracker,
            adsService: adsService,
            settingsStore: settingsStore,
            logger: logger
        )

        // Initialize use cases
        self.fetchMallsUseCase = DefaultFetchMallsUseCase(packsService: packsService)
        self.fetchMallStoresUseCase = DefaultFetchMallStoresUseCase(packsService: packsService)
    }
}
