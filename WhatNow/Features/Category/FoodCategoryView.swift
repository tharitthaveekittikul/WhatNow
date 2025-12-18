//
//  FoodCategoryView.swift
//  WhatNow
//
//  Food Category View - Mall and Famous Store selection
//

import SwiftUI

struct FoodCategoryView: View {
    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Title
                Text("What to Eat?", bundle: .main, comment: "Food category title")
                    .font(.appLargeTitle)
                    .foregroundColor(.App.text)

                Spacer()

                // Source type cards
                VStack(spacing: 20) {
                    NavigationLink(value: AppRoute.mallSelection) {
                        DecisionCardContent(
                            title: FoodSourceType.mall.title,
                            emoji: FoodSourceType.mall.emoji,
                            accentColor: .App.accentLavender
                        )
                    }
                    .buttonStyle(CardButtonStyle())

                    NavigationLink(value: AppRoute.famousStores) {
                        DecisionCardContent(
                            title: FoodSourceType.famous.title,
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
        .navigationTitle(String(localized: "What to Eat?"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FoodCategoryView()
    }
}
