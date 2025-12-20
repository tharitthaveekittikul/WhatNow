//
//  ResultView.swift
//  WhatNow
//
//  Result view - shows after spin result (store/activity details)
//

import SafariServices
import SwiftUI

struct ResultView: View {
    let store: Store
    let mall: Mall?
    let suggestedMallNames: String?
    let showSpinAgain: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @State private var showSupportForm = false
    @State private var supportFormURL: URL?

    init(store: Store, mall: Mall? = nil, suggestedMallNames: String? = nil, showSpinAgain: Bool = false) {
        self.store = store
        self.mall = mall
        self.suggestedMallNames = suggestedMallNames
        self.showSpinAgain = showSpinAgain
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    // Store logo or icon
                    AsyncImageWithFallback(
                        imageUrl: store.logoUrl,
                        fallbackIcon: "fork.knife.circle.fill",
                        size: 120,
                        cornerRadius: 60
                    )

                    // Store name
                    Text(
                        store.name.localized(
                            for: appEnvironment.currentLanguage
                        )
                    )
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
                            title: "Location".localized(
                                for: appEnvironment.currentLanguage
                            ),
                            content: location.displayText
                        )
                    }

                    // Mall card (only show if mall is provided)
                    if let mall = mall {
                        InfoCard(
                            icon: "building.2.fill",
                            title: "Mall".localized(
                                for: appEnvironment.currentLanguage
                            ),
                            content: mall.name.localized(
                                for: appEnvironment.currentLanguage
                            )
                        )
                    }

                    // Suggested malls card (for famous restaurants)
                    if let suggestedMallNames = suggestedMallNames {
                        InfoCard(
                            icon: "building.2.fill",
                            title: "Available at".localized(
                                for: appEnvironment.currentLanguage
                            ),
                            content: suggestedMallNames
                        )
                    }

                    // Tags card
                    if !store.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.App.accentSky)
                                Text(
                                    "Categories".localized(
                                        for: appEnvironment.currentLanguage
                                    )
                                )
                                .font(.appHeadline)
                                .foregroundColor(.App.text)
                                Spacer()
                            }

                            FlowLayout(spacing: 8) {
                                ForEach(store.tags, id: \.self) { tag in
                                    Text(
                                        tag.replacingOccurrences(
                                            of: "_",
                                            with: " "
                                        ).capitalized
                                    )
                                    .font(.appCaption)
                                    .foregroundColor(.App.text)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(
                                                Color.App.accentSky.opacity(0.3)
                                            )
                                    )
                                    .fixedSize()
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 16,
                                style: .continuous
                            )
                            .fill(Color.App.surface)
                        )
                    }
                }
                .padding(.horizontal, 24)

                // Action buttons
                VStack(spacing: 12) {
                    if let mapUrl = store.mapUrl, let url = URL(string: mapUrl)
                    {
                        ActionButton(
                            title: "Open in Maps".localized(
                                for: appEnvironment.currentLanguage
                            ),
                            icon: "map.fill",
                            color: Color.App.accentSky
                        ) {
                            UIApplication.shared.open(url)
                        }
                    }

                    if let detailUrl = store.detailUrl,
                        let url = URL(string: detailUrl)
                    {
                        ActionButton(
                            title: "View Details".localized(
                                for: appEnvironment.currentLanguage
                            ),
                            icon: "info.circle.fill",
                            color: Color.App.accentLavender
                        ) {
                            UIApplication.shared.open(url)
                        }
                    }

                    // Report Problem button
                    Button(action: {
                        openReportProblem()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.bubble.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text(
                                "Report Problem".localized(
                                    for: appEnvironment.currentLanguage
                                )
                            )
                            .font(.appHeadline)
                        }
                        .foregroundColor(.App.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 16,
                                style: .continuous
                            )
                            .strokeBorder(
                                Color.App.textSecondary.opacity(0.3),
                                lineWidth: 2
                            )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())

                    if showSpinAgain {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(
                                    "Spin Again".localized(
                                        for: appEnvironment.currentLanguage
                                    )
                                )
                                .font(.appHeadline)
                            }
                            .foregroundColor(.App.text)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 16,
                                    style: .continuous
                                )
                                .strokeBorder(
                                    Color.App.text.opacity(0.3),
                                    lineWidth: 2
                                )
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
        .navigationTitle(
            "Result".localized(for: appEnvironment.currentLanguage)
        )
        .navigationBarTitleDisplayMode(.inline)
        .id(appEnvironment.languageDidChange)  // Refresh when language changes
        .withBannerAd(placement: .result)
        .sheet(isPresented: $showSupportForm) {
            if let url = supportFormURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Actions

    private func openReportProblem() {
        Task {
            let formBase = "https://docs.google.com/forms/d/e/1FAIpQLSeiBB9cJTxxyzQqVxUgs1L4Bi-yxr-RUqPzI_eOU5RA_eb_7g/viewform"

            // Get app info
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
            let deviceModel = UIDevice.current.model
            let iosVersion = UIDevice.current.systemVersion
            let appLanguage = appEnvironment.currentLanguage.rawValue
            let appLocale = "\(appLanguage)_\(Locale.current.regionCode ?? "TH")"
            let timeZone = TimeZone.current.identifier

            // Check if user has Pro
            let isProUser = await appEnvironment.purchaseService.hasPurchased(productId: "whatnow_pro")

            var entries: [String: String] = [
                "entry.644868148": appVersion,
                "entry.573002577": buildNumber,
                "entry.1516834508": deviceModel,
                "entry.797688444": iosVersion,
                "entry.114735768": appLocale,
                "entry.266300204": timeZone,
                "entry.2042691400": isProUser ? "Yes" : "No",
            ]

            // Add store-specific entries ONLY if this is a mall spin (has mall and location)
            if let mall = mall, let location = store.location {
                let storeName = store.name.localized(for: appEnvironment.currentLanguage)
                let mallName = mall.name.localized(for: appEnvironment.currentLanguage)
                let locationText = location.displayText

                entries["entry.1754396415"] = storeName
                entries["entry.1745886589"] = mallName
                entries["entry.1618588487"] = locationText
            }

            var components = URLComponents(string: formBase)
            components?.queryItems = entries.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }

            supportFormURL = components?.url
            showSupportForm = true
        }
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
            .foregroundColor(.App.text)
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
            .animation(
                .easeInOut(duration: 0.1),
                value: configuration.isPressed
            )
    }
}

// Safari View for ResultView
private struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true

        let safari = SFSafariViewController(url: url, configuration: config)
        safari.preferredControlTintColor = UIColor(Color.App.text)
        return safari
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: Context
    ) {}
}

// Helper type for sheet presentation
private struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        var currentY = bounds.minY
        for (index, row) in result.rows.enumerated() {
            var x = bounds.minX
            for subviewIndex in row {
                let subview = subviews[subviewIndex]
                let size = subview.sizeThatFits(.unspecified)
                subview.place(
                    at: CGPoint(x: x, y: currentY),
                    proposal: .unspecified
                )
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

                rowHeights[currentRow] = max(
                    rowHeights[currentRow],
                    size.height
                )
                rows[currentRow].append(index)
                currentX += size.width + spacing
                maxRowWidth = max(maxRowWidth, currentX - spacing)
            }

            // Calculate total height
            let totalHeight =
                rowHeights.reduce(0, +) + CGFloat(max(0, rowHeights.count - 1))
                * spacing
            size = CGSize(width: maxRowWidth, height: totalHeight)
        }
    }
}

#Preview {
    NavigationStack {
        ResultView(
            store: Store(
                id: "bonchon",
                name: LocalizedName(th: "บอนชอน", en: "Bonchon Chicken"),
                displayName: "Bonchon Chicken",
                tags: ["korean", "chicken"],
                priceRange: .mid,
                location: StoreLocation(
                    floor: "5F",
                    zone: "Food Court",
                    unit: "A-12"
                ),
                detailUrl: "https://example.com",
                mapUrl: "https://maps.google.com",
                logoUrl: nil
            ),
            mall: Mall(
                mallId: "siam-paragon",
                name: LocalizedName(th: "สยามพารากอน", en: "Siam Paragon"),
                displayName: "สยามพารากอน",
                city: "Bangkok",
                assetKey: "mall_paragon",
                tags: ["bts"],
                logoUrl: nil
            ),
            showSpinAgain: true
        )
    }
    .environmentObject(AppEnvironment())
}
