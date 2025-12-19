//
//  AppRoute.swift
//  WhatNow
//
//  App Routing - Navigation destinations
//

import Foundation

/// Represents navigation destinations in the app
enum AppRoute: Hashable {
    case foodCategory
    case activityCategory
    case mallSelection
    case famousStores
    case activitySpin(category: ActivityCategory)
    case spin(mall: Mall)
    case settings
}
