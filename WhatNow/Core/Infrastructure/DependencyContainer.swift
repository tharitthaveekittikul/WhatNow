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

    // MARK: - Services

    lazy var packsService: PacksService = {
        APIPacksService()
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
