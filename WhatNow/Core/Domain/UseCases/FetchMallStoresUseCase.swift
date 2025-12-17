//
//  FetchMallStoresUseCase.swift
//  WhatNow
//
//  Use Case - Fetch Mall Stores
//

import Foundation

/// Use case for fetching stores from a specific mall
protocol FetchMallStoresUseCase {
    func execute(mallId: String) async throws -> MallPack
}

/// Default implementation
final class DefaultFetchMallStoresUseCase: FetchMallStoresUseCase {
    private let packsService: PacksService

    init(packsService: PacksService) {
        self.packsService = packsService
    }

    func execute(mallId: String) async throws -> MallPack {
        try await packsService.fetchMallStores(mallId: mallId)
    }
}
