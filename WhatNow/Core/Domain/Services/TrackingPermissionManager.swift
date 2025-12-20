//
//  TrackingPermissionManager.swift
//  WhatNow
//
//  Manages App Tracking Transparency (ATT) permissions for AdMob
//

import Foundation
import AppTrackingTransparency
internal import Combine

/// Manages App Tracking Transparency (ATT) permission requests
@MainActor
final class TrackingPermissionManager: ObservableObject {

    // MARK: - Properties

    @Published private(set) var trackingStatus: ATTrackingManager.AuthorizationStatus = .notDetermined
    @Published private(set) var hasRequestedPermission = false

    private let logger: Logger

    // MARK: - Initialization

    init(logger: Logger) {
        self.logger = logger
        self.trackingStatus = ATTrackingManager.trackingAuthorizationStatus
    }

    // MARK: - Public Methods

    /// Request tracking permission from the user
    /// Shows the ATT prompt if status is not determined
    /// - Returns: The authorization status after the request
    @discardableResult
    func requestPermission() async -> ATTrackingManager.AuthorizationStatus {
        // Check current status
        let currentStatus = ATTrackingManager.trackingAuthorizationStatus

        // If already determined, no need to request again
        if currentStatus != .notDetermined {
            logger.info("Tracking permission already determined: \(statusString(currentStatus))", category: .networking)
            trackingStatus = currentStatus
            hasRequestedPermission = true
            return currentStatus
        }

        // Wait a bit for the app UI to appear
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Request tracking authorization
        logger.info("Requesting tracking permission...", category: .networking)
        let status = await ATTrackingManager.requestTrackingAuthorization()

        // Update published properties
        trackingStatus = status
        hasRequestedPermission = true

        logger.info("Tracking permission result: \(statusString(status))", category: .networking)

        return status
    }

    /// Check if tracking is authorized
    var isAuthorized: Bool {
        trackingStatus == .authorized
    }

    // MARK: - Private Helpers

    private func statusString(_ status: ATTrackingManager.AuthorizationStatus) -> String {
        switch status {
        case .authorized:
            return "Authorized"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Determined"
        @unknown default:
            return "Unknown"
        }
    }
}
