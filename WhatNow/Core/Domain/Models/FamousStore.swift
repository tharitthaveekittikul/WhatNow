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
}

/// Famous stores pack response
struct FamousStoresPack: Sendable, Codable {
    let version: Int
    let updatedAt: String
    let titleTH: String
    let titleEN: String
    let items: [FamousStoreItem]
}
