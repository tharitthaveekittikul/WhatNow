//
//  ActivityCategoryViewModel.swift
//  WhatNow
//
//  ViewModel for Activity Category View
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class ActivityCategoryViewModel: ObservableObject {
    // MARK: - Published State

    @Published private(set) var categories: [ActivityCategory] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let packsService: PacksService
    private let logger = DependencyContainer.shared.logger
    private var hasLoaded = false

    // MARK: - Initialization

    init(packsService: PacksService? = nil) {
        self.packsService = packsService ?? DependencyContainer.shared.packsService
    }

    // MARK: - Data Loading

    func loadCategories() async {
        // Prevent duplicate loads
        guard !hasLoaded && !isLoading else { return }

        hasLoaded = true
        isLoading = true
        errorMessage = nil

        do {
            logger.info("🌐 Fetching activity categories from API", category: .networking)
            let index = try await packsService.fetchActivityCategories()
            categories = index.categories
            logger.info("✅ Loaded \(categories.count) activity categories", category: .networking)
        } catch {
            logger.error("❌ Failed to load activity categories: \(error)", category: .networking)
            errorMessage = "Failed to load activity categories: \(error.localizedDescription)"
            hasLoaded = false // Allow retry
        }

        isLoading = false
    }

    // MARK: - Helpers

    func emoji(for category: ActivityCategory) -> String {
        // Map category IDs to emojis
        switch category.id {
        case "indoor-activities":
            return "🏢"
        case "outdoor-activities":
            return "🏞️"
        case "entertainment":
            return "🎬"
        default:
            return "🎯"
        }
    }

    func accentColor(for category: ActivityCategory) -> Color {
        // Map category IDs to colors
        switch category.id {
        case "indoor-activities":
            return Color.App.accentLavender
        case "outdoor-activities":
            return Color.App.accentSky
        case "entertainment":
            return Color.App.accentWarm
        default:
            return Color.App.accentSky
        }
    }
}
