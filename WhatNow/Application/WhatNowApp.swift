//
//  WhatNowApp.swift
//  WhatNow
//
//  App Entry Point
//

import SwiftUI
import SDWebImage
import SDWebImageSVGCoder

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
                    await appEnvironment.trackingPermissionManager.requestPermission()

                    // Initialize AdMob SDK
                    await GoogleMobileAdsService.initializeSDK(logger: appEnvironment.logger)

                    // Mark app as launched (for first-time setup)
                    await appEnvironment.spinSessionTracker.markAppLaunched()

                    // Preload first interstitial ad
                    await appEnvironment.interstitialAdManager.preloadInterstitial()
                }
        }
    }
}
