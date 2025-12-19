//
//  BannerAdModifier.swift
//  WhatNow
//
//  View modifier to easily add banner ads to any screen
//

import SwiftUI

/// View modifier that adds a banner ad at the bottom of a view
struct BannerAdModifier: ViewModifier {

    let placement: BannerPlacement
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @State private var shouldShowAd = false

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content

            // Banner Ad at bottom (only show if not disabled)
            if shouldShowAd,
               let adUnitID = appEnvironment.adsService.getBannerAdUnitID(for: placement) {
                Divider()
                BannerAdView.adaptive(adUnitID: adUnitID, logger: appEnvironment.logger)
                    .background(Color.App.surfaceSoft)
            }
        }
        .task {
            // Check if ads are disabled
            shouldShowAd = !(await appEnvironment.adsService.areAdsDisabled)
        }
    }
}

extension View {
    /// Add a banner ad at the bottom of this view
    /// - Parameter placement: The banner placement location (which screen)
    /// - Returns: A view with a banner ad at the bottom
    func withBannerAd(placement: BannerPlacement) -> some View {
        modifier(BannerAdModifier(placement: placement))
    }
}
