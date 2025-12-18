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

                VStack(spacing: 24) {
                    Spacer()

                    // Title
                    VStack(spacing: 8) {
                        Text("WhatNow".localized(for: appEnvironment.currentLanguage))
                            .font(.appLargeTitle)
                            .foregroundColor(.App.text)

                        Text("อะไรดี".localized(for: appEnvironment.currentLanguage))
                            .font(.appTitle3)
                            .foregroundColor(.App.textSecondary)
                    }

                    Spacer()

                    // Decision cards
                    VStack(spacing: 20) {
                        Button {
                            navigationPath.append(AppRoute.foodCategory)
                        } label: {
                            DecisionCardContent(
                                title: DecisionCategory.food.title(for: appEnvironment.currentLanguage),
                                emoji: DecisionCategory.food.emoji,
                                accentColor: .App.accentWarm
                            )
                        }
                        .buttonStyle(CardButtonStyle())

                        Button {
                            navigationPath.append(AppRoute.activityCategory)
                        } label: {
                            DecisionCardContent(
                                title: DecisionCategory.activity.title(for: appEnvironment.currentLanguage),
                                emoji: DecisionCategory.activity.emoji,
                                accentColor: .App.accentSky
                            )
                        }
                        .buttonStyle(CardButtonStyle())
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
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .foodCategory:
            FoodCategoryView()
        case .activityCategory:
            Text("Activities Coming Soon!".localized(for: appEnvironment.currentLanguage)).font(.appTitle)
        case .mallSelection:
            MallSelectionView()
        case .famousStores:
            Text("Famous Stores Coming Soon!".localized(for: appEnvironment.currentLanguage)).font(.appTitle)
        case .spin(let mall):
            SpinView(mall: mall)
        case .settings:
            SettingsView()
        }
    }
}

/// Card content without button wrapper (for use with NavigationLink)
struct DecisionCardContent: View {
    let title: String
    let emoji: String
    let accentColor: Color

    var body: some View {
        VStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 60))

            Text(title)
                .font(.appTitle2)
                .foregroundColor(.App.text)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(accentColor)
        )
    }
}

#Preview {
    HomeView()
}
