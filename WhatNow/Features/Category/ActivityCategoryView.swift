//
//  ActivityCategoryView.swift
//  WhatNow
//
//  Activity Category View - Activity type selection
//

import SwiftUI

struct ActivityCategoryView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment

    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Title
                Text("What to Do?".localized(for: appEnvironment.currentLanguage))
                    .font(.appLargeTitle)
                    .foregroundColor(.App.text)

                Spacer()

                // Activity type cards
                VStack(spacing: 20) {
                    ForEach(ActivitySourceType.allCases) { activityType in
                        NavigationLink(value: AppRoute.activitySpin(type: activityType)) {
                            DecisionCardContent(
                                title: activityType.title(for: appEnvironment.currentLanguage),
                                emoji: activityType.emoji,
                                accentColor: accentColorFor(activityType)
                            )
                        }
                        .buttonStyle(CardButtonStyle())
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationTitle("What to Do?".localized(for: appEnvironment.currentLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .id(appEnvironment.languageDidChange) // Refresh when language changes
    }

    private func accentColorFor(_ type: ActivitySourceType) -> Color {
        switch type {
        case .indoor:
            return Color.App.accentLavender
        case .outdoor:
            return Color.App.accentSky
        case .entertainment:
            return Color.App.accentWarm
        }
    }
}

#Preview {
    NavigationStack {
        ActivityCategoryView()
    }
    .environmentObject(AppEnvironment())
}
