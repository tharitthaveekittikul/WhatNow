//
//  ReelPicker.swift
//  WhatNow
//
//  Slot-machine style vertical reel picker
//

import SwiftUI

struct ReelPicker: View {
    let items: [Store]
    @Binding var isSpinning: Bool
    @Binding var selectedIndex: Int

    // Animation state
    @State private var scrollPosition: CGFloat = 0
    private let itemHeight: CGFloat = 80
    private let visibleItems = 5
    private let centerIndex = 2

    var body: some View {
        ZStack {
            // Background panel
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.App.surface)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)

            // Scrolling reel
            GeometryReader { geo in
                VStack(spacing: 0) {
                    // Repeat items for infinite scroll effect
                    ForEach(0..<(items.count * 3), id: \.self) { index in
                        let store = items[index % items.count]
                        reelItem(store: store, globalIndex: index)
                            .frame(height: itemHeight)
                    }
                }
                .offset(y: scrollPosition)
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black, location: 0.15),
                            .init(color: .black, location: 0.85),
                            .init(color: .clear, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

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
        .onChange(of: selectedIndex) { newValue in
            updateScrollPosition(animated: isSpinning)
        }
        .onAppear {
            updateScrollPosition(animated: false)
        }
    }

    private func updateScrollPosition(animated: Bool) {
        // Calculate the scroll position to center the selected item
        // Start from middle of repeated items (items.count)
        let targetPosition = CGFloat(items.count + selectedIndex) * itemHeight
        let centerOffset = CGFloat(centerIndex) * itemHeight
        let newPosition = -(targetPosition - centerOffset)

        if animated {
            withAnimation(.easeOut(duration: 2.5)) {
                scrollPosition = newPosition
            }
        } else {
            scrollPosition = newPosition
        }
    }

    @ViewBuilder
    private func reelItem(store: Store, globalIndex: Int) -> some View {
        // Calculate distance from center for scale/opacity effects
        let itemPosition = CGFloat(globalIndex) * itemHeight
        let centerPosition = -scrollPosition + CGFloat(centerIndex) * itemHeight
        let distance = abs(itemPosition - centerPosition) / itemHeight

        let scale = max(0.85, 1.0 - (distance * 0.08))
        let opacity = max(0.4, 1.0 - (distance * 0.25))

        VStack(spacing: 4) {
            Text(store.displayName)
                .font(.appHeadline)
                .foregroundColor(.App.text)
                .lineLimit(1)
                .truncationMode(.tail)

            Text(store.priceRange.displayText)
                .font(.appCaption)
                .foregroundColor(.App.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: itemHeight)
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
                priceRange: .mid
            ),
            Store(
                id: "2",
                name: LocalizedName(th: "ร้านอาหาร 2", en: "Restaurant 2"),
                displayName: "After You",
                tags: ["dessert"],
                priceRange: .mid
            ),
            Store(
                id: "3",
                name: LocalizedName(th: "ร้านอาหาร 3", en: "Restaurant 3"),
                displayName: "Fuji",
                tags: ["japanese"],
                priceRange: .premium
            )
        ],
        isSpinning: .constant(false),
        selectedIndex: .constant(0)
    )
    .background(Color.App.background)
}
