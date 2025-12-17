//
//  AppTypography.swift
//  WhatNow
//
//  Design System - Typography
//  SF Pro Rounded with Dynamic Type support
//

import SwiftUI

/// Typography system for WhatNow app
/// Uses SF Pro Rounded with semantic styles
extension Font {

    // MARK: - Display

    /// Large title - 34pt rounded
    static let appLargeTitle = Font.system(size: 34, weight: .bold, design: .rounded)

    /// Title 1 - 28pt rounded
    static let appTitle = Font.system(size: 28, weight: .bold, design: .rounded)

    /// Title 2 - 22pt rounded
    static let appTitle2 = Font.system(size: 22, weight: .semibold, design: .rounded)

    /// Title 3 - 20pt rounded
    static let appTitle3 = Font.system(size: 20, weight: .semibold, design: .rounded)

    // MARK: - Body

    /// Headline - 17pt rounded semibold
    static let appHeadline = Font.system(size: 17, weight: .semibold, design: .rounded)

    /// Body - 17pt rounded regular
    static let appBody = Font.system(size: 17, weight: .regular, design: .rounded)

    /// Callout - 16pt rounded regular
    static let appCallout = Font.system(size: 16, weight: .regular, design: .rounded)

    /// Subheadline - 15pt rounded regular
    static let appSubheadline = Font.system(size: 15, weight: .regular, design: .rounded)

    /// Footnote - 13pt rounded regular
    static let appFootnote = Font.system(size: 13, weight: .regular, design: .rounded)

    /// Caption 1 - 12pt rounded regular
    static let appCaption = Font.system(size: 12, weight: .regular, design: .rounded)

    /// Caption 2 - 11pt rounded regular
    static let appCaption2 = Font.system(size: 11, weight: .regular, design: .rounded)
}

/// Text styles with semantic meaning
extension Text {

    /// Apply large title style
    func largeTitleStyle() -> some View {
        self
            .font(.appLargeTitle)
            .foregroundColor(.App.text)
    }

    /// Apply title style
    func titleStyle() -> some View {
        self
            .font(.appTitle)
            .foregroundColor(.App.text)
    }

    /// Apply title 2 style
    func title2Style() -> some View {
        self
            .font(.appTitle2)
            .foregroundColor(.App.text)
    }

    /// Apply headline style
    func headlineStyle() -> some View {
        self
            .font(.appHeadline)
            .foregroundColor(.App.text)
    }

    /// Apply body style
    func bodyStyle() -> some View {
        self
            .font(.appBody)
            .foregroundColor(.App.text)
    }

    /// Apply secondary text style
    func secondaryStyle() -> some View {
        self
            .font(.appBody)
            .foregroundColor(.App.textSecondary)
    }

    /// Apply tertiary text style
    func tertiaryStyle() -> some View {
        self
            .font(.appCallout)
            .foregroundColor(.App.textTertiary)
    }

    /// Apply caption style
    func captionStyle() -> some View {
        self
            .font(.appCaption)
            .foregroundColor(.App.textSecondary)
    }
}
