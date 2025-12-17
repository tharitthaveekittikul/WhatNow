//
//  Store.swift
//  WhatNow
//
//  Domain Model - Store/Restaurant
//

import Foundation

/// Represents a store or restaurant
struct Store: Identifiable, Codable, Hashable {
    let id: String
    let name: LocalizedName
    let displayName: String
    let tags: [String]
    let priceRange: PriceRange
}

/// Price range for stores
enum PriceRange: String, Codable, CaseIterable {
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
struct StoreCategory: Identifiable, Codable, Hashable {
    let id: String
    let name: LocalizedName
    let items: [Store]
}

/// Mall pack response
struct MallPack: Codable {
    let version: Int
    let updatedAt: String
    let mall: Mall
    let taxonomy: Taxonomy
    let categories: [StoreCategory]
}

struct Taxonomy: Codable, Hashable {
    let categoryIds: [String]
}
