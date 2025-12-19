//
//  MockAdsService.swift
//  WhatNow
//
//  Mock implementation of AdsService for testing
//

import Foundation

actor MockAdsService: AdsService {

    private var adsDisabled = false
    private var loadedAds: Set<AdPlacement> = []

    // Mock ad unit IDs for testing (Google's test IDs)
    private let adUnitIDs: [AdPlacement: String] = [
        .banner: "ca-app-pub-3940256099942544/2934735716",  // Test banner ID
        .interstitial: "ca-app-pub-3940256099942544/4411468910",  // Test interstitial ID
        .rewarded: "ca-app-pub-3940256099942544/1712485313"  // Test rewarded ID
    ]

    // Mock banner ad unit IDs for testing (all use the same test banner ID)
    private let bannerAdUnitIDs: [BannerPlacement: String] = [
        .home: "ca-app-pub-3940256099942544/2934735716",
        .settings: "ca-app-pub-3940256099942544/2934735716",
        .mallSelection: "ca-app-pub-3940256099942544/2934735716",
        .activityCategory: "ca-app-pub-3940256099942544/2934735716",
        .foodCategory: "ca-app-pub-3940256099942544/2934735716",
        .spin: "ca-app-pub-3940256099942544/2934735716",
        .famousSpin: "ca-app-pub-3940256099942544/2934735716",
        .activitySpin: "ca-app-pub-3940256099942544/2934735716",
        .list: "ca-app-pub-3940256099942544/2934735716",
        .result: "ca-app-pub-3940256099942544/2934735716"
    ]

    // MARK: - Initialization

    init() {}

    nonisolated var areAdsDisabled: Bool {
        get async {
            return await getAdsDisabled()
        }
    }

    private func getAdsDisabled() -> Bool {
        adsDisabled
    }

    func loadAd(for placement: AdPlacement) async throws {
        // Simulate ad loading
        try await Task.sleep(nanoseconds: 500_000_000)
        loadedAds.insert(placement)
    }

    func showAd(for placement: AdPlacement) async -> Bool {
        guard !adsDisabled else { return false }
        guard loadedAds.contains(placement) else { return false }

        // Simulate showing ad
        try? await Task.sleep(nanoseconds: 200_000_000)
        loadedAds.remove(placement)
        return true
    }

    func disableAds() async {
        adsDisabled = true
        loadedAds.removeAll()
    }

    nonisolated func getAdUnitID(for placement: AdPlacement) -> String? {
        adUnitIDs[placement]
    }

    nonisolated func getBannerAdUnitID(for placement: BannerPlacement) -> String? {
        bannerAdUnitIDs[placement]
    }
}
