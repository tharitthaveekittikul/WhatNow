//
//  FetchMallsUseCase.swift
//  WhatNow
//
//  Use Case - Fetch Malls
//

import Foundation

/// Use case for fetching the list of malls
protocol FetchMallsUseCase {
    func execute() async throws -> [Mall]
}

/// Default implementation
final class DefaultFetchMallsUseCase: FetchMallsUseCase {
    private let packsService: PacksService

    init(packsService: PacksService) {
        self.packsService = packsService
    }

    func execute() async throws -> [Mall] {
        try await packsService.fetchMalls()
    }
}
