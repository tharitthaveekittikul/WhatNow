//
//  Activity.swift
//  WhatNow
//
//  Domain Model - Activities
//

import Foundation

/// Activity category
struct ActivityCategory: Identifiable, Hashable, Sendable, Codable {
    let id: String
    let nameTH: String
    let nameEN: String
    let assetKey: String?

    var displayName: String {
        // TODO: Use locale to determine TH vs EN
        nameTH
    }
}

/// Activity item
struct ActivityItem: Identifiable, Hashable, Sendable, Codable {
    let id: String
    let nameTH: String
    let nameEN: String
    let tags: [String]
    let priceRange: PriceRange

    var displayName: String {
        // TODO: Use locale to determine TH vs EN
        nameTH
    }
}

/// Activities index response
struct ActivitiesIndex: Sendable, Codable {
    let version: Int
    let updatedAt: String
    let categories: [ActivityCategory]
}

/// Activity pack response (for a specific category)
struct ActivityPack: Sendable, Codable {
    let version: Int
    let updatedAt: String
    let category: ActivityCategory
    let items: [ActivityItem]
}
