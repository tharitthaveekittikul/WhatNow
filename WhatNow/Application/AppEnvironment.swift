//
//  AppEnvironment.swift
//  WhatNow
//
//  App Environment - Global app state
//

import Foundation
internal import Combine

@MainActor
final class AppEnvironment: ObservableObject {
    // Dependency container
    let container: DependencyContainer

    init(container: DependencyContainer = .shared) {
        self.container = container
    }
}
