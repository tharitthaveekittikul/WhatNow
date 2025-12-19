//
//  GoogleMobileAdsService.swift
//  WhatNow
//
//  Production implementation of AdsService using Google Mobile Ads SDK
//

import Foundation
import GoogleMobileAds

actor GoogleMobileAdsService: NSObject, AdsService {

    // MARK: - Properties

    private var adsDisabled = false
    private let logger: Logger

    // Ad Unit IDs for general placements
    private let adUnitIDs: [AdPlacement: String] = [
        .banner: "ca-app-pub-9089812705885677/8493895585",  // Default banner (Home)
        .interstitial: "ca-app-pub-3940256099942544/4411468910",  // Test ID - Replace when you create interstitial
        .rewarded: "ca-app-pub-3940256099942544/1712485313",  // Test ID - Replace when you create rewarded
    ]

    // Banner ad unit IDs for each screen
    // NOTE: Test device identifiers are configured in initializeSDK()
    // This ensures test ads are shown during development without changing these IDs
    private let bannerAdUnitIDs: [BannerPlacement: String] = [
        .home: "ca-app-pub-9089812705885677/8493895585",
        .settings: "ca-app-pub-9089812705885677/2110829371",
        .mallSelection: "ca-app-pub-9089812705885677/1026469107",
        .activityCategory: "ca-app-pub-9089812705885677/1671845670",
        .foodCategory: "ca-app-pub-9089812705885677/1082309420",
        .spin: "ca-app-pub-9089812705885677/7671768502",
        .famousSpin: "ca-app-pub-9089812705885677/3979935505",
        .activitySpin: "ca-app-pub-9089812705885677/9306793116",
        .list: "ca-app-pub-9089812705885677/6680629778",
        .result: "ca-app-pub-9089812705885677/8045682338",
    ]

    // MARK: - Initialization

    init(logger: Logger) {
        self.logger = logger
        super.init()
    }

    // MARK: - AdsService Protocol

    nonisolated var areAdsDisabled: Bool {
        get async {
            // For now, ads are always enabled
            // TODO: Add premium purchase support in the future
            return await getAdsDisabled()
        }
    }

    private func getAdsDisabled() -> Bool {
        adsDisabled
    }

    func loadAd(for placement: AdPlacement) async throws {
        guard !adsDisabled else { return }

        guard let adUnitID = adUnitIDs[placement] else {
            throw AdError.loadFailed(
                "No ad unit ID configured for \(placement)"
            )
        }

        // Ad loading is handled by the view components (BannerAdView, etc.)
        // This method is here for protocol compliance and can be used for preloading
    }

    func showAd(for placement: AdPlacement) async -> Bool {
        guard !adsDisabled else { return false }
        // For banner ads, showing is handled by the BannerAdView component
        // For interstitial/rewarded ads, implement presentation logic here
        return true
    }

    func disableAds() async {
        adsDisabled = true
    }

    // MARK: - Helper Methods

    nonisolated func getAdUnitID(for placement: AdPlacement) -> String? {
        adUnitIDs[placement]
    }

    /// Get the banner ad unit ID for a specific screen
    /// - Parameter placement: The banner placement location
    /// - Returns: The ad unit ID string, or nil if not available
    nonisolated func getBannerAdUnitID(for placement: BannerPlacement)
        -> String?
    {
        bannerAdUnitIDs[placement]
    }
}

// MARK: - Static Initialization

extension GoogleMobileAdsService {
    /// Initialize the Google Mobile Ads SDK
    /// Call this once at app startup
    static func initializeSDK(logger: Logger) async {
        await MainActor.run {
            // Debug: Verify GADApplicationIdentifier is loaded from Info.plist
            if let appID = Bundle.main.object(
                forInfoDictionaryKey: "GADApplicationIdentifier"
            ) as? String {
                logger.info(
                    "GADApplicationIdentifier loaded: \(appID)",
                    category: .networking
                )
            } else {
                logger.error(
                    "GADApplicationIdentifier NOT FOUND in Info.plist",
                    category: .networking
                )
            }

            // Configure test devices for development
            // These identifiers are safe to keep in production - they only affect registered devices
            // Your device will see test ads, real users will see real ads
            // TODO: Add your test device ID here for development
            // Get your device ID from Xcode console when running the app
            MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
                "ac70bd30cb5f2242d3e9fb79a6b561c0"
            ]

            // Initialize AdMob SDK
            MobileAds.shared.start { status in
                logger.info("AdMob SDK initialized", category: .networking)
                logger.debug(
                    "Adapter status: \(status.adapterStatusesByClassName)",
                    category: .networking
                )

                // Log adapter details
                for (adapter, adapterStatus) in status
                    .adapterStatusesByClassName
                {
                    logger.debug(
                        "\(adapter): \(adapterStatus.state.rawValue) - \(adapterStatus.description)",
                        category: .networking
                    )
                }
            }
        }
    }
}
