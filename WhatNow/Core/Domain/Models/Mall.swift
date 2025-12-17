//
//  Mall.swift
//  WhatNow
//
//  Domain Model - Mall
//

import Foundation

/// Represents a shopping mall
struct Mall: Identifiable, Codable, Hashable {
    let mallId: String
    let name: LocalizedName
    let displayName: String
    let city: String
    let assetKey: String
    let tags: [String]

    var id: String { mallId }
}

/// Localized name for entities
struct LocalizedName: Codable, Hashable {
    let th: String
    let en: String
}

/// Mall index response
struct MallsIndex: Codable {
    let version: Int
    let updatedAt: String
    let malls: [Mall]
}
