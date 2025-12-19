//
//  FilterChip.swift
//  WhatNow
//
//  Active filter chip component
//

import SwiftUI

/// Displays active filters as removable chips
struct FilterChipsView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    let filter: StoreFilter
    let onRemoveCategory: (String) -> Void
    let onRemovePriceRange: (PriceRange) -> Void
    let onClearAll: () -> Void

    var body: some View {
        if filter.isActive {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Category chips
                    ForEach(Array(filter.selectedCategories).sorted(), id: \.self) { category in
                        FilterChip(
                            text: category.replacingOccurrences(of: "_", with: " ").capitalized,
                            color: Color.App.accentSky
                        ) {
                            onRemoveCategory(category)
                        }
                    }

                    // Price range chips
                    ForEach(Array(filter.selectedPriceRanges).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { priceRange in
                        FilterChip(
                            text: priceRange.displayText,
                            color: Color.App.accentWarm
                        ) {
                            onRemovePriceRange(priceRange)
                        }
                    }

                    // Clear all button
                    if filter.activeFilterCount > 1 {
                        Button(action: onClearAll) {
                            Text("Clear All".localized(for: appEnvironment.currentLanguage))
                                .font(.appCaption)
                                .foregroundColor(.App.textSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .strokeBorder(Color.App.textSecondary.opacity(0.5), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

/// Individual filter chip with remove button
private struct FilterChip: View {
    let text: String
    let color: Color
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.appCaption)
                .foregroundColor(.App.text)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.App.text.opacity(0.8))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color)
        )
    }
}

#Preview {
    VStack {
        FilterChipsView(
            filter: StoreFilter(
                selectedCategories: ["korean", "japanese"],
                selectedPriceRanges: [.mid, .premium]
            ),
            onRemoveCategory: { _ in },
            onRemovePriceRange: { _ in },
            onClearAll: {}
        )
        .environmentObject(AppEnvironment())

        Spacer()
    }
    .background(Color.App.background)
}
