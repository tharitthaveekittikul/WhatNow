//
//  DefaultRatingService.swift
//  WhatNow
//
//  Default implementation of RatingService
//

import Foundation
import UIKit

actor DefaultRatingService: RatingService {
    static let appStoreID = "6756788566"

    private let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

    nonisolated func openReviewPage(appID: String) async {
        guard let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") else {
            await logger.error("Invalid App Store URL for app ID: \(appID)")
            return
        }

        await MainActor.run {
            UIApplication.shared.open(url)
        }

        await logger.info("Opened App Store review page")
    }
}
