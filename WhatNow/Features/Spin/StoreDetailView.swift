//
//  StoreDetailView.swift
//  WhatNow
//
//  Store detail view - shows after spin result
//

import SwiftUI

struct StoreDetailView: View {
    let store: Store
    let mall: Mall
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    // Store icon/image placeholder
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.App.accentSky.opacity(0.3),
                                        Color.App.accentLavender.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)

                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.App.text.opacity(0.7))
                    }

                    // Store name
                    Text(store.displayName)
                        .font(.appTitle)
                        .foregroundColor(.App.text)
                        .multilineTextAlignment(.center)

                    // Price range
                    Text(store.priceRange.displayText)
                        .font(.appTitle2)
                        .foregroundColor(.App.textSecondary)
                }
                .padding(.top, 32)

                // Info cards
                VStack(spacing: 16) {
                    // Location card
                    if let location = store.location {
                        InfoCard(
                            icon: "location.fill",
                            title: "Location",
                            content: location.displayText
                        )
                    }

                    // Mall card
                    InfoCard(
                        icon: "building.2.fill",
                        title: "Mall",
                        content: mall.displayName
                    )

                    // Tags card
                    if !store.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.App.accentSky)
                                Text("Categories")
                                    .font(.appHeadline)
                                    .foregroundColor(.App.text)
                            }

                            FlowLayout(spacing: 8) {
                                ForEach(store.tags, id: \.self) { tag in
                                    Text(tag.replacingOccurrences(of: "_", with: " ").capitalized)
                                        .font(.appCaption)
                                        .foregroundColor(.App.text)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color.App.accentSky.opacity(0.2))
                                        )
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.App.surface)
                        )
                    }
                }
                .padding(.horizontal, 24)

                // Action buttons
                VStack(spacing: 12) {
                    if let mapUrl = store.mapUrl, let url = URL(string: mapUrl) {
                        ActionButton(
                            title: "Open in Maps",
                            icon: "map.fill",
                            color: .App.accentSky
                        ) {
                            UIApplication.shared.open(url)
                        }
                    }

                    if let detailUrl = store.detailUrl, let url = URL(string: detailUrl) {
                        ActionButton(
                            title: "View Details",
                            icon: "info.circle.fill",
                            color: .App.accentLavender
                        ) {
                            UIApplication.shared.open(url)
                        }
                    }

                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Spin Again")
                                .font(.appHeadline)
                        }
                        .foregroundColor(.App.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.App.text.opacity(0.3), lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color.App.background.ignoresSafeArea())
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Supporting Views

struct InfoCard: View {
    let icon: String
    let title: String
    let content: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.App.accentSky)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.appCaption)
                    .foregroundColor(.App.textSecondary)
                Text(content)
                    .font(.appBody)
                    .foregroundColor(.App.text)
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.App.surface)
        )
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.appHeadline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color)
            )
        }
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, row) in result.rows.enumerated() {
            let rowY = bounds.minY + result.rowYPositions[index]
            var x = bounds.minX
            for subviewIndex in row {
                let subview = subviews[subviewIndex]
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: rowY), proposal: .unspecified)
                x += size.width + spacing
            }
        }
    }

    private struct FlowResult {
        var rows: [[Int]] = [[]]
        var rowYPositions: [CGFloat] = [0]
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentRow = 0
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var maxRowWidth: CGFloat = 0

            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth, !rows[currentRow].isEmpty {
                    // Move to next row
                    currentRow += 1
                    rows.append([])
                    currentY += rowYPositions.last! + spacing
                    rowYPositions.append(size.height)
                    currentX = 0
                } else {
                    rowYPositions[currentRow] = max(rowYPositions[currentRow], size.height)
                }

                rows[currentRow].append(index)
                currentX += size.width + spacing
                maxRowWidth = max(maxRowWidth, currentX - spacing)
            }

            size = CGSize(width: maxRowWidth, height: currentY + rowYPositions.last!)
        }
    }
}

#Preview {
    NavigationStack {
        StoreDetailView(
            store: Store(
                id: "bonchon",
                name: LocalizedName(th: "บอนชอน", en: "Bonchon Chicken"),
                displayName: "Bonchon Chicken",
                tags: ["korean", "chicken"],
                priceRange: .mid,
                location: StoreLocation(floor: "5F", zone: "Food Court", unit: "A-12"),
                detailUrl: "https://example.com",
                mapUrl: "https://maps.google.com"
            ),
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
