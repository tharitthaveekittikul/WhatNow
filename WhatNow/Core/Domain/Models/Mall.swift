//
//  Mall.swift
//  WhatNow
//
//  Domain Model - Mall
//

import Foundation

/// Represents a shopping mall
struct Mall: Identifiable, Hashable, Sendable, Codable {
    let mallId: String
    let name: LocalizedName
    let displayName: String
    let city: String
    let assetKey: String
    let tags: [String]?

    var id: String { mallId }
}

/// Localized name for entities
struct LocalizedName: Hashable, Sendable, Codable {
    let th: String?
    let en: String?

    /// Get the best available name (fallback to non-nil value)
    var bestAvailable: String {
        th ?? en ?? "Unknown"
    }
}

/// Mall index response
struct MallsIndex: Sendable, Codable {
    let version: Int
    let updatedAt: String
    let malls: [Mall]
}
