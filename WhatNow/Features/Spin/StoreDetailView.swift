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
    let showSpinAgain: Bool
    @Environment(\.dismiss) private var dismiss

    init(store: Store, mall: Mall, showSpinAgain: Bool = false) {
        self.store = store
        self.mall = mall
        self.showSpinAgain = showSpinAgain
    }

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
                                Spacer()
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
                                        .fixedSize()
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                            color: Color(light: Color(hex: "4A90E2"), dark: Color(hex: "5BA3F5"))
                        ) {
                            UIApplication.shared.open(url)
                        }
                    }

                    if let detailUrl = store.detailUrl, let url = URL(string: detailUrl) {
                        ActionButton(
                            title: "View Details",
                            icon: "info.circle.fill",
                            color: Color(light: Color(hex: "9B6FD6"), dark: Color(hex: "B494E5"))
                        ) {
                            UIApplication.shared.open(url)
                        }
                    }

                    if showSpinAgain {
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
                        .buttonStyle(ScaleButtonStyle())
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
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
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
        var currentY = bounds.minY
        for (index, row) in result.rows.enumerated() {
            var x = bounds.minX
            for subviewIndex in row {
                let subview = subviews[subviewIndex]
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: currentY), proposal: .unspecified)
                x += size.width + spacing
            }
            currentY += result.rowHeights[index] + spacing
        }
    }

    private struct FlowResult {
        var rows: [[Int]] = [[]]
        var rowHeights: [CGFloat] = [0]
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentRow = 0
            var currentX: CGFloat = 0
            var maxRowWidth: CGFloat = 0

            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth, !rows[currentRow].isEmpty {
                    // Move to next row
                    currentRow += 1
                    rows.append([])
                    rowHeights.append(0)
                    currentX = 0
                }

                rowHeights[currentRow] = max(rowHeights[currentRow], size.height)
                rows[currentRow].append(index)
                currentX += size.width + spacing
                maxRowWidth = max(maxRowWidth, currentX - spacing)
            }

            // Calculate total height
            let totalHeight = rowHeights.reduce(0, +) + CGFloat(max(0, rowHeights.count - 1)) * spacing
            size = CGSize(width: maxRowWidth, height: totalHeight)
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
            ),
            showSpinAgain: true
        )
    }
}
