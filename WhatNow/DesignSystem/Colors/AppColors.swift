//
//  AppColors.swift
//  WhatNow
//
//  Design System - Cloudy Color Palette
//

import SwiftUI

/// Semantic color system for WhatNow app
/// Based on the Cloudy theme with adaptive light/dark mode support
extension Color {

    // MARK: - Light Mode Tokens

    /// #F4F7FB - CloudyLight - Lightest background
    static let cloudyLight = Color(hex: "F4F7FB")

    /// #E6EBF2 - CloudyPrimary - Primary background
    static let cloudyPrimary = Color(hex: "E6EBF2")

    /// #C9D3E1 - CloudyMedium - Medium surfaces
    static let cloudyMedium = Color(hex: "C9D3E1")

    /// #9AA8BF - CloudyDark - Dark accents
    static let cloudyDark = Color(hex: "9AA8BF")

    /// #FFFFFF - SurfacePrimary - Primary surface (cards, sheets)
    static let surfacePrimary = Color(hex: "FFFFFF")

    /// #EEF2F7 - SurfaceSoft - Soft surface
    static let surfaceSoft = Color(hex: "EEF2F7")

    /// #FFE6C7 - AccentWarm - Warm accent
    static let accentWarm = Color(hex: "FFE6C7")

    /// #DDEBFF - AccentSky - Sky accent
    static let accentSky = Color(hex: "DDEBFF")

    /// #EDE7F6 - AccentLavender - Lavender accent
    static let accentLavender = Color(hex: "EDE7F6")

    /// #2B3440 - TextPrimary - Primary text
    static let textPrimary = Color(hex: "2B3440")

    /// #6B7280 - TextSecondary - Secondary text
    static let textSecondary = Color(hex: "6B7280")

    /// #9CA3AF - TextTertiary - Tertiary text
    static let textTertiary = Color(hex: "9CA3AF")

    // MARK: - Dark Mode Tokens

    /// #1E2430 - CloudyLightDark
    static let cloudyLightDark = Color(hex: "1E2430")

    /// #252C3A - CloudyPrimaryDark
    static let cloudyPrimaryDark = Color(hex: "252C3A")

    /// #2F3748 - CloudyMediumDark
    static let cloudyMediumDark = Color(hex: "2F3748")

    /// #3B465C - CloudyDarkDark
    static let cloudyDarkDark = Color(hex: "3B465C")

    /// #1B202B - SurfacePrimaryDark
    static let surfacePrimaryDark = Color(hex: "1B202B")

    /// #242B38 - SurfaceSoftDark
    static let surfaceSoftDark = Color(hex: "242B38")

    /// #5A4630 - AccentWarmDark
    static let accentWarmDark = Color(hex: "5A4630")

    /// #3A4C6A - AccentSkyDark
    static let accentSkyDark = Color(hex: "3A4C6A")

    /// #4A3F5E - AccentLavenderDark
    static let accentLavenderDark = Color(hex: "4A3F5E")

    /// #E5E9F0 - TextPrimaryDark
    static let textPrimaryDark = Color(hex: "E5E9F0")

    /// #B6BDC9 - TextSecondaryDark
    static let textSecondaryDark = Color(hex: "B6BDC9")

    /// #8A93A3 - TextTertiaryDark
    static let textTertiaryDark = Color(hex: "8A93A3")

    // MARK: - Semantic Colors (Adaptive)

    struct App {
        /// Background - Primary
        static let background = Color(
            light: .cloudyLight,
            dark: .cloudyLightDark
        )

        /// Background - Secondary
        static let backgroundSecondary = Color(
            light: .cloudyPrimary,
            dark: .cloudyPrimaryDark
        )

        /// Surface - Primary (cards)
        static let surface = Color(
            light: .surfacePrimary,
            dark: .surfacePrimaryDark
        )

        /// Surface - Soft
        static let surfaceSoft = Color(
            light: Color.surfaceSoft,
            dark: .surfaceSoftDark
        )

        /// Accent - Warm
        static let accentWarm = Color(
            light: Color.accentWarm,
            dark: .accentWarmDark
        )

        /// Accent - Sky
        static let accentSky = Color(
            light: Color.accentSky,
            dark: .accentSkyDark
        )

        /// Accent - Lavender
        static let accentLavender = Color(
            light: Color.accentLavender,
            dark: .accentLavenderDark
        )

        /// Text - Primary
        static let text = Color(
            light: .textPrimary,
            dark: .textPrimaryDark
        )

        /// Text - Secondary
        static let textSecondary = Color(
            light: Color.textSecondary,
            dark: .textSecondaryDark
        )

        /// Text - Tertiary
        static let textTertiary = Color(
            light: Color.textTertiary,
            dark: .textTertiaryDark
        )

        /// Divider
        static let divider = Color(
            light: .cloudyMedium,
            dark: Color.white.opacity(0.06)
        )
    }

    // MARK: - Utility

    /// Helper for creating colors from hex strings
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Helper for creating adaptive colors (light/dark mode)
    init(light: Color, dark: Color) {
        self.init(
            UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(dark)
                default:
                    return UIColor(light)
                }
            }
        )
    }
}
