//
//  DesignSystemShowcase.swift
//  WhatNow
//
//  Created by Tharit Thaveekittikul on 12/19/25.
//

import SwiftUI

/// Design System Showcase
/// Preview all semantic colors + typography + key UI components in both Light/Dark
struct DesignSystemShowcase: View {
    var body: some View {
        ShowcaseContainer {
            VStack(spacing: 16) {
                headerSection
                typographySection
                componentsSection
                colorsSection
            }
            .padding(20)
        }
    }
}

// MARK: - Container (uses semantic background)
private struct ShowcaseContainer<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Color.App.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                content
            }
        }
    }
}

// MARK: - Sections
private extension DesignSystemShowcase {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                iconBadge(systemName: "sparkles")

                VStack(alignment: .leading, spacing: 2) {
                    Text("WhatNow Design System")
                        .titleStyle()

                    Text("Cloudy Theme • Showcase")
                        .secondaryStyle()
                }

                Spacer()

                pill("v1", fill: Color.App.accentSky, textColor: Color.App.text)
            }

            Divider().overlay(Color.App.divider)
        }
    }

    var typographySection: some View {
        sectionCard(title: "Typography") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Large Title – App Hero")
                    .largeTitleStyle()

                Text("Title – Screen Title")
                    .titleStyle()

                Text("Title 2 – Section Title")
                    .title2Style()

                Text("Title 3 – Subsection Title")
                    .font(.appTitle3)
                    .foregroundColor(.App.text)

                Text("Headline – Card / List Title")
                    .headlineStyle()

                Text("Body – Main content text used throughout the app.")
                    .bodyStyle()

                Text("Secondary – Supporting information or description.")
                    .secondaryStyle()

                Text("Tertiary – Hint, metadata, timestamp.")
                    .tertiaryStyle()

                Text("Caption – Tags, footnotes")
                    .captionStyle()
            }
        }
    }

    var componentsSection: some View {
        sectionCard(title: "Components") {
            VStack(spacing: 14) {

                // Buttons
                HStack(spacing: 10) {
                    appButton(
                        "Primary",
                        icon: "dice.fill",
                        fill: Color.App.accentWarm,
                        text: Color.App.text
                    )

                    appButton(
                        "Secondary",
                        icon: "sparkles",
                        fill: Color.App.accentSky,
                        text: Color.App.text
                    )
                }

                HStack(spacing: 10) {
                    appButton(
                        "Neutral",
                        icon: "square.grid.2x2",
                        fill: Color.App.surfaceSoft,
                        text: Color.App.text
                    )

                    appButton(
                        "Ghost",
                        icon: "chevron.right",
                        fill: .clear,
                        text: Color.App.textSecondary,
                        border: Color.App.divider
                    )
                }

                // Cards
                HStack(spacing: 12) {
                    miniCard(
                        title: "Card Title",
                        subtitle: "Surface",
                        icon: "fork.knife",
                        iconFill: Color.App.accentLavender
                    )

                    miniCard(
                        title: "Info",
                        subtitle: "Soft Surface",
                        icon: "map",
                        iconFill: Color.App.accentSky
                    )
                }

                // Chips / Tags
                HStack(spacing: 8) {
                    pill("cafe", fill: Color.App.accentLavender, textColor: Color.App.text)
                    pill("dessert", fill: Color.App.accentWarm, textColor: Color.App.text)
                    pill("thai", fill: Color.App.surfaceSoft, textColor: Color.App.textSecondary)
                    Spacer()
                }

                // List row sample
                VStack(spacing: 10) {
                    listRow(title: "Somtam Nua", subtitle: "Thai • mid", icon: "leaf")
                    Divider().overlay(Color.App.divider)
                    listRow(title: "After You", subtitle: "Cafe • dessert", icon: "cup.and.saucer")
                }
            }
        }
    }

    var colorsSection: some View {
        VStack(spacing: 12) {
            sectionTitle("Semantic Colors (Use these in UI)")
            swatchGrid(items: [
                .init(name: "App.background", color: Color.App.background, usage: "App background"),
                .init(name: "App.backgroundSecondary", color: Color.App.backgroundSecondary, usage: "Secondary bg"),
                .init(name: "App.surface", color: Color.App.surface, usage: "Cards/sheets"),
                .init(name: "App.surfaceSoft", color: Color.App.surfaceSoft, usage: "Soft containers"),
                .init(name: "App.accentWarm", color: Color.App.accentWarm, usage: "Primary CTA / highlight"),
                .init(name: "App.accentSky", color: Color.App.accentSky, usage: "Secondary CTA / info"),
                .init(name: "App.accentLavender", color: Color.App.accentLavender, usage: "Decor / tag"),
                .init(name: "App.text", color: Color.App.text, usage: "Main text"),
                .init(name: "App.textSecondary", color: Color.App.textSecondary, usage: "Supporting text"),
                .init(name: "App.textTertiary", color: Color.App.textTertiary, usage: "Hints/meta"),
                .init(name: "App.divider", color: Color.App.divider, usage: "Dividers/strokes")
            ])

            sectionTitle("Raw Tokens (Reference only)")
            swatchGrid(items: [
                .init(name: "cloudyLight", color: .cloudyLight, usage: "token"),
                .init(name: "cloudyPrimary", color: .cloudyPrimary, usage: "token"),
                .init(name: "cloudyMedium", color: .cloudyMedium, usage: "token"),
                .init(name: "cloudyDark", color: .cloudyDark, usage: "token"),
                .init(name: "surfacePrimary", color: .surfacePrimary, usage: "token"),
                .init(name: "surfaceSoft", color: .surfaceSoft, usage: "token"),
                .init(name: "accentWarm", color: .accentWarm, usage: "token"),
                .init(name: "accentSky", color: .accentSky, usage: "token"),
                .init(name: "accentLavender", color: .accentLavender, usage: "token"),
                .init(name: "textPrimary", color: .textPrimary, usage: "token"),
                .init(name: "textSecondary", color: .textSecondary, usage: "token"),
                .init(name: "textTertiary", color: .textTertiary, usage: "token"),

                .init(name: "cloudyLightDark", color: .cloudyLightDark, usage: "token"),
                .init(name: "cloudyPrimaryDark", color: .cloudyPrimaryDark, usage: "token"),
                .init(name: "cloudyMediumDark", color: .cloudyMediumDark, usage: "token"),
                .init(name: "cloudyDarkDark", color: .cloudyDarkDark, usage: "token"),
                .init(name: "surfacePrimaryDark", color: .surfacePrimaryDark, usage: "token"),
                .init(name: "surfaceSoftDark", color: .surfaceSoftDark, usage: "token"),
                .init(name: "accentWarmDark", color: .accentWarmDark, usage: "token"),
                .init(name: "accentSkyDark", color: .accentSkyDark, usage: "token"),
                .init(name: "accentLavenderDark", color: .accentLavenderDark, usage: "token"),
                .init(name: "textPrimaryDark", color: .textPrimaryDark, usage: "token"),
                .init(name: "textSecondaryDark", color: .textSecondaryDark, usage: "token"),
                .init(name: "textTertiaryDark", color: .textTertiaryDark, usage: "token"),
            ])
        }
    }
}

// MARK: - Building blocks
private extension DesignSystemShowcase {

    func sectionCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.appTitle3)
                .foregroundColor(.App.text)

            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.App.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.App.divider, lineWidth: 1)
        )
    }

    func sectionTitle(_ text: String) -> some View {
        HStack {
            Text(text)
                .title2Style()
            Spacer()
        }
        .padding(.top, 4)
    }

    func iconBadge(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.appHeadline)
            .foregroundColor(.App.text)
            .frame(width: 34, height: 34)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.App.surfaceSoft)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.App.divider, lineWidth: 1)
            )
    }

    func appButton(_ title: String, icon: String, fill: Color, text: Color, border: Color? = nil) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.appCallout.weight(.semibold))

            Text(title)
                .font(.appCallout.weight(.semibold))
        }
        .foregroundColor(text)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(fill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(border ?? .clear, lineWidth: border == nil ? 0 : 1)
        )
    }

    func pill(_ text: String, fill: Color, textColor: Color) -> some View {
        Text(text)
            .font(.appCaption.weight(.semibold))
            .foregroundColor(textColor)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Capsule().fill(fill))
    }

    func miniCard(title: String, subtitle: String, icon: String, iconFill: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.appHeadline)
                .foregroundColor(.App.text)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(iconFill)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .headlineStyle()

                Text(subtitle)
                    .captionStyle()
            }

            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.App.surfaceSoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.App.divider, lineWidth: 1)
        )
    }

    func listRow(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 12) {
            iconBadge(systemName: icon)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .headlineStyle()

                Text(subtitle)
                    .captionStyle()
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.appCaption.weight(.semibold))
                .foregroundColor(.App.textTertiary)
        }
    }

    // MARK: - Swatches
    struct SwatchItem: Identifiable {
        let id = UUID()
        let name: String
        let color: Color
        let usage: String
    }

    func swatchGrid(items: [SwatchItem]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 165), spacing: 12)], spacing: 12) {
            ForEach(items) { item in
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(item.color)
                        .frame(height: 46)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.App.divider, lineWidth: 1)
                        )

                    Text(item.name)
                        .font(.appCaption.weight(.semibold))
                        .foregroundColor(.App.text)

                    Text(item.usage)
                        .font(.appCaption2)
                        .foregroundColor(.App.textSecondary)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.App.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.App.divider, lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Previews (Light & Dark)
#Preview("DesignSystem • Light") {
    DesignSystemShowcase()
        .preferredColorScheme(.light)
}

#Preview("DesignSystem • Dark") {
    DesignSystemShowcase()
        .preferredColorScheme(.dark)
}
