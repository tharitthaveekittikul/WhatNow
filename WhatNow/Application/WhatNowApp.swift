//
//  WhatNowApp.swift
//  WhatNow
//
//  App Entry Point
//

import SwiftUI
import SDWebImage
import SDWebImageSVGCoder
import AppTrackingTransparency

@main
struct WhatNowApp: App {
    @StateObject private var appEnvironment = AppEnvironment()

    init() {
        // Register SVG coder for SDWebImage
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appEnvironment)
                .preferredColorScheme(appEnvironment.colorScheme)
                .environment(\.locale, appEnvironment.locale)
                .task {
                    // Request ATT permission
                    await requestTrackingPermission()

                    // Initialize AdMob SDK
                    let logger = DependencyContainer.shared.logger
                    await GoogleMobileAdsService.initializeSDK(logger: logger)

                    // Mark app as launched (for first-time setup)
                    await appEnvironment.spinSessionTracker.markAppLaunched()

                    // Preload first interstitial ad
                    await appEnvironment.interstitialAdManager.preloadInterstitial()
                }
        }
    }

    /// Request App Tracking Transparency permission
    /// This is required for AdMob personalized ads
    @MainActor
    private func requestTrackingPermission() async {
        // Wait for the app UI to appear
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay

        // Request tracking authorization
        let status = await ATTrackingManager.requestTrackingAuthorization()
        let logger = DependencyContainer.shared.logger

        switch status {
        case .authorized:
            logger.info("Tracking permission: Authorized", category: .networking)
        case .denied:
            logger.info("Tracking permission: Denied", category: .networking)
        case .restricted:
            logger.info("Tracking permission: Restricted", category: .networking)
        case .notDetermined:
            logger.info("Tracking permission: Not Determined", category: .networking)
        @unknown default:
            logger.info("Tracking permission: Unknown", category: .networking)
        }
    }
}
