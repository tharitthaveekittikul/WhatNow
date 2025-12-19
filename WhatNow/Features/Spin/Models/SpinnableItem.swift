//
//  SpinnableItem.swift
//  WhatNow
//
//  Generic protocol for items that can be displayed in the spinning reel
//

import Foundation

/// Protocol for any item that can be displayed in a spinning reel picker
protocol SpinnableItem: Identifiable, Hashable {
    /// Primary display name in current language
    var displayName: String { get }

    /// Secondary info (e.g., price range, activity duration)
    var secondaryInfo: String { get }

    /// Tags/categories for filtering
    var filterTags: [String] { get }
}

// MARK: - Store Conformance

extension Store: SpinnableItem {
    // displayName already exists in Store, satisfies protocol requirement

    var secondaryInfo: String {
        priceRange.displayText
    }

    var filterTags: [String] {
        tags
    }
}
