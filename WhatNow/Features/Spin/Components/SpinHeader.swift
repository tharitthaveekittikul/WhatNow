//
//  SpinHeader.swift
//  WhatNow
//
//  Reusable header component for Spin view with filter and see all buttons
//

import SwiftUI

struct SpinHeader: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment

    let title: String
    let subtitle: String
    let filterCount: Int
    let hasActiveFilters: Bool
    let isDisabled: Bool
    let showSeeAllButton: Bool
    let showFilterButton: Bool
    let onFilterTap: () -> Void
    let onSeeAllTap: () -> Void

    var body: some View {
        HStack {
            // Filter button
            if showFilterButton {
                Button(action: onFilterTap) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(hasActiveFilters ? Color.App.accentSky : .App.text)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.App.surface)
                            )

                        // Filter count badge
                        if filterCount > 0 {
                            FilterBadge(count: filterCount)
                                .offset(x: 6, y: -6)
                        }
                    }
                }
                .disabled(isDisabled)
            }

            Spacer()

            // Title and subtitle
            VStack(spacing: 8) {
                Text(title)
                    .font(.appTitle2)
                    .foregroundColor(.App.text)

                Text(subtitle)
                    .font(hasActiveFilters ? .appCaption : .appCallout)
                    .foregroundColor(hasActiveFilters ? Color.App.accentSky : .App.textSecondary)
            }

            Spacer()

            // See All button
            if showSeeAllButton {
                Button(action: onSeeAllTap) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.App.text)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.App.surface)
                        )
                }
                .disabled(isDisabled)
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    VStack(spacing: 32) {
        SpinHeader(
            title: "Siam Paragon",
            subtitle: "120 stores",
            filterCount: 0,
            hasActiveFilters: false,
            isDisabled: false,
            showSeeAllButton: true,
            showFilterButton: true,
            onFilterTap: {},
            onSeeAllTap: {}
        )

        SpinHeader(
            title: "Siam Paragon",
            subtitle: "45 / 120 stores",
            filterCount: 3,
            hasActiveFilters: true,
            isDisabled: false,
            showSeeAllButton: true,
            showFilterButton: true,
            onFilterTap: {},
            onSeeAllTap: {}
        )

        SpinHeader(
            title: "Famous Restaurants",
            subtitle: "50 restaurants",
            filterCount: 0,
            hasActiveFilters: false,
            isDisabled: false,
            showSeeAllButton: true,
            showFilterButton: false,
            onFilterTap: {},
            onSeeAllTap: {}
        )
    }
    .padding()
    .background(Color.App.background)
    .environmentObject(AppEnvironment())
}
