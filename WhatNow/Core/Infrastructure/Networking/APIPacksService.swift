//
//  APIPacksService.swift
//  WhatNow
//
//  Infrastructure - API Packs Service Implementation
//

import Foundation

/// API-based implementation of PacksService
final class APIPacksService: PacksService {
    private let baseURL: String
    private let session: URLSession

    init(
        baseURL: String = "https://whatnow-api-867193034636.asia-southeast1.run.app",
//        baseURL: String = "http://192.168.1.36:8080",
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    // MARK: - Private Helper

    /// Generic fetch method with proper error handling
    private func fetch<T: Decodable>(_ type: T.Type, from endpoint: String) async throws -> T {
        let url = URL(string: "\(baseURL)\(endpoint)")!

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.parse(from: data, statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Malls

    func fetchMalls() async throws -> [Mall] {
        let mallsIndex = try await fetch(MallsIndex.self, from: "/v1/packs/malls/index")
        return mallsIndex.malls
    }

    func fetchMallStores(mallId: String) async throws -> MallPack {
        try await fetch(MallPack.self, from: "/v1/packs/malls/\(mallId)")
    }

    // MARK: - Famous Stores

    func fetchFamousStores() async throws -> FamousStoresPack {
        try await fetch(FamousStoresPack.self, from: "/v1/packs/food/famous-stores")
    }

    // MARK: - Starred Restaurants

    func fetchMichelinRestaurants() async throws -> MallPack {
        try await fetch(MallPack.self, from: "/v1/packs/food/michelin-thailand")
    }

    // MARK: - Activities

    func fetchActivityCategories() async throws -> ActivitiesIndex {
        try await fetch(ActivitiesIndex.self, from: "/v1/packs/activities/index")
    }

    func fetchActivities(categoryId: String) async throws -> ActivityPack {
        try await fetch(ActivityPack.self, from: "/v1/packs/activities/\(categoryId)")
    }

    // MARK: - Configuration & Metadata

    func fetchAppConfig() async throws -> AppConfig {
        try await fetch(AppConfig.self, from: "/v1/packs/config")
    }

    func fetchPriceRanges() async throws -> PriceRangesPack {
        try await fetch(PriceRangesPack.self, from: "/v1/packs/meta/price-ranges")
    }

    func fetchTags() async throws -> TagsPack {
        try await fetch(TagsPack.self, from: "/v1/packs/meta/tags")
    }

    func fetchCatalog() async throws -> CatalogPack {
        try await fetch(CatalogPack.self, from: "/v1/packs/catalog")
    }
}
