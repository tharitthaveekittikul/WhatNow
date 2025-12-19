//
//  ListView.swift
//  WhatNow
//
//  List view - shows all stores/activities that will be randomized
//

import SwiftUI

struct ListView: View {
    let stores: [Store]
    let mall: Mall
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @State private var searchText = ""

    private var filteredStores: [Store] {
        if searchText.isEmpty {
            return stores
        } else {
            return stores.filter { store in
                store.displayName.localizedCaseInsensitiveContains(searchText)
                    || (store.name.th?.localizedCaseInsensitiveContains(
                        searchText
                    ) ?? false)
                    || (store.name.en?.localizedCaseInsensitiveContains(
                        searchText
                    ) ?? false)
                    || store.tags.contains { tag in
                        tag.replacingOccurrences(of: "_", with: " ")
                            .localizedCaseInsensitiveContains(searchText)
                    }
                    || store.priceRange.displayText
                        .localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredStores) { store in
                    NavigationLink {
                        ResultView(store: store, mall: mall)
                    } label: {
                        ListRow(store: store)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                if filteredStores.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.App.textTertiary)
                        Text(
                            "No stores found".localized(
                                for: appEnvironment.currentLanguage
                            )
                        )
                        .font(.appHeadline)
                        .foregroundColor(.App.textSecondary)
                        Text(
                            "Try a different search term".localized(
                                for: appEnvironment.currentLanguage
                            )
                        )
                        .font(.appCallout)
                        .foregroundColor(.App.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color.App.background.ignoresSafeArea())
        .navigationTitle(
            "All Stores".localized(for: appEnvironment.currentLanguage)
        )
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            prompt: Text(
                "Search stores".localized(for: appEnvironment.currentLanguage)
            )
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.App.textSecondary)
                }
            }
        }
        .id(appEnvironment.languageDidChange)  // Refresh when language changes
        .withBannerAd(placement: .list)
    }
}

struct ListRow: View {
    let store: Store
    @EnvironmentObject private var appEnvironment: AppEnvironment

    var body: some View {
        HStack(spacing: 14) {
            // Store logo or icon
            AsyncImageWithFallback(
                imageUrl: store.logoUrl,
                fallbackIcon: "fork.knife.circle.fill",
                size: 64,
                cornerRadius: 14
            )

            // Store info
            VStack(alignment: .leading, spacing: 8) {
                // Name and price
                HStack(spacing: 8) {
                    Text(
                        store.name.localized(
                            for: appEnvironment.currentLanguage
                        )
                    )
                    .font(.appHeadline)
                    .foregroundColor(.App.text)
                    .lineLimit(1)

                    Spacer()
                }

                HStack {
                    // Location
                    if let floor = store.location?.floor {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.appCaption2)
                                .foregroundColor(.App.textSecondary)
                            Text(
                                "Floor \(floor)".localized(
                                    for: appEnvironment.currentLanguage
                                )
                            )
                            .font(.appCallout)
                            .foregroundColor(.App.textSecondary)
                        }
                    }

                    Divider()

                    Text("\(store.priceRange.displayText)")
                        .font(.appCallout)
                        .foregroundColor(.App.textSecondary.opacity(0.8))
                        .fontWeight(.medium)
                }

                // Tags
                if !store.tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(store.tags.prefix(2), id: \.self) { tag in
                            Text(
                                tag.replacingOccurrences(of: "_", with: " ")
                                    .capitalized
                            )
                            .font(.appCaption2)
                            .foregroundColor(.App.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.App.accentSky.opacity(0.15))
                            )
                        }

                        if store.tags.count > 2 {
                            Text("+\(store.tags.count - 2)")
                                .font(.appCaption2)
                                .foregroundColor(.App.textTertiary)
                        }
                    }
                }
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.appCallout)
                .fontWeight(.semibold)
                .foregroundColor(.App.textTertiary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.App.surface)
                .shadow(
                    color: Color.App.text.opacity(0.04),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
    }
}

#Preview {
    NavigationStack {
        ListView(
            stores: [
                Store(
                    id: "1",
                    name: LocalizedName(th: "บอนชอน", en: "Bonchon Chicken"),
                    displayName: "Bonchon Chicken",
                    tags: ["korean", "chicken"],
                    priceRange: .mid,
                    location: StoreLocation(floor: "5F", zone: nil, unit: nil),
                    detailUrl: nil,
                    mapUrl: nil,
                    logoUrl: ""
                ),
                Store(
                    id: "2",
                    name: LocalizedName(th: "อาฟเตอร์ยู", en: "After You"),
                    displayName: "After You",
                    tags: ["cafe_dessert", "thai"],
                    priceRange: .mid,
                    location: StoreLocation(floor: "3F", zone: nil, unit: nil),
                    detailUrl: nil,
                    mapUrl: nil,
                    logoUrl: ""
                ),
                Store(
                    id: "3",
                    name: LocalizedName(th: "ฟูจิ", en: "Fuji"),
                    displayName: "Fuji Restaurant",
                    tags: ["japanese", "sushi"],
                    priceRange: .premium,
                    location: StoreLocation(floor: "4F", zone: nil, unit: nil),
                    detailUrl: nil,
                    mapUrl: nil,
                    logoUrl: ""
                ),
            ],
            mall: Mall(
                mallId: "siam-paragon",
                name: LocalizedName(th: "สยามพารากอน", en: "Siam Paragon"),
                displayName: "สยามพารากอน",
                city: "Bangkok",
                assetKey: "mall_paragon",
                tags: ["bts"],
                logoUrl: ""
            )
        )
    }
    .environmentObject(AppEnvironment())
}
