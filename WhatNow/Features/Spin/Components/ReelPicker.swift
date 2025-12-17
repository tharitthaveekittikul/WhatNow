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
    @State private var offset: CGFloat = 0
    private let itemHeight: CGFloat = 80
    private let visibleItems = 5
    private let centerIndex = 2

    var body: some View {
        ZStack {
            // Background panel
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.App.surface)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)

            // Reel container
            VStack(spacing: 0) {
                ForEach(0..<visibleItems, id: \.self) { index in
                    reelItem(at: index)
                        .frame(height: itemHeight)
                }
            }
            .offset(y: offset)
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
    }

    @ViewBuilder
    private func reelItem(at displayIndex: Int) -> some View {
        let actualIndex = (selectedIndex - centerIndex + displayIndex + items.count * 100) % items.count

        if actualIndex < items.count {
            let store = items[actualIndex]
            let distanceFromCenter = abs(displayIndex - centerIndex)
            let scale = 1.0 - (CGFloat(distanceFromCenter) * 0.15)
            let opacity = 1.0 - (CGFloat(distanceFromCenter) * 0.3)

            VStack(spacing: 4) {
                Text(store.displayName)
                    .font(.appHeadline)
                    .foregroundColor(.App.text)
                    .lineLimit(1)

                Text(store.priceRange.displayText)
                    .font(.appCaption)
                    .foregroundColor(.App.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(scale)
            .opacity(opacity)
        }
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
