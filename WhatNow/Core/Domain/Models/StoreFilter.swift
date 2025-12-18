//
//  StoreFilter.swift
//  WhatNow
//
//  Domain Model - Store Filter
//

import Foundation

/// Filter criteria for stores
struct StoreFilter: Equatable {
    var selectedCategories: Set<String> = []
    var selectedPriceRanges: Set<PriceRange> = []

    /// Check if any filters are active
    var isActive: Bool {
        !selectedCategories.isEmpty || !selectedPriceRanges.isEmpty
    }

    /// Count of active filters
    var activeFilterCount: Int {
        selectedCategories.count + selectedPriceRanges.count
    }

    /// Apply filter to stores
    func apply(to stores: [Store]) -> [Store] {
        var filtered = stores

        // Filter by categories
        if !selectedCategories.isEmpty {
            filtered = filtered.filter { store in
                !Set(store.tags).isDisjoint(with: selectedCategories)
            }
        }

        // Filter by price ranges
        if !selectedPriceRanges.isEmpty {
            filtered = filtered.filter { store in
                selectedPriceRanges.contains(store.priceRange)
            }
        }

        return filtered
    }

    /// Clear all filters
    mutating func clear() {
        selectedCategories.removeAll()
        selectedPriceRanges.removeAll()
    }
}

/// Available categories extracted from stores
struct CategoryOption: Identifiable, Hashable {
    let id: String
    let count: Int

    init(tag: String, count: Int) {
        self.id = tag
        self.count = count
    }

    /// Display name for category
    func displayName(for language: Language) -> String {
        // Convert tag like "korean" to "Korean"
        let formatted = id.replacingOccurrences(of: "_", with: " ").capitalized
        // You can add proper translations later if needed
        return formatted
    }
}

/// Price range option with count
struct PriceRangeOption: Identifiable, Hashable {
    let priceRange: PriceRange
    let count: Int

    var id: String { priceRange.rawValue }
}
