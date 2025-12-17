//
//  DependencyContainer.swift
//  WhatNow
//
//  Dependency Injection Container
//

import Foundation

/// Simple dependency injection container
final class DependencyContainer {
    static let shared = DependencyContainer()

    // MARK: - Infrastructure

    lazy var logger: Logger = {
        ConsoleLogger()
    }()

    lazy var cacheService: CacheService = {
        FileManagerCacheService(logger: logger)
    }()

    lazy var settingsStore: SettingsStore = {
        UserDefaultsSettingsStore()
    }()

    // MARK: - Services

    lazy var packsService: PacksService = {
        CachedAPIPacksService(
            cache: cacheService,
            logger: logger
        )
    }()

    // MARK: - Use Cases

    lazy var fetchMallsUseCase: FetchMallsUseCase = {
        DefaultFetchMallsUseCase(packsService: packsService)
    }()

    lazy var fetchMallStoresUseCase: FetchMallStoresUseCase = {
        DefaultFetchMallStoresUseCase(packsService: packsService)
    }()

    private init() {}
}
