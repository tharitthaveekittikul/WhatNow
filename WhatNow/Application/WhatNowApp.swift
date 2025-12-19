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

        // Initialize AdMob SDK
        let logger = DependencyContainer.shared.logger
        Task {
            await GoogleMobileAdsService.initializeSDK(logger: logger)
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appEnvironment)
                .preferredColorScheme(appEnvironment.colorScheme)
                .environment(\.locale, appEnvironment.locale)
                .task {
                    // Mark app as launched (for first-time setup)
                    await appEnvironment.spinSessionTracker.markAppLaunched()

                    // Preload first interstitial ad
                    await appEnvironment.interstitialAdManager.preloadInterstitial()
                }
        }
    }
}
