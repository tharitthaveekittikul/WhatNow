//
//  SpinViewModel.swift
//  WhatNow
//
//  ViewModel for Spin View - Handles all business logic
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class SpinViewModel: ObservableObject {
    // MARK: - Published State

    // Data state
    @Published private(set) var allItems: [Store] = []
    @Published private(set) var shuffledItems: [Store] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // Filter state
    @Published var filter = StoreFilter()

    // Spin state
    @Published private(set) var isSpinning = false
    @Published var reelIndex: Int = 0

    // Navigation state
    @Published var selectedItem: Store?
    @Published var showItemDetail = false
    @Published var showItemList = false
    @Published var showFilterSheet = false

    // Animation state
    @Published var gradientRotation: Double = 0

    // MARK: - Configuration

    let configuration: SpinConfiguration
    private let fetchMallStoresUseCase: FetchMallStoresUseCase
    private let logger = DependencyContainer.shared.logger
    private var hasLoaded = false

    // MARK: - Computed Properties

    /// Items after applying filters
    var filteredItems: [Store] {
        filter.apply(to: allItems)
    }

    /// Whether there are any active filters
    var hasActiveFilters: Bool {
        filter.isActive
    }

    /// Number of active filters
    var activeFilterCount: Int {
        filter.activeFilterCount
    }

    /// Whether the spin button should be enabled
    var canSpin: Bool {
        !isSpinning && !shuffledItems.isEmpty
    }

    /// Whether filter controls should be disabled
    var filterControlsDisabled: Bool {
        isSpinning
    }

    /// Display title for the view
    func displayTitle(for language: Language) -> String {
        configuration.title.localized(for: language)
    }

    /// Display subtitle showing item count
    func displaySubtitle(for language: Language) -> String {
        if hasActiveFilters {
            return "\(shuffledItems.count) / \(allItems.count) stores".localized(for: language)
        } else {
            return "\(allItems.count) stores".localized(for: language)
        }
    }

    // MARK: - Initialization

    init(
        configuration: SpinConfiguration,
        fetchMallStoresUseCase: FetchMallStoresUseCase? = nil
    ) {
        self.configuration = configuration
        self.fetchMallStoresUseCase = fetchMallStoresUseCase ?? DependencyContainer.shared.fetchMallStoresUseCase
    }

    // MARK: - Data Loading

    func loadItems() async {
        // Prevent duplicate loads
        guard !hasLoaded && !isLoading else { return }

        hasLoaded = true
        isLoading = true
        errorMessage = nil

        do {
            switch configuration.context {
            case .mall(let mall):
                try await loadMallStores(mall: mall)
            case .famousRestaurant:
                // TODO: Implement when famous restaurant API is ready
                errorMessage = "Famous restaurant feature coming soon"
            case .activity:
                // TODO: Implement when activity API is ready
                errorMessage = "Activity feature coming soon"
            }

            // Initial shuffle after loading
            if !allItems.isEmpty {
                applyFiltersAndShuffle()
            } else {
                errorMessage = "No items available"
            }
        } catch {
            errorMessage = error.localizedDescription
            hasLoaded = false // Allow retry
        }

        isLoading = false
    }

    private func loadMallStores(mall: Mall) async throws {
        let mallPack = try await fetchMallStoresUseCase.execute(mallId: mall.mallId)

        // Get all stores from the "all" category
        if let allCategory = mallPack.categories.first(where: { $0.id == "all" }) {
            allItems = allCategory.items
        } else {
            throw SpinError.noCategoryFound
        }
    }

    // MARK: - Filter Management

    func applyFiltersAndShuffle() {
        let filtered = filteredItems

        withAnimation(.easeInOut(duration: 0.3)) {
            if !filtered.isEmpty {
                shuffledItems = filtered.shuffled()
                reelIndex = Int.random(in: 0..<shuffledItems.count)
            } else {
                shuffledItems = []
                reelIndex = 0
            }
        }
    }

    func removeCategory(_ category: String) {
        guard !isSpinning else { return }
        filter.selectedCategories.remove(category)
    }

    func removePriceRange(_ priceRange: PriceRange) {
        guard !isSpinning else { return }
        filter.selectedPriceRanges.remove(priceRange)
    }

    func clearAllFilters() {
        guard !isSpinning else { return }
        filter.clear()
    }

    // MARK: - Spin Logic

    func spin() {
        guard canSpin else { return }

        isSpinning = true

        // Start gradient rotation animation
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            gradientRotation = 360
        }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()

        let totalItems = shuffledItems.count

        // Calculate target with large rotation for suspense
        let fullSpins = Int.random(in: 10...16)
        let randomExtra = Int.random(in: 0..<totalItems)
        let targetReelIndex = reelIndex + (totalItems * fullSpins) + randomExtra

        // Phase 1: Fast acceleration (0.3s)
        let phase1Duration = 0.3
        let phase1Target = reelIndex + 8

        generator.impactOccurred()

        if #available(iOS 17.0, *) {
            // iOS 17+: Use animation completion callbacks
            withAnimation(.easeIn(duration: phase1Duration)) {
                reelIndex = phase1Target
            } completion: {
                self.startDecelerationPhase(
                    targetReelIndex: targetReelIndex,
                    generator: generator
                )
            }
        } else {
            // iOS 16: Fallback to DispatchQueue
            withAnimation(.easeIn(duration: phase1Duration)) {
                reelIndex = phase1Target
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + phase1Duration) {
                self.startDecelerationPhase(
                    targetReelIndex: targetReelIndex,
                    generator: generator
                )
            }
        }
    }

    private func startDecelerationPhase(
        targetReelIndex: Int,
        generator: UIImpactFeedbackGenerator
    ) {
        // Phase 2: Long deceleration (4.5s-5.5s)
        let phase2Duration = Double.random(in: 4.5...5.5)
        generator.impactOccurred()

        if #available(iOS 17.0, *) {
            withAnimation(.timingCurve(0.22, 0.61, 0.36, 1.0, duration: phase2Duration)) {
                reelIndex = targetReelIndex
            } completion: {
                self.onSpinComplete()
            }
        } else {
            withAnimation(.timingCurve(0.22, 0.61, 0.36, 1.0, duration: phase2Duration)) {
                reelIndex = targetReelIndex
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + phase2Duration) {
                self.onSpinComplete()
            }
        }
    }

    private func onSpinComplete() {
        isSpinning = false

        // Reset gradient rotation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            gradientRotation = 0
        }

        // Strong haptic at the end
        let endFeedback = UIImpactFeedbackGenerator(style: .heavy)
        endFeedback.impactOccurred()

        // Calculate final selected item
        let totalItems = shuffledItems.count
        guard totalItems > 0 else {
            logger.error("❌ No items available after spin!")
            return
        }

        let finalIndex = ((reelIndex % totalItems) + totalItems) % totalItems
        let item: Store = shuffledItems[finalIndex]
        let itemName: String = item.displayName

        logger.info("🎰 Spin result: \(itemName) (Index: \(finalIndex)/\(totalItems), Type: \(configuration.spinType.rawValue))")

        // Set selected item and show detail after delay
        selectedItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showItemDetail = true
        }
    }

    // MARK: - Navigation Actions

    func openFilterSheet() {
        guard !isSpinning else { return }
        showFilterSheet = true
    }

    func openItemList() {
        guard !isSpinning else { return }
        showItemList = true
    }

    /// Reshuffle items (called when view appears)
    func reshuffleItems() {
        guard !allItems.isEmpty else { return }
        applyFiltersAndShuffle()
    }
}

// MARK: - Spin Error

enum SpinError: LocalizedError {
    case noCategoryFound
    case noItemsAvailable

    var errorDescription: String? {
        switch self {
        case .noCategoryFound:
            return "No stores found in 'all' category"
        case .noItemsAvailable:
            return "No items available"
        }
    }
}
