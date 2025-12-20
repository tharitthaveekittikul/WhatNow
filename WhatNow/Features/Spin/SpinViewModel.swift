//
//  SpinViewModel.swift
//  WhatNow
//
//  ViewModel for Spin View - Handles all business logic
//

internal import Combine
import Foundation
import SwiftUI

@MainActor
final class SpinViewModel: ObservableObject {
    // MARK: - Published State

    // Data state
    @Published private(set) var allItems: [Store] = []
    @Published private(set) var shuffledItems: [Store] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // PERFORMANCE: Dictionary-based O(1) lookups instead of O(n) array search
    // Store metadata (e.g., suggested malls for famous stores)
    private var storeSuggestedMalls: [String: [String]] = [:]  // storeId -> [mallId]
    private var mallsById: [String: Mall] = [:]  // mallId -> Mall
    private var storesById: [String: Store] = [:]  // storeId -> Store (O(1) lookup cache)

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
    private let packsService: PacksService
    private let interstitialAdManager: InterstitialAdManager
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
            return "\(shuffledItems.count) / \(allItems.count) stores"
                .localized(for: language)
        } else {
            return "\(allItems.count) stores".localized(for: language)
        }
    }

    /// Get formatted suggested mall names for a store
    func getSuggestedMallNames(for storeId: String, language: Language) -> String? {
        guard let mallIds = storeSuggestedMalls[storeId], !mallIds.isEmpty else {
            return nil
        }

        let mallNames = mallIds.compactMap { mallId -> String? in
            mallsById[mallId]?.name.localized(for: language)
        }

        guard !mallNames.isEmpty else { return nil }

        return mallNames.joined(separator: ", ")
    }

    // MARK: - Initialization

    init(
        configuration: SpinConfiguration,
        fetchMallStoresUseCase: FetchMallStoresUseCase? = nil,
        packsService: PacksService? = nil,
        interstitialAdManager: InterstitialAdManager? = nil
    ) {
        self.configuration = configuration
        self.fetchMallStoresUseCase =
            fetchMallStoresUseCase
            ?? DependencyContainer.shared.fetchMallStoresUseCase
        self.packsService =
            packsService ?? DependencyContainer.shared.packsService
        self.interstitialAdManager =
            interstitialAdManager
            ?? DependencyContainer.shared.interstitialAdManager

        // Preload interstitial ad
        Task {
            await self.interstitialAdManager.preloadInterstitial()
        }
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
                await loadFamousRestaurants()
            case .activity(let category):
                await loadActivities(category: category)
            case .customList(let list):
                loadCustomList(list)
            }

            // Initial shuffle after loading
            if !allItems.isEmpty {
                applyFiltersAndShuffle()
            } else {
                errorMessage = "No items available"
            }
        } catch {
            errorMessage = error.localizedDescription
            hasLoaded = false  // Allow retry
        }

        isLoading = false
    }

    private func loadMallStores(mall: Mall) async throws {
        let mallPack = try await fetchMallStoresUseCase.execute(
            mallId: mall.mallId
        )

        // Get all stores from the "all" category
        if let allCategory = mallPack.categories.first(where: { $0.id == "all" }
        ) {
            allItems = allCategory.items

            // PERFORMANCE: Build O(1) lookup dictionary for stores
            storesById = Dictionary(
                uniqueKeysWithValues: allItems.map { ($0.id, $0) }
            )
        } else {
            throw SpinError.noCategoryFound
        }
    }

    private func loadFamousRestaurants() async {
        do {
            logger.info(
                "🌐 Fetching famous restaurants from API",
                category: .networking
            )
            let pack = try await packsService.fetchFamousStores()

            // Fetch malls index to map mall IDs to names
            do {
                let malls = try await packsService.fetchMalls()
                mallsById = Dictionary(
                    uniqueKeysWithValues: malls.map { ($0.mallId, $0) }
                )
                logger.info(
                    "✅ Loaded \(mallsById.count) malls for mapping",
                    category: .networking
                )
            } catch {
                logger.error(
                    "⚠️ Failed to load malls for mapping: \(error)",
                    category: .networking
                )
            }

            // Convert FamousStoreItem to Store and store suggested malls
            allItems = pack.items.map { item in
                // Store suggested malls mapping
                if let suggestedMalls = item.suggestedMalls {
                    storeSuggestedMalls[item.id] = suggestedMalls
                }

                return Store(
                    id: item.id,
                    name: LocalizedName(th: item.name, en: item.name),
                    displayName: item.name,
                    tags: item.tags,
                    priceRange: item.priceRange,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil,
                    logoUrl: nil
                )
            }

            // PERFORMANCE: Build O(1) lookup dictionary for stores
            storesById = Dictionary(
                uniqueKeysWithValues: allItems.map { ($0.id, $0) }
            )

            logger.info(
                "✅ Loaded \(allItems.count) famous restaurants",
                category: .networking
            )
        } catch {
            logger.error(
                "❌ Failed to load famous restaurants: \(error)",
                category: .networking
            )
            errorMessage =
                "Failed to load famous restaurants: \(error.localizedDescription)"
        }
    }

    private func loadActivities(category: String) async {
        do {
            // category parameter is now the API category ID directly (e.g., "indoor-activities")
            logger.info(
                "🌐 Fetching activities for category: \(category)",
                category: .networking
            )
            let pack = try await packsService.fetchActivities(
                categoryId: category
            )

            // Convert ActivityItem to Store
            allItems = pack.items.map { item in
                Store(
                    id: item.id,
                    name: LocalizedName(th: item.nameTH, en: item.nameEN),
                    displayName: item.nameEN,
                    tags: item.tags,
                    priceRange: item.priceRange,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil,
                    logoUrl: nil
                )
            }

            // PERFORMANCE: Build O(1) lookup dictionary for stores
            storesById = Dictionary(
                uniqueKeysWithValues: allItems.map { ($0.id, $0) }
            )

            logger.info(
                "✅ Loaded \(allItems.count) activities for \(category)",
                category: .networking
            )
        } catch {
            logger.error(
                "❌ Failed to load activities: \(error)",
                category: .networking
            )
            errorMessage =
                "Failed to load activities: \(error.localizedDescription)"
        }
    }

    private func loadCustomList(_ list: CustomSpinList) {
        logger.info(
            "✨ Loading custom list: \(list.name) with \(list.items.count) items",
            category: .business
        )

        // Convert CustomSpinItem to Store
        allItems = list.items.map { item in
            Store(
                id: item.id.uuidString,
                name: LocalizedName(th: item.text, en: item.text),
                displayName: item.text,
                tags: [],
                priceRange: .mid,  // Default, not used for custom items
                location: nil,
                detailUrl: nil,
                mapUrl: nil,
                logoUrl: nil
            )
        }

        // PERFORMANCE: Build O(1) lookup dictionary for stores
        storesById = Dictionary(
            uniqueKeysWithValues: allItems.map { ($0.id, $0) }
        )

        logger.info(
            "✅ Loaded \(allItems.count) custom items",
            category: .business
        )
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

        // Record spin and check if we should show ad BEFORE spinning
        Task {
            await interstitialAdManager.recordSpin()

            let shouldShowAd = await interstitialAdManager.shouldShowInterstitialAfterSpin()

            if shouldShowAd {
                // Show interstitial ad first, then start spin
                logger.info("🎬 Showing interstitial ad before spin")
                let adShown = await interstitialAdManager.showInterstitial()

                if adShown {
                    // Ad was shown and dismissed, now start spin
                    logger.info("✅ Ad dismissed, starting spin animation")
                }

                // Start spin animation after ad dismissal
                await MainActor.run {
                    self.startSpinAnimation()
                }
            } else {
                // No ad, start spin immediately
                await MainActor.run {
                    self.startSpinAnimation()
                }
            }
        }
    }

    private func startSpinAnimation() {
        isSpinning = true

        // Start gradient rotation animation
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            gradientRotation = 360
        }

        // Wait for ReelPicker animation to complete (3 seconds)
        // ReelPicker will update reelIndex when it finishes
        let totalDuration: Double = 3.0

        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            self.onSpinComplete()
        }
    }

    private func onSpinComplete() {
        // PERFORMANCE: Calculate and cache result immediately (off main actor if possible)
        // This uses O(1) array indexing, not O(n) search
        let totalItems = shuffledItems.count
        guard totalItems > 0 else {
            logger.error("❌ No items available after spin!")
            isSpinning = false
            return
        }

        // O(1) array access by index
        let finalIndex = ((reelIndex % totalItems) + totalItems) % totalItems
        let item: Store = shuffledItems[finalIndex]
        let itemName: String = item.displayName

        logger.info(
            "🎰 Spin result: \(itemName) (Index: \(finalIndex)/\(totalItems), Type: \(configuration.spinType.rawValue))"
        )

        // PERFORMANCE: Set selected item BEFORE stopping spin
        // This ensures the sheet content is ready to render when presented
        selectedItem = item

        // Now stop spinning (triggers UI updates)
        isSpinning = false

        // Reset gradient rotation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            gradientRotation = 0
        }

        // PERFORMANCE: Small delay (0.15s) to let animation context clear
        // This prevents main thread congestion during sheet presentation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
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

    // MARK: - Debug & Verification

    #if DEBUG
    /// Verify that the landing logic produces the expected result
    /// Used for testing that virtualized rendering produces identical results to original
    func verifyLandingLogic(targetIndex: Int, reelIndex: Int) -> Bool {
        guard !shuffledItems.isEmpty else { return false }

        let totalItems = shuffledItems.count
        let finalIndex = ((reelIndex % totalItems) + totalItems) % totalItems
        let landedItem = shuffledItems[finalIndex]
        let expectedItem = shuffledItems[targetIndex % totalItems]

        let matches = landedItem.id == expectedItem.id

        if !matches {
            logger.error(
                "⚠️ Landing verification FAILED: Expected \(expectedItem.displayName), got \(landedItem.displayName)"
            )
        }

        return matches
    }
    #endif
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
