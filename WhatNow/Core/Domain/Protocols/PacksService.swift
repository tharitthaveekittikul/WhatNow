//
//  PacksService.swift
//  WhatNow
//
//  Domain Protocol - Packs Service
//

import Foundation

/// Service protocol for fetching data packs from the API
protocol PacksService: Sendable {
    // MARK: - Malls
    /// Fetch the list of malls
    func fetchMalls() async throws -> [Mall]

    /// Fetch a specific mall's stores
    func fetchMallStores(mallId: String) async throws -> MallPack

    // MARK: - Famous Stores
    /// Fetch famous stores list
    func fetchFamousStores() async throws -> FamousStoresPack

    // MARK: - Starred Restaurants
    /// Fetch starred restaurants
    func fetchMichelinRestaurants() async throws -> MallPack

    // MARK: - Activities
    /// Fetch activity categories
    func fetchActivityCategories() async throws -> ActivitiesIndex

    /// Fetch activities for a specific category
    func fetchActivities(categoryId: String) async throws -> ActivityPack

    // MARK: - Configuration & Metadata
    /// Fetch app configuration
    func fetchAppConfig() async throws -> AppConfig

    /// Fetch price range metadata
    func fetchPriceRanges() async throws -> PriceRangesPack

    /// Fetch tags metadata
    func fetchTags() async throws -> TagsPack

    /// Fetch catalog/manifest
    func fetchCatalog() async throws -> CatalogPack
}
