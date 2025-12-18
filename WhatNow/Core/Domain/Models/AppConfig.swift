//
//  AppConfig.swift
//  WhatNow
//
//  Domain Model - App Configuration
//

import Foundation

/// App configuration response
struct AppConfig: Sendable, Codable {
    let version: Int
    let updatedAt: String
    let features: FeatureFlags
}

/// Feature flags
struct FeatureFlags: Sendable, Codable {
    let enableMallPacks: Bool
    let enableFamousStores: Bool
    let enableActivities: Bool
    let enableFeedback: Bool
}

/// Price range metadata
struct PriceRangeMetadata: Identifiable, Hashable, Sendable, Codable {
    let id: String
    let nameTH: String
    let nameEN: String

    var displayName: String {
        // TODO: Use locale to determine TH vs EN
        nameTH
    }
}

/// Price ranges response
struct PriceRangesPack: Sendable, Codable {
    let version: Int
    let updatedAt: String
    let ranges: [PriceRangeMetadata]
}

/// Tags metadata response
struct TagsPack: Sendable, Codable {
    let version: Int
    let updatedAt: String
    let foodTags: [String]
    let activityTags: [String]
}

/// Catalog/Manifest response
struct CatalogPack: Sendable, Codable {
    let version: Int
    let updatedAt: String
    let packs: CatalogPacks
    let malls: [CatalogMallEntry]
    let activities: [CatalogActivityEntry]
}

struct CatalogPacks: Sendable, Codable {
    let mallsIndex: CatalogEntry
    let famousStores: CatalogEntry
    let activities: CatalogEntry
    let tags: CatalogEntry
    let priceRanges: CatalogEntry
    let appConfig: CatalogEntry
}

struct CatalogEntry: Sendable, Codable {
    let path: String
    let version: Int
}

struct CatalogMallEntry: Sendable, Codable {
    let mallId: String
    let path: String
    let version: Int
}

struct CatalogActivityEntry: Sendable, Codable {
    let categoryId: String
    let path: String
    let version: Int
}
