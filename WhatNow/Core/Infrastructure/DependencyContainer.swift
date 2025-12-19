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
        self.adsService = GoogleMobileAdsService(logger: logger)

        // Initialize use cases
        self.fetchMallsUseCase = DefaultFetchMallsUseCase(packsService: packsService)
        self.fetchMallStoresUseCase = DefaultFetchMallStoresUseCase(packsService: packsService)
    }
}
