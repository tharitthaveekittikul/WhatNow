//
//  WhatNowApp.swift
//  WhatNow
//
//  App Entry Point
//

import SwiftUI

@main
struct WhatNowApp: App {
    @StateObject private var appEnvironment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appEnvironment)
        }
    }
}
