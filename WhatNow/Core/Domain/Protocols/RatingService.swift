//
//  RatingService.swift
//  WhatNow
//
//  Service for app rating and reviews
//

import Foundation

protocol RatingService: Sendable {
    /// Opens the App Store review page for the app
    func openReviewPage(appID: String) async
}
