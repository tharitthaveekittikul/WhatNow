//
//  SpinConfiguration.swift
//  WhatNow
//
//  Configuration model for different spin types (Mall, Famous Restaurant, Activity, etc.)
//

import Foundation

/// Configuration for different types of spin experiences
struct SpinConfiguration {
    /// Context object (Mall, Category, etc.)
    let context: SpinContext

    /// Title to display (e.g., mall name)
    let title: LocalizedName

    /// Subtitle to display (e.g., store count)
    let subtitle: String?

    /// Whether to show the "See All" button
    let showSeeAllButton: Bool

    /// Whether filtering is enabled
    let filteringEnabled: Bool

    /// Type of spin for analytics/logging
    let spinType: SpinType

    init(
        context: SpinContext,
        title: LocalizedName,
        subtitle: String? = nil,
        showSeeAllButton: Bool = true,
        filteringEnabled: Bool = true,
        spinType: SpinType = .mallStores
    ) {
        self.context = context
        self.title = title
        self.subtitle = subtitle
        self.showSeeAllButton = showSeeAllButton
        self.filteringEnabled = filteringEnabled
        self.spinType = spinType
    }
}

// MARK: - Spin Context

/// Context for different spin types
enum SpinContext {
    case mall(Mall)
    case famousRestaurant
    case michelinGuide
    case activity(category: String)
    case customList(CustomSpinList)
}

// MARK: - Spin Type

/// Type of spin for analytics and logging
enum SpinType: String {
    case mallStores = "mall_stores"
    case famousRestaurant = "famous_restaurant"
    case michelinGuide = "michelin_guide"
    case activity = "activity"
    case customList = "custom_list"
}
