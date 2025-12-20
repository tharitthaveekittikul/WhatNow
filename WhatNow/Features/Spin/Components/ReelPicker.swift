//
//  ReelPicker.swift
//  WhatNow
//
//  Slot-machine style vertical reel picker with smooth slowdown animation
//

import SwiftUI

struct ReelPicker<Item: SpinnableItem>: View {
    let items: [Item]
    let isSpinning: Bool
    @Binding var reelIndex: Int
    @EnvironmentObject private var appEnvironment: AppEnvironment

    // MARK: - Configuration

    private let itemHeight: CGFloat = 80
    private let visibleItems = 5
    private let centerIndex = 2

    // Spin parameters
    private let spinDuration: Double = 3.0 // Total spin time
    private let minFullCycles: Int = 5 // Minimum full rotations before landing

    // Calculate minimum repeated items needed to avoid white space during spin
    // We need enough items to scroll minFullCycles forward from the middle
    // Formula: we need (minFullCycles + 2) complete cycles, doubled for centering
    private var minTotalItems: Int {
        let cyclesNeeded = minFullCycles + 3 // +3 for safety buffer
        return items.count * cyclesNeeded * 2
    }

    // MARK: - State

    @State private var scrollPosition: CGFloat = 0
    @State private var targetItemIndex: Int = 0
    @State private var isAnimating: Bool = false // Prevent interference during animation

    // MARK: - Computed Properties

    private var repeats: Int {
        guard !items.isEmpty else { return 2 }
        return max(2, Int(ceil(Double(minTotalItems) / Double(items.count))))
    }

    private var totalRepeatedItems: Int {
        items.count * repeats
    }

    private var baseIndex: Int {
        guard !items.isEmpty else { return 0 }
        let middle = totalRepeatedItems / 2
        return (middle / items.count) * items.count
    }

    var body: some View {
        ZStack {
            // Background panel
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.App.surface)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)

            // Scrolling reel viewport
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Top padding
                    Color.clear.frame(height: CGFloat(centerIndex) * itemHeight)

                    // Repeated items
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
            if spinning {
                startSpin()
            }
        }
        .onChange(of: reelIndex) { newIndex in
            // Update when reelIndex changes externally (not during spin or animation)
            if !isSpinning && !isAnimating {
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
        let landingItemIndex = finalDisplayIndex % items.count
        assert(landingItemIndex == targetItemIndex, "Math error: will land on \(landingItemIndex) but target is \(targetItemIndex)")

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
