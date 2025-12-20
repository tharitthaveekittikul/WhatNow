//
//  ActivityCategoryView.swift
//  WhatNow
//
//  Activity Category View - Activity type selection
//

import SwiftUI

struct ActivityCategoryView: View {
    @StateObject private var viewModel = ActivityCategoryViewModel()
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @State private var hasAppeared = false

    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else {
                contentView
            }
        }
        .navigationTitle("What to Do?".localized(for: appEnvironment.currentLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .id(appEnvironment.languageDidChange) // Refresh when language changes
        .task {
            guard !hasAppeared else { return }
            hasAppeared = true
            await viewModel.loadCategories()
        }
        .withBannerAd(placement: .activityCategory)
    }

    // MARK: - Subviews

    private var loadingView: some View {
        ProgressView()
            .tint(.App.text)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Text("Error".localized(for: appEnvironment.currentLanguage))
                .font(.appTitle2)
                .foregroundColor(.App.text)

            Text(message)
                .font(.appBody)
                .foregroundColor(.App.textSecondary)
                .multilineTextAlignment(.center)

            Button("Try Again".localized(for: appEnvironment.currentLanguage)) {
                Task {
                    await viewModel.loadCategories()
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }

    private var contentView: some View {
        VStack(spacing: 16) {
            // Title
            Text("What to Do?".localized(for: appEnvironment.currentLanguage))
                .font(.appLargeTitle)
                .foregroundColor(.App.text)
                .padding(.top, 24)

            Spacer()

            // Activity category cards in grid (from API)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.categories) { category in
                    NavigationLink(value: AppRoute.activitySpin(category: category)) {
                        VStack(spacing: 12) {
                            Text(viewModel.emoji(for: category))
                                .font(.system(size: 48))

                            Text(appEnvironment.currentLanguage == .thai ? category.nameTH : category.nameEN)
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
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(viewModel.accentColor(for: category).opacity(0.6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(viewModel.accentColor(for: category).opacity(0.4), lineWidth: 1)
                        )
                    }
                    .buttonStyle(CardButtonStyle())
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        ActivityCategoryView()
    }
    .environmentObject(AppEnvironment())
}
