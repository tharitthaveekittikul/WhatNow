//
//  AdsService.swift
//  WhatNow
//
//  Domain protocol for ad management
//

import Foundation

/// Service for managing advertisements
protocol AdsService: Sendable {

    /// Check if ads are currently disabled (user has premium)
    var areAdsDisabled: Bool { get async }

    /// Load an ad for the specified placement
    /// - Parameter placement: Where the ad will be shown
    func loadAd(for placement: AdPlacement) async throws

    /// Show a loaded ad
    /// - Parameter placement: Which ad to show
    /// - Returns: True if ad was shown successfully
    func showAd(for placement: AdPlacement) async -> Bool

    /// Disable ads (after premium purchase)
    func disableAds() async

    /// Get the ad unit ID for a specific placement
    /// - Parameter placement: The ad placement
    /// - Returns: The ad unit ID string, or nil if not available
    func getAdUnitID(for placement: AdPlacement) -> String?

    /// Get the banner ad unit ID for a specific screen
    /// - Parameter placement: The banner placement location
    /// - Returns: The ad unit ID string, or nil if not available
    func getBannerAdUnitID(for placement: BannerPlacement) -> String?
}
