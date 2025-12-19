//
//  AdModels.swift
//  WhatNow
//
//  Domain models for advertising
//

import Foundation

/// Ad placement types
enum AdPlacement: String, Sendable {
    case banner
    case interstitial
    case rewarded
}

/// Banner ad placement locations (specific screens)
enum BannerPlacement: String, Sendable {
    case home = "Home_Banner"
    case settings = "Settings_Banner"
    case mallSelection = "Mall_Selection_Banner"
    case activityCategory = "Activity_Category_Banner"
    case foodCategory = "Food_Category_Banner"
    case spin = "Spin_Banner"
    case famousSpin = "Famous_Spin_Banner"
    case activitySpin = "Activity_Spin_Banner"
    case list = "List_Banner"
    case result = "Result_Banner"
}

/// Interstitial ad placement locations
enum InterstitialPlacement: String, Sendable {
    case spinResult = "Spin_Interstitial"
}

/// Ad load state
enum AdLoadState: Equatable, Sendable {
    case notLoaded
    case loading
    case loaded
    case failed(AdError)
}

/// Errors that can occur with ads
enum AdError: Error, Equatable, Sendable {
    case loadFailed(String)
    case notAvailable
    case alreadyShowing

    var localizedDescription: String {
        switch self {
        case .loadFailed(let message):
            return "Failed to load ad: \(message)"
        case .notAvailable:
            return "Ad not available"
        case .alreadyShowing:
            return "Ad is already showing"
        }
    }
}
