//
//  Store.swift
//  WhatNow
//
//  Domain Model - Store/Restaurant
//

import Foundation

/// Represents a store or restaurant
struct Store: Identifiable, Hashable, Sendable, Codable {
    let id: String
    let name: LocalizedName
    let displayName: String
    let tags: [String]
    let priceRange: PriceRange
    let location: StoreLocation?
    let detailUrl: String?
    let mapUrl: String?
    let logoUrl: String?
}

/// Store location information
struct StoreLocation: Hashable, Sendable, Codable {
    let floor: String?
    let zone: String?
    let unit: String?

    var displayText: String {
        var components: [String] = []
        if let floor = floor {
            components.append(String(localized: "Floor \(floor)"))
        }
        if let zone = zone {
            components.append("Zone \(zone)")
        }
        if let unit = unit {
            components.append("Unit \(unit)")
        }
        return components.isEmpty ? "Location not available" : components.joined(separator: " • ")
    }
}

/// Price range for stores
enum PriceRange: String, CaseIterable, Sendable, Codable {
    case budget
    case mid
    case premium

    var displayText: String {
        switch self {
        case .budget: return "฿"
        case .mid: return "฿฿"
        case .premium: return "฿฿฿"
        }
    }
}

/// Category of stores
struct StoreCategory: Identifiable, Hashable, Sendable, Codable {
    let id: String
    let name: LocalizedName
    let items: [Store]
}

/// Mall pack response
struct MallPack: Sendable, Codable {
    let version: Int
    let updatedAt: String
    let mall: Mall
    let taxonomy: Taxonomy
    let stores: [Store]

    enum CodingKeys: String, CodingKey {
        case version, updatedAt, mall, taxonomy
        case stores = "items" // New API uses "items"
        case categories // Old API uses "categories"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        mall = try container.decode(Mall.self, forKey: .mall)
        taxonomy = try container.decode(Taxonomy.self, forKey: .taxonomy)

        // Try new format first (items), fallback to old format (categories)
        if let items = try? container.decode([Store].self, forKey: .stores) {
            // New API format: flat array of stores
            stores = items
        } else if let categories = try? container.decode([StoreCategory].self, forKey: .categories) {
            // Old API format: array of categories containing stores
            // Use the "all" category if available, otherwise deduplicate across all categories
            if let allCategory = categories.first(where: { $0.id == "all" }) {
                stores = allCategory.items
            } else {
                // Deduplicate by ID to avoid crashes from duplicate stores across categories
                let allStores = categories.flatMap { $0.items }
                var uniqueStores: [String: Store] = [:]
                for store in allStores {
                    uniqueStores[store.id] = store
                }
                stores = Array(uniqueStores.values)
            }
        } else {
            stores = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(mall, forKey: .mall)
        try container.encode(taxonomy, forKey: .taxonomy)
        try container.encode(stores, forKey: .stores)
    }
}

/// Category metadata (new API format)
struct Category: Identifiable, Hashable, Sendable, Codable {
    let id: String
    let name: LocalizedName
    let order: Int?
}

struct Taxonomy: Hashable, Sendable, Codable {
    let categoryIds: [String]? // Old API format
    let categories: [Category]? // New API format

    /// Get all category IDs (works with both old and new format)
    var allCategoryIds: [String] {
        if let ids = categoryIds {
            return ids
        } else if let cats = categories {
            return cats.map { $0.id }
        }
        return []
    }

    /// Get category name by ID (only works with new format)
    func categoryName(for id: String, language: Language) -> String? {
        categories?.first(where: { $0.id == id })?.name.localized(for: language)
    }
}
