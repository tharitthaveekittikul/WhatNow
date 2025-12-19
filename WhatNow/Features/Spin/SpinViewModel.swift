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
                await loadFamousRestaurants()
            case .activity(let category):
                await loadActivities(category: category)
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

    private func loadFamousRestaurants() async {
        // Simulate API delay
        try? await Task.sleep(for: .seconds(0.5))

        // Mock famous restaurant data
        allItems = [
            Store(
                id: "somtam-nua",
                name: LocalizedName(th: "ส้มตำนัว", en: "Somtam Nua"),
                displayName: "Somtam Nua",
                tags: ["thai", "issan", "popular"],
                priceRange: .budget,
                location: StoreLocation(floor: "G", zone: "Food Court", unit: "FC-12"),
                detailUrl: nil,
                mapUrl: nil
            ),
            Store(
                id: "thipsamai",
                name: LocalizedName(th: "ทิพย์สมัย", en: "Thipsamai Pad Thai"),
                displayName: "Thipsamai Pad Thai",
                tags: ["thai", "pad_thai", "legendary"],
                priceRange: .budget,
                location: nil,
                detailUrl: nil,
                mapUrl: nil
            ),
            Store(
                id: "jay-fai",
                name: LocalizedName(th: "เจ๊ไฝ", en: "Jay Fai"),
                displayName: "Jay Fai",
                tags: ["thai", "seafood", "michelin"],
                priceRange: .premium,
                location: nil,
                detailUrl: nil,
                mapUrl: nil
            ),
            Store(
                id: "kuang-heng",
                name: LocalizedName(th: "ก๋วยเตี๋ยวเรือกวงเฮง", en: "Kuang Heng Boat Noodles"),
                displayName: "Kuang Heng",
                tags: ["thai", "noodles", "street_food"],
                priceRange: .budget,
                location: nil,
                detailUrl: nil,
                mapUrl: nil
            ),
            Store(
                id: "mango-tango",
                name: LocalizedName(th: "มะม่วงแทงโก้", en: "Mango Tango"),
                displayName: "Mango Tango",
                tags: ["dessert", "mango", "famous"],
                priceRange: .mid,
                location: nil,
                detailUrl: nil,
                mapUrl: nil
            ),
            Store(
                id: "srettha",
                name: LocalizedName(th: "เศรษฐา", en: "Srettha"),
                displayName: "Srettha",
                tags: ["thai", "chicken_rice", "popular"],
                priceRange: .budget,
                location: nil,
                detailUrl: nil,
                mapUrl: nil
            ),
            Store(
                id: "yentafo-convent",
                name: LocalizedName(th: "เย็นตาโฟคอนแวนต์", en: "Yen Ta Fo Convent"),
                displayName: "Yen Ta Fo Convent",
                tags: ["thai", "noodles", "pink_soup"],
                priceRange: .budget,
                location: nil,
                detailUrl: nil,
                mapUrl: nil
            ),
            Store(
                id: "krua-apsorn",
                name: LocalizedName(th: "ครัวอัปษร", en: "Krua Apsorn"),
                displayName: "Krua Apsorn",
                tags: ["thai", "royal_cuisine", "famous"],
                priceRange: .mid,
                location: nil,
                detailUrl: nil,
                mapUrl: nil
            )
        ]
    }

    private func loadActivities(category: String) async {
        // Simulate API delay
        try? await Task.sleep(for: .seconds(0.5))

        // Mock activity data based on category
        if category == "Indoor Activities" {
            allItems = [
                Store(
                    id: "bowling",
                    name: LocalizedName(th: "โบว์ลิ่ง", en: "Bowling"),
                    displayName: "Bowling",
                    tags: ["sports", "fun", "group"],
                    priceRange: .mid,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "karaoke",
                    name: LocalizedName(th: "คาราโอเกะ", en: "Karaoke"),
                    displayName: "Karaoke",
                    tags: ["music", "fun", "group"],
                    priceRange: .mid,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "escape-room",
                    name: LocalizedName(th: "ห้องหนีตาย", en: "Escape Room"),
                    displayName: "Escape Room",
                    tags: ["puzzle", "team", "adventure"],
                    priceRange: .mid,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "arcade",
                    name: LocalizedName(th: "เกมส์", en: "Arcade Games"),
                    displayName: "Arcade Games",
                    tags: ["games", "fun", "casual"],
                    priceRange: .budget,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "billiards",
                    name: LocalizedName(th: "บิลเลียด", en: "Billiards"),
                    displayName: "Billiards",
                    tags: ["sports", "chill", "casual"],
                    priceRange: .mid,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                )
            ]
        } else if category == "Outdoor Activities" {
            allItems = [
                Store(
                    id: "park-walk",
                    name: LocalizedName(th: "เดินสวน", en: "Park Walk"),
                    displayName: "Park Walk",
                    tags: ["nature", "relaxing", "free"],
                    priceRange: .budget,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "cycling",
                    name: LocalizedName(th: "ปั่นจักรยาน", en: "Cycling"),
                    displayName: "Cycling",
                    tags: ["sports", "exercise", "outdoor"],
                    priceRange: .budget,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "night-market",
                    name: LocalizedName(th: "ตลาดนัด", en: "Night Market"),
                    displayName: "Night Market",
                    tags: ["shopping", "food", "local"],
                    priceRange: .budget,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "temple-tour",
                    name: LocalizedName(th: "ชมวัด", en: "Temple Tour"),
                    displayName: "Temple Tour",
                    tags: ["culture", "sightseeing", "peaceful"],
                    priceRange: .budget,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "river-cruise",
                    name: LocalizedName(th: "ล่องเรือ", en: "River Cruise"),
                    displayName: "River Cruise",
                    tags: ["sightseeing", "romantic", "relaxing"],
                    priceRange: .mid,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                )
            ]
        } else if category == "Entertainment" {
            allItems = [
                Store(
                    id: "cinema",
                    name: LocalizedName(th: "ดูหนัง", en: "Cinema"),
                    displayName: "Cinema",
                    tags: ["movie", "indoor", "relaxing"],
                    priceRange: .mid,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "live-music",
                    name: LocalizedName(th: "ดนตรีสด", en: "Live Music"),
                    displayName: "Live Music",
                    tags: ["music", "nightlife", "fun"],
                    priceRange: .mid,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "theater",
                    name: LocalizedName(th: "ละคร", en: "Theater Show"),
                    displayName: "Theater Show",
                    tags: ["performance", "culture", "art"],
                    priceRange: .premium,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "comedy-club",
                    name: LocalizedName(th: "คอมเมดี้โชว์", en: "Comedy Club"),
                    displayName: "Comedy Club",
                    tags: ["comedy", "nightlife", "fun"],
                    priceRange: .mid,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "rooftop-bar",
                    name: LocalizedName(th: "รูฟท็อปบาร์", en: "Rooftop Bar"),
                    displayName: "Rooftop Bar",
                    tags: ["drinks", "view", "romantic"],
                    priceRange: .premium,
                    location: nil,
                    detailUrl: nil,
                    mapUrl: nil
                )
            ]
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
