//
//  HomeView.swift
//  WhatNow
//
//  Home View - Main decision screen
//

import SwiftUI

struct HomeView: View {
    @State private var navigationPath = NavigationPath()
    @EnvironmentObject private var appEnvironment: AppEnvironment

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.App.background
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Title
                    VStack(spacing: 8) {
                        Text("WhatNow".localized(for: appEnvironment.currentLanguage))
                            .font(.appLargeTitle)
                            .foregroundColor(.App.text)

                        Text("อะไรดี".localized(for: appEnvironment.currentLanguage))
                            .font(.appTitle3)
                            .foregroundColor(.App.textSecondary)
                    }
                    .padding(.top, 24)

                    Spacer()

                    // Decision cards in grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        DecisionCard(
                            title: DecisionCategory.food.title(for: appEnvironment.currentLanguage),
                            emoji: DecisionCategory.food.emoji,
                            accentColor: .App.accentWarm
                        ) {
                            navigationPath.append(AppRoute.foodCategory)
                        }

                        DecisionCard(
                            title: DecisionCategory.activity.title(for: appEnvironment.currentLanguage),
                            emoji: DecisionCategory.activity.emoji,
                            accentColor: .App.accentSky
                        ) {
                            navigationPath.append(AppRoute.activityCategory)
                        }

                        DecisionCard(
                            title: DecisionCategory.customSpin.title(for: appEnvironment.currentLanguage),
                            emoji: DecisionCategory.customSpin.emoji,
                            accentColor: .App.accentLavender
                        ) {
                            navigationPath.append(AppRoute.customSpinList)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                destinationView(for: route)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        navigationPath.append(AppRoute.settings)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.App.text)
                    }
                }
            }
            .id(appEnvironment.languageDidChange) // Refresh when language changes
            .withBannerAd(placement: .home)
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .foodCategory:
            FoodCategoryView()
        case .activityCategory:
            ActivityCategoryView()
        case .mallSelection:
            MallSelectionView()
        case .famousStores:
            FamousStoresSpinView()
        case .activitySpin(let category):
            ActivitySpinView(category: category)
        case .spin(let mall):
            SpinView(mall: mall)
        case .customSpinList:
            CustomSpinListView()
        case .customSpinEditor(let list):
            CustomSpinEditorView(list: list)
        case .customSpin(let list):
            CustomSpinView(list: list)
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppEnvironment())
}
