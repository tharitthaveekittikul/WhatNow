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
    private let purchaseService: PurchaseService

    // Ad Unit IDs for general placements
    private let adUnitIDs: [AdPlacement: String] = [
        .banner: "ca-app-pub-9089812705885677/8493895585",  // Default banner (Home)
        .interstitial: "ca-app-pub-9089812705885677/5475359315",  // Spin Interstitial
        .rewarded: "ca-app-pub-3940256099942544/1712485313",  // Test ID - Replace when you create rewarded
    ]

    // Interstitial ad unit IDs
    private let interstitialAdUnitIDs: [InterstitialPlacement: String] = [
        .spinResult: "ca-app-pub-9089812705885677/5475359315",
        .customSpinResult: "ca-app-pub-9089812705885677/3127687138"
    ]

    // State
    private var loadedInterstitial: InterstitialAd?
    private var isLoadingInterstitial = false
    private var interstitialDismissalContinuation: CheckedContinuation<Void, Never>?

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
        .customSpinList: "ca-app-pub-9089812705885677/1394312370",
        .customSpinEditor: "ca-app-pub-9089812705885677/7870530314",
        .customSpin: "ca-app-pub-9089812705885677/4496609127",
        .customSpinResult: "ca-app-pub-9089812705885677/7385005658",
        .list: "ca-app-pub-9089812705885677/6680629778",
        .result: "ca-app-pub-9089812705885677/8045682338",
    ]

    // MARK: - Initialization

    init(logger: Logger, purchaseService: PurchaseService) {
        self.logger = logger
        self.purchaseService = purchaseService
        super.init()
    }

    // MARK: - AdsService Protocol

    nonisolated var areAdsDisabled: Bool {
        get async {
            // Check if user has purchased Pro
            let hasPro = await purchaseService.hasPurchased(productId: StoreKitPurchaseService.whatNowProProductID)
            if hasPro {
                return true
            }

            // Check if ads are manually disabled
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

        // Handle interstitial loading
        if placement == .interstitial {
            guard !isLoadingInterstitial else {
                logger.debug("Interstitial already loading", category: .networking)
                return
            }

            isLoadingInterstitial = true

            await MainActor.run {
                let request = Request()
                InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
                    Task {
                        guard let self = self else { return }

                        await self.setLoadingState(false)

                        if let error = error {
                            self.logger.error("Failed to load interstitial ad", category: .networking, error: error)
                            return
                        }

                        if let ad = ad {
                            await self.setLoadedInterstitial(ad)
                            self.logger.info("Interstitial ad loaded successfully", category: .networking)
                        }
                    }
                }
            }
            return
        }

        // Banner ads are handled by BannerAdView component
    }

    func showAd(for placement: AdPlacement) async -> Bool {
        guard !adsDisabled else { return false }

        // Handle interstitial showing
        if placement == .interstitial {
            guard let interstitial = loadedInterstitial else {
                logger.warning("No interstitial ad loaded", category: .networking)
                return false
            }

            // Set delegate to receive dismissal callback
            await MainActor.run {
                interstitial.fullScreenContentDelegate = self
            }

            // Present ad and wait for dismissal
            let success = await MainActor.run {
                guard let rootVC = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.windows.first?.rootViewController else {
                    logger.error("No root view controller found", category: .networking)
                    return false
                }

                interstitial.present(from: rootVC)
                logger.info("Interstitial ad presented", category: .networking)
                return true
            }

            if success {
                // Wait for ad to be dismissed
                await withCheckedContinuation { continuation in
                    interstitialDismissalContinuation = continuation
                }

                logger.info("Interstitial ad dismissed by user", category: .networking)

                loadedInterstitial = nil  // Clear after showing

                // Preload next ad
                Task {
                    try? await self.loadAd(for: .interstitial)
                }
            }

            return success
        }

        // Banner ads are handled by BannerAdView component
        return true
    }

    // Helper methods for state management
    private func setLoadingState(_ isLoading: Bool) {
        isLoadingInterstitial = isLoading
    }

    private func setLoadedInterstitial(_ ad: InterstitialAd?) {
        loadedInterstitial = ad
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

// MARK: - GADFullScreenContentDelegate

extension GoogleMobileAdsService: FullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        // Resume the continuation when ad is dismissed
        Task {
            await resumeDismissalContinuation()
        }
    }

    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        // If ad fails to present, also resume continuation
        Task {
            await self.logger.error("Interstitial ad failed to present", category: .networking, error: error)
            await resumeDismissalContinuation()
        }
    }

    private func resumeDismissalContinuation() {
        if let continuation = interstitialDismissalContinuation {
            continuation.resume()
            interstitialDismissalContinuation = nil
        }
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
