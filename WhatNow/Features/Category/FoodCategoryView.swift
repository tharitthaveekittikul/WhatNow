//
//  FoodCategoryView.swift
//  WhatNow
//
//  Food Category View - Mall and Famous Store selection
//

import SwiftUI

struct FoodCategoryView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment

    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Title
                Text("What to Eat?".localized(for: appEnvironment.currentLanguage))
                    .font(.appLargeTitle)
                    .foregroundColor(.App.text)

                Spacer()

                // Source type cards
                VStack(spacing: 20) {
                    NavigationLink(value: AppRoute.mallSelection) {
                        DecisionCardContent(
                            title: FoodSourceType.mall.title(for: appEnvironment.currentLanguage),
                            emoji: FoodSourceType.mall.emoji,
                            accentColor: .App.accentLavender
                        )
                    }
                    .buttonStyle(CardButtonStyle())

                    NavigationLink(value: AppRoute.famousStores) {
                        DecisionCardContent(
                            title: FoodSourceType.famous.title(for: appEnvironment.currentLanguage),
                            emoji: FoodSourceType.famous.emoji,
                            accentColor: .App.accentWarm
                        )
                    }
                    .buttonStyle(CardButtonStyle())
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationTitle("What to Eat?".localized(for: appEnvironment.currentLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .id(appEnvironment.languageDidChange) // Refresh when language changes
        .withBannerAd(placement: .foodCategory)
    }
}

#Preview {
    NavigationStack {
        FoodCategoryView()
    }
    .environmentObject(AppEnvironment())
}
