//
//  StoreListView.swift
//  WhatNow
//
//  List view - shows all stores that will be randomized
//

import SwiftUI

struct StoreListView: View {
    let stores: [Store]
    let mall: Mall
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(stores) { store in
                    NavigationLink {
                        StoreDetailView(store: store, mall: mall)
                    } label: {
                        StoreListRow(store: store)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color.App.background.ignoresSafeArea())
        .navigationTitle("All Stores")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StoreListRow: View {
    let store: Store

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.App.accentSky.opacity(0.2),
                                Color.App.accentLavender.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: "fork.knife")
                    .font(.system(size: 24))
                    .foregroundColor(.App.text.opacity(0.6))
            }

            // Store info
            VStack(alignment: .leading, spacing: 6) {
                Text(store.displayName)
                    .font(.appHeadline)
                    .foregroundColor(.App.text)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(store.priceRange.displayText)
                        .font(.appCaption)
                        .foregroundColor(.App.textSecondary)

                    if let location = store.location?.floor {
                        Text("•")
                            .foregroundColor(.App.textSecondary.opacity(0.5))
                        Text("Floor \(location)")
                            .font(.appCaption)
                            .foregroundColor(.App.textSecondary)
                    }
                }

                // Tags
                if !store.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(store.tags.prefix(3), id: \.self) { tag in
                                Text(tag.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.App.text.opacity(0.7))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.App.accentSky.opacity(0.15))
                                    )
                            }
                        }
                    }
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.App.textSecondary.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.App.surface)
        )
    }
}

#Preview {
    NavigationStack {
        StoreListView(
            stores: [
                Store(
                    id: "1",
                    name: LocalizedName(th: "บอนชอน", en: "Bonchon Chicken"),
                    displayName: "Bonchon Chicken",
                    tags: ["korean", "chicken"],
                    priceRange: .mid,
                    location: StoreLocation(floor: "5F", zone: nil, unit: nil),
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "2",
                    name: LocalizedName(th: "อาฟเตอร์ยู", en: "After You"),
                    displayName: "After You",
                    tags: ["cafe_dessert", "thai"],
                    priceRange: .mid,
                    location: StoreLocation(floor: "3F", zone: nil, unit: nil),
                    detailUrl: nil,
                    mapUrl: nil
                ),
                Store(
                    id: "3",
                    name: LocalizedName(th: "ฟูจิ", en: "Fuji"),
                    displayName: "Fuji Restaurant",
                    tags: ["japanese", "sushi"],
                    priceRange: .premium,
                    location: StoreLocation(floor: "4F", zone: nil, unit: nil),
                    detailUrl: nil,
                    mapUrl: nil
                )
            ],
            mall: Mall(
                mallId: "siam-paragon",
                name: LocalizedName(th: "สยามพารากอน", en: "Siam Paragon"),
                displayName: "สยามพารากอน",
                city: "Bangkok",
                assetKey: "mall_paragon",
                tags: ["bts"]
            )
        )
    }
}
