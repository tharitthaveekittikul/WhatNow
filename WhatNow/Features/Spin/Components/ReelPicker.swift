//
//  ReelPicker.swift
//  WhatNow
//
//  Slot-machine style vertical reel picker with smooth slowdown animation
//  PERFORMANCE OPTIMIZED: Uses adaptive repeats to handle large datasets (100-1000+ items)
//

import SwiftUI

struct ReelPicker<Item: SpinnableItem>: View {
    let items: [Item]
    let isSpinning: Bool
    @Binding var reelIndex: Int
    var autoSpin: Bool = true  // Set to false for external control
    @EnvironmentObject private var appEnvironment: AppEnvironment

    // MARK: - Configuration

    private let itemHeight: CGFloat = 80
    private let visibleItems = 5
    private let centerIndex = 2

    // Spin parameters
    private let spinDuration: Double = 3.0 // Total spin time

    // PERFORMANCE: Adaptive minimum cycles based on dataset size
    // Fewer cycles for large datasets to reduce total rendered items
    private var minFullCycles: Int {
        let itemCount = items.count
        if itemCount < 50 {
            return 5 // Full visual experience for small datasets
        } else if itemCount < 200 {
            return 4 // Slightly reduced for medium datasets
        } else {
            return 3 // Minimum for large datasets (still provides good visual feedback)
        }
    }

    // PERFORMANCE: Adaptive repeats strategy
    // Instead of always using 10+ repeats (which creates 5000+ views for 500 items),
    // we use fewer repeats for large datasets while ensuring enough for smooth animation
    private var repeats: Int {
        guard !items.isEmpty else { return 2 }
        let itemCount = items.count

        // Calculate minimum repeats needed for spin animation
        // We need enough repeats to cover:
        // 1. Starting position at middle (repeats/2)
        // 2. Scrolling forward by (minFullCycles + extra margin) × items.count
        // Formula: repeats ≥ 2 × (minFullCycles + 2) for safety margin
        // Small datasets (< 50): 2 × (5 + 2) = 14 repeats
        // Large datasets (200+): 2 × (3 + 2) = 10 repeats
        let minRepeatsForAnimation = 2 * (minFullCycles + 2)

        // PERFORMANCE: Hard cap at 2500 total rendered items for smooth 60fps
        let maxTotalItems = 2500
        let maxRepeatsForPerformance = maxTotalItems / itemCount

        // For small datasets, use more repeats for visual variety
        if itemCount < 20 {
            return min(15, maxRepeatsForPerformance) // Cap at performance limit
        } else if itemCount < 50 {
            return min(15, maxRepeatsForPerformance) // Cap at performance limit
        } else if itemCount < 100 {
            return min(minRepeatsForAnimation, maxRepeatsForPerformance)
        } else {
            // For 100+ items, use whichever is larger between minimum and performance cap
            // This ensures smooth animation even if it means more items
            // 100 items: min(14, 25) = 14 repeats = 1400 total ✓
            // 200 items: min(14, 12) = 12 repeats = 2400 total ✓ (close to cap)
            // 500 items: min(14, 5) = 5 repeats = 2500 total ❌ (too few, will show white space!)
            // So we need to use minRepeatsForAnimation for large datasets
            return minRepeatsForAnimation
        }
    }

    private var totalRepeatedItems: Int {
        items.count * repeats
    }

    private var baseIndex: Int {
        guard !items.isEmpty else { return 0 }
        let middle = totalRepeatedItems / 2
        return (middle / items.count) * items.count
    }

    // MARK: - State

    @State private var scrollPosition: CGFloat = 0
    @State private var targetItemIndex: Int = 0
    @State private var isAnimating: Bool = false // Prevent interference during animation

    var body: some View {
        ZStack {
            // Background panel
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.App.surface)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)

            // PERFORMANCE: Adaptive repeat rendering
            // Renders all repeated items, but uses fewer repeats for large datasets
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Top padding
                    Color.clear.frame(height: CGFloat(centerIndex) * itemHeight)

                    // Repeated items (adaptive count based on dataset size)
                    ForEach(0..<totalRepeatedItems, id: \.self) { index in
                        let item = items[index % items.count]
                        reelItem(item: item, globalIndex: index)
                            .frame(height: itemHeight)
                    }

                    // Bottom padding
                    Color.clear.frame(height: CGFloat(visibleItems - centerIndex - 1) * itemHeight)
                }
                .frame(width: geometry.size.width)
                .offset(y: scrollPosition)
                .drawingGroup() // PERFORMANCE: Flatten into single layer for GPU rendering
            }
            .frame(height: CGFloat(visibleItems) * itemHeight)
            .clipped()
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.2),
                        .init(color: .black, location: 0.8),
                        .init(color: .clear, location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // Center highlight bar
            Rectangle()
                .fill(Color.App.accentSky.opacity(0.2))
                .frame(height: itemHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.App.accentSky, lineWidth: 2)
                )
                .padding(.horizontal, 8)
        }
        .frame(height: CGFloat(visibleItems) * itemHeight)
        .padding()
        .onAppear {
            updateScrollPosition(animated: false)
        }
        .onChange(of: isSpinning) { spinning in
            if spinning && autoSpin {
                startSpin()
            }
        }
        .onChange(of: reelIndex) { newIndex in
            // If autoSpin is false, always follow reelIndex changes (external control)
            // No animation here because the binding value itself is animated by the parent
            if !autoSpin {
                updateScrollPosition(animated: false)
            }
            // If autoSpin is true, only update when not spinning/animating
            else if !isSpinning && !isAnimating {
                updateScrollPosition(animated: false)
            }
        }
        .onChange(of: items.count) { _ in
            // Reset if items change
            isAnimating = false
            updateScrollPosition(animated: false)
        }
    }

    // MARK: - Item View

    @ViewBuilder
    private func reelItem(item: Item, globalIndex: Int) -> some View {
        // Calculate distance from center for depth effects
        let itemPosition = (CGFloat(centerIndex) + CGFloat(globalIndex)) * itemHeight
        let centerPosition = -scrollPosition + CGFloat(centerIndex) * itemHeight
        let distance = abs(itemPosition - centerPosition) / itemHeight

        let scale = max(0.85, 1.0 - (distance * 0.08))
        let opacity = max(0.4, 1.0 - (distance * 0.25))

        VStack(spacing: 4) {
            Text(item.displayName)
                .font(.appHeadline)
                .foregroundColor(.App.text)
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)

            if !item.secondaryInfo.isEmpty {
                Text(item.secondaryInfo)
                    .font(.appCaption)
                    .foregroundColor(.App.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: itemHeight)
        .padding(.horizontal, 24)
        .scaleEffect(scale)
        .opacity(opacity)
    }

    // MARK: - Animation Logic

    /// Starts the spin animation with gradual slowdown (easeOut)
    /// This creates the classic slot machine deceleration effect
    private func startSpin() {
        guard !items.isEmpty else { return }

        // Set animation flag to prevent onChange interference
        isAnimating = true

        // Pick random target item (this is what we'll land on)
        targetItemIndex = Int.random(in: 0..<items.count)

        // CRITICAL: Update reelIndex NOW, before animation starts
        // This ensures ViewModel sees the correct result when its timer expires
        reelIndex = targetItemIndex

        // Get current display index (which slot in repeated array is centered)
        let currentDisplayIndex = getCurrentDisplayIndex()
        let currentItemIndex = currentDisplayIndex % items.count

        // Calculate how many items to scroll to land on targetItemIndex
        // We want: (finalDisplayIndex % items.count) == targetItemIndex
        let minExtraItems = minFullCycles * items.count

        // Items needed to reach target from current position
        let itemsToTarget = (targetItemIndex - currentItemIndex + items.count) % items.count

        // Total items to scroll (at least minExtraItems)
        let totalItemsToScroll = minExtraItems + itemsToTarget

        // Final display index in the repeated array
        let finalDisplayIndex = currentDisplayIndex + totalItemsToScroll

        // Verify the math (debug check)
        #if DEBUG
        let landingItemIndex = finalDisplayIndex % items.count
        if landingItemIndex != targetItemIndex {
            print("⚠️ VERIFICATION FAILED: will land on \(landingItemIndex) but target is \(targetItemIndex)")
            print("   currentDisplayIndex=\(currentDisplayIndex), currentItemIndex=\(currentItemIndex)")
            print("   targetItemIndex=\(targetItemIndex), totalItemsToScroll=\(totalItemsToScroll)")
            print("   finalDisplayIndex=\(finalDisplayIndex)")
        }
        assert(landingItemIndex == targetItemIndex, "Math error: will land on \(landingItemIndex) but target is \(targetItemIndex)")
        #endif

        let finalScrollPosition = calculateScrollPosition(for: finalDisplayIndex)

        // Single smooth animation with easeOut for gradual slowdown
        withAnimation(.timingCurve(0.25, 0.46, 0.45, 0.94, duration: spinDuration)) {
            scrollPosition = finalScrollPosition
        }

        // Clear animation flag and haptic feedback when animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + spinDuration) {
            // CRITICAL: Reset scroll position back to middle (baseIndex zone)
            // This prevents us from scrolling past the end of repeated array on subsequent spins
            // We snap to the same item but at a safe position (user won't notice)
            let safeDisplayIndex = self.baseIndex + self.targetItemIndex
            let safeScrollPosition = self.calculateScrollPosition(for: safeDisplayIndex)

            // Instant snap (no animation) to safe position
            self.scrollPosition = safeScrollPosition

            self.isAnimating = false

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    /// Get current display index based on scroll position
    /// Returns which slot in the repeated array is currently centered
    private func getCurrentDisplayIndex() -> Int {
        // scrollPosition = -(displayIndex * itemHeight)
        // So: displayIndex = -scrollPosition / itemHeight
        return Int(round(-scrollPosition / itemHeight))
    }

    /// Calculate scroll offset to center a specific display index
    private func calculateScrollPosition(for displayIndex: Int) -> CGFloat {
        let itemPosition = (CGFloat(centerIndex) + CGFloat(displayIndex)) * itemHeight
        let centerPosition = CGFloat(centerIndex) * itemHeight
        return -(itemPosition - centerPosition)
    }

    /// Update scroll position to show reelIndex at center
    private func updateScrollPosition(animated: Bool) {
        guard !items.isEmpty else { return }

        let displayIndex = baseIndex + (reelIndex % items.count)
        let newPosition = calculateScrollPosition(for: displayIndex)

        if animated {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scrollPosition = newPosition
            }
        } else {
            scrollPosition = newPosition
        }
    }
}

// MARK: - Preview

#Preview {
    ReelPicker(
        items: [
            Store(
                id: "1",
                name: LocalizedName(th: "ร้านอาหาร", en: "Restaurant"),
                displayName: "Bonchon Chicken",
                tags: ["korean"],
                priceRange: .mid,
                location: nil,
                detailUrl: nil,
                mapUrl: nil,
                logoUrl: nil
            ),
            Store(
                id: "2",
                name: LocalizedName(th: "ร้านอาหาร 2", en: "Restaurant 2"),
                displayName: "After You",
                tags: ["dessert"],
                priceRange: .mid,
                location: nil,
                detailUrl: nil,
                mapUrl: nil,
                logoUrl: nil
            ),
            Store(
                id: "3",
                name: LocalizedName(th: "ร้านอาหาร 3", en: "Restaurant 3"),
                displayName: "Fuji",
                tags: ["japanese"],
                priceRange: .premium,
                location: nil,
                detailUrl: nil,
                mapUrl: nil,
                logoUrl: nil
            ),
            Store(
                id: "4",
                name: LocalizedName(th: "ร้านอาหาร 4", en: "Restaurant 4"),
                displayName: "Starbucks",
                tags: ["cafe"],
                priceRange: .mid,
                location: nil,
                detailUrl: nil,
                mapUrl: nil,
                logoUrl: nil
            ),
            Store(
                id: "5",
                name: LocalizedName(th: "ร้านอาหาร 5", en: "Restaurant 5"),
                displayName: "KFC",
                tags: ["fast-food"],
                priceRange: .budget,
                location: nil,
                detailUrl: nil,
                mapUrl: nil,
                logoUrl: nil
            )
        ],
        isSpinning: false,
        reelIndex: .constant(0)
    )
    .background(Color.App.background)
    .environmentObject(AppEnvironment())
}
