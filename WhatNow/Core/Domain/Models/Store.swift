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
    let categories: [StoreCategory]
}

struct Taxonomy: Hashable, Sendable, Codable {
    let categoryIds: [String]
}
