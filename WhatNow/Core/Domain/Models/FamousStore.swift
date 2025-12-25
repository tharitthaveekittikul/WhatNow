//
//  FamousStore.swift
//  WhatNow
//
//  Domain Model - Famous Stores
//

import Foundation

/// Famous store item
struct FamousStoreItem: Identifiable, Hashable, Sendable, Codable {
    let id: String
    let name: String
    let tags: [String]
    let priceRange: PriceRange
    let suggestedMalls: [String]?
    let mapUrl: String?
}

/// Famous stores pack response
struct FamousStoresPack: Sendable, Codable {
    let version: Int
    let updatedAt: String
    let titleTH: String?  // Optional for backward compatibility
    let titleEN: String?  // Optional for backward compatibility
    let taxonomy: Taxonomy?  // New API format includes taxonomy
    let items: [FamousStoreItem]

    /// Get title in specified language (with fallback)
    func title(for language: Language) -> String {
        switch language {
        case .thai:
            return titleTH ?? titleEN ?? "Famous Stores"
        case .english:
            return titleEN ?? titleTH ?? "Famous Stores"
        }
    }
}
