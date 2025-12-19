//
//  FilterSheet.swift
//  WhatNow
//
//  Filter bottom sheet for store filtering
//

import SwiftUI

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appEnvironment: AppEnvironment

    let stores: [Store]
    @Binding var filter: StoreFilter

    @State private var tempFilter: StoreFilter

    init(stores: [Store], filter: Binding<StoreFilter>) {
        self.stores = stores
        self._filter = filter
        self._tempFilter = State(initialValue: filter.wrappedValue)
    }

    // Extract available categories with counts
    private var availableCategories: [CategoryOption] {
        var tagCounts: [String: Int] = [:]

        for store in stores {
            for tag in store.tags {
                tagCounts[tag, default: 0] += 1
            }
        }

        return tagCounts
            .map { CategoryOption(tag: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    // Extract price ranges with counts
    private var availablePriceRanges: [PriceRangeOption] {
        var priceCounts: [PriceRange: Int] = [:]

        for store in stores {
            priceCounts[store.priceRange, default: 0] += 1
        }

        return PriceRange.allCases
            .compactMap { priceRange in
                guard let count = priceCounts[priceRange], count > 0 else { return nil }
                return PriceRangeOption(priceRange: priceRange, count: count)
            }
    }

    // Calculate filtered count in real-time
    private var filteredCount: Int {
        tempFilter.apply(to: stores).count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.App.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Categories Section
                        if !availableCategories.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Categories".localized(for: appEnvironment.currentLanguage))
                                    .font(.appTitle3)
                                    .foregroundColor(.App.text)
                                    .padding(.horizontal, 24)

                                FlowLayout(spacing: 12) {
                                    ForEach(availableCategories) { category in
                                        CategoryFilterButton(
                                            category: category,
                                            isSelected: tempFilter.selectedCategories.contains(category.id),
                                            language: appEnvironment.currentLanguage
                                        ) {
                                            toggleCategory(category.id)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }

                        // Price Range Section
                        if !availablePriceRanges.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Price Range".localized(for: appEnvironment.currentLanguage))
                                    .font(.appTitle3)
                                    .foregroundColor(.App.text)
                                    .padding(.horizontal, 24)

                                HStack(spacing: 12) {
                                    ForEach(availablePriceRanges) { option in
                                        PriceRangeFilterButton(
                                            option: option,
                                            isSelected: tempFilter.selectedPriceRanges.contains(option.priceRange),
                                            language: appEnvironment.currentLanguage
                                        ) {
                                            togglePriceRange(option.priceRange)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                            }
                        }

                        // Empty state warning
                        if filteredCount == 0 && tempFilter.isActive {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("No stores match filters".localized(for: appEnvironment.currentLanguage))
                                    .font(.appCallout)
                                    .foregroundColor(.App.textSecondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Filter Stores".localized(for: appEnvironment.currentLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All".localized(for: appEnvironment.currentLanguage)) {
                        tempFilter.clear()
                    }
                    .disabled(!tempFilter.isActive)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        applyFilters()
                    } label: {
                        if filteredCount > 0 {
                            Text("Apply".localized(for: appEnvironment.currentLanguage) + " (\(filteredCount))")
                                .fontWeight(.semibold)
                        } else {
                            Text("Apply".localized(for: appEnvironment.currentLanguage))
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(filteredCount == 0 && tempFilter.isActive)
                }
            }
        }
    }

    private func toggleCategory(_ category: String) {
        if tempFilter.selectedCategories.contains(category) {
            tempFilter.selectedCategories.remove(category)
        } else {
            tempFilter.selectedCategories.insert(category)
        }
    }

    private func togglePriceRange(_ priceRange: PriceRange) {
        if tempFilter.selectedPriceRanges.contains(priceRange) {
            tempFilter.selectedPriceRanges.remove(priceRange)
        } else {
            tempFilter.selectedPriceRanges.insert(priceRange)
        }
    }

    private func applyFilters() {
        filter = tempFilter
        dismiss()
    }
}

// MARK: - Category Filter Button

private struct CategoryFilterButton: View {
    let category: CategoryOption
    let isSelected: Bool
    let language: Language
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(category.displayName(for: language))
                    .font(.appCallout)

                Text("(\(category.count))")
                    .font(.appCaption)
                    .foregroundColor(.App.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? Color.App.accentSky : Color.App.surface)
            )
            .foregroundColor(isSelected ? .App.text : .App.text)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.App.accentSky : Color.App.text.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Price Range Filter Button

private struct PriceRangeFilterButton: View {
    let option: PriceRangeOption
    let isSelected: Bool
    let language: Language
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(option.priceRange.displayText)
                    .font(.appTitle3)

                Text("(\(option.count))")
                    .font(.appCaption)
                    .foregroundColor(.App.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.App.accentWarm : Color.App.surface)
            )
            .foregroundColor(isSelected ? .App.text : .App.text)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.App.accentWarm : Color.App.text.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    FilterSheet(
        stores: [
            Store(
                id: "1",
                name: LocalizedName(th: "บอนชอน", en: "Bonchon"),
                displayName: "Bonchon",
                tags: ["korean", "chicken"],
                priceRange: .mid,
                location: nil,
                detailUrl: nil,
                mapUrl: nil
            ),
            Store(
                id: "2",
                name: LocalizedName(th: "อาฟเตอร์ยู", en: "After You"),
                displayName: "After You",
                tags: ["dessert", "cafe"],
                priceRange: .mid,
                location: nil,
                detailUrl: nil,
                mapUrl: nil
            ),
            Store(
                id: "3",
                name: LocalizedName(th: "ฟูจิ", en: "Fuji"),
                displayName: "Fuji",
                tags: ["japanese", "sushi"],
                priceRange: .premium,
                location: nil,
                detailUrl: nil,
                mapUrl: nil
            )
        ],
        filter: .constant(StoreFilter())
    )
    .environmentObject(AppEnvironment())
}
