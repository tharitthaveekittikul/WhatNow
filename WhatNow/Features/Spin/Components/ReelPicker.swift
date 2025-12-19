//
//  ReelPicker.swift
//  WhatNow
//
//  Slot-machine style vertical reel picker
//

import SwiftUI

struct ReelPicker: View {
    let items: [Store]
    let isSpinning: Bool
    @Binding var reelIndex: Int
    @EnvironmentObject private var appEnvironment: AppEnvironment

    // Animation state
    @State private var scrollPosition: CGFloat = 0
    private let itemHeight: CGFloat = 80
    private let visibleItems = 5
    private let centerIndex = 2
    private let minTotalItems = 60  // Minimum items for good spin experience

    // Calculate how many times to repeat items to reach at least minTotalItems
    private var repeats: Int {
        guard !items.isEmpty else { return 2 }
        let calculated = max(2, Int(ceil(Double(minTotalItems) / Double(items.count))))
        return calculated
    }

    // Total items after repeating
    private var totalRepeatedItems: Int {
        items.count * repeats
    }

    // Base index MUST be aligned to items.count for modulo arithmetic to work correctly
    // This ensures: baseIndex % items.count == 0
    private var baseIndex: Int {
        guard !items.isEmpty else { return 0 }
        let middle = totalRepeatedItems / 2
        // Round down to nearest multiple of items.count
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
                    // Add padding to allow proper scrolling
                    Color.clear.frame(height: CGFloat(centerIndex) * itemHeight)

                    // Repeat items to reach at least minTotalItems for good spin experience
                    ForEach(0..<totalRepeatedItems, id: \.self) { index in
                        let store = items[index % items.count]
                        reelItem(store: store, globalIndex: index)
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
        .onChange(of: reelIndex) { newValue in
            updateScrollPosition()
        }
        .onChange(of: items.count) { _ in
            // Force update when items change (e.g., after filtering)
            updateScrollPosition()
        }
        .onAppear {
            updateScrollPosition()
        }
    }

    private func updateScrollPosition() {
        // Calculate the scroll position to center the current reel item
        // Account for top padding (centerIndex * itemHeight)

        // Map reelIndex to actual display position using baseIndex
        // This keeps us in the middle of the repeated items array
        let displayIndex = baseIndex + (reelIndex % items.count)

        // Calculate scroll offset
        let itemPosition = (CGFloat(centerIndex) + CGFloat(displayIndex)) * itemHeight
        let centerPosition = CGFloat(centerIndex) * itemHeight
        let newPosition = -(itemPosition - centerPosition)

        // Animate scrollPosition changes
        if isSpinning {
            // During spin: use spring animation for smooth slot-machine feel
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scrollPosition = newPosition
            }
        } else {
            // Initial setup: no animation
            scrollPosition = newPosition
        }
    }

    @ViewBuilder
    private func reelItem(store: Store, globalIndex: Int) -> some View {
        // Calculate distance from center for scale/opacity effects
        // Account for top padding when calculating position
        let itemPosition = (CGFloat(centerIndex) + CGFloat(globalIndex)) * itemHeight
        let centerPosition = -scrollPosition + CGFloat(centerIndex) * itemHeight
        let distance = abs(itemPosition - centerPosition) / itemHeight

        let scale = max(0.85, 1.0 - (distance * 0.08))
        let opacity = max(0.4, 1.0 - (distance * 0.25))

        VStack(spacing: 4) {
            Text(store.name.localized(for: appEnvironment.currentLanguage))
                .font(.appHeadline)
                .foregroundColor(.App.text)
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)

            Text(store.priceRange.displayText)
                .font(.appCaption)
                .foregroundColor(.App.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: itemHeight)
        .padding(.horizontal, 24)
        .scaleEffect(scale)
        .opacity(opacity)
    }
}

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
                mapUrl: nil, logoUrl: nil
            ),
            Store(
                id: "2",
                name: LocalizedName(th: "ร้านอาหาร 2", en: "Restaurant 2"),
                displayName: "After You",
                tags: ["dessert"],
                priceRange: .mid,
                location: nil,
                detailUrl: nil,
                mapUrl: nil, logoUrl: nil
            ),
            Store(
                id: "3",
                name: LocalizedName(th: "ร้านอาหาร 3", en: "Restaurant 3"),
                displayName: "Fuji",
                tags: ["japanese"],
                priceRange: .premium,
                location: nil,
                detailUrl: nil,
                mapUrl: nil, logoUrl: nil
            )
        ],
        isSpinning: false,
        reelIndex: .constant(0)
    )
    .background(Color.App.background)
    .environmentObject(AppEnvironment())
}
