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

            VStack(spacing: 16) {
                // Title
                Text(
                    "What to Eat?".localized(
                        for: appEnvironment.currentLanguage
                    )
                )
                .font(.appLargeTitle)
                .foregroundColor(.App.text)
                .padding(.top, 24)

                Spacer()
                    .frame(height: 24)

                // Source type cards in grid
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 12
                ) {
                    NavigationLink(value: AppRoute.mallSelection) {
                        VStack(spacing: 12) {
                            Text(FoodSourceType.mall.emoji)
                                .font(.system(size: 48))

                            Text(
                                FoodSourceType.mall.title(
                                    for: appEnvironment.currentLanguage
                                )
                            )
                            .font(.appCallout)
                            .foregroundColor(.App.text)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 110)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 16,
                                style: .continuous
                            )
                            .fill(Color.App.accentLavender.opacity(0.6))
                        )
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: 16,
                                style: .continuous
                            )
                            .stroke(
                                Color.App.accentLavender.opacity(0.4),
                                lineWidth: 1
                            )
                        )
                    }
                    .buttonStyle(CardButtonStyle())

                    NavigationLink(value: AppRoute.famousStores) {
                        VStack(spacing: 12) {
                            Text(FoodSourceType.famous.emoji)
                                .font(.system(size: 48))

                            Text(
                                FoodSourceType.famous.title(
                                    for: appEnvironment.currentLanguage
                                )
                            )
                            .font(.appCallout)
                            .foregroundColor(.App.text)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 110)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 16,
                                style: .continuous
                            )
                            .fill(Color.App.accentWarm.opacity(0.6))
                        )
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: 16,
                                style: .continuous
                            )
                            .stroke(
                                Color.App.accentWarm.opacity(0.4),
                                lineWidth: 1
                            )
                        )
                    }
                    .buttonStyle(CardButtonStyle())
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        //        .navigationTitle("What to Eat?".localized(for: appEnvironment.currentLanguage))
        //        .navigationBarTitleDisplayMode(.inline)
        .id(appEnvironment.languageDidChange)  // Refresh when language changes
        .withBannerAd(placement: .foodCategory)
    }
}

#Preview {
    NavigationStack {
        FoodCategoryView()
    }
    .environmentObject(AppEnvironment())
}
