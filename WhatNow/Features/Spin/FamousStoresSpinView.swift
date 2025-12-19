//
//  FamousStoresSpinView.swift
//  WhatNow
//
//  Famous Stores Spin View - Random selection from famous restaurants
//

import SwiftUI

struct FamousStoresSpinView: View {
    @StateObject private var viewModel: SpinViewModel
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @State private var hasAppeared = false

    init() {
        let config = SpinConfiguration(
            context: .famousRestaurant,
            title: LocalizedName(th: "ร้านดัง", en: "Famous Restaurants"),
            showSeeAllButton: true,
            filteringEnabled: false,  // No filtering for famous restaurants
            spinType: .famousRestaurant
        )
        _viewModel = StateObject(
            wrappedValue: SpinViewModel(configuration: config)
        )
    }

    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else if !viewModel.allItems.isEmpty {
                contentView
            }
        }
        .navigationTitle(
            "Famous Restaurants".localized(for: appEnvironment.currentLanguage)
        )
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showItemDetail) {
            itemDetailSheet
        }
        .sheet(isPresented: $viewModel.showItemList) {
            itemListSheet
        }
        .task {
            guard !hasAppeared else { return }
            hasAppeared = true
            await viewModel.loadItems()
        }
        .onAppear {
            if !viewModel.allItems.isEmpty {
                viewModel.reshuffleItems()
            }
        }
        .id(appEnvironment.languageDidChange)
        .withBannerAd(placement: .famousSpin)
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
                    await viewModel.loadItems()
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }

    private var contentView: some View {
        VStack(spacing: 16) {
            // Header
            SpinHeader(
                title: viewModel.displayTitle(
                    for: appEnvironment.currentLanguage
                ),
                subtitle: viewModel.displaySubtitle(
                    for: appEnvironment.currentLanguage
                ),
                filterCount: 0,
                hasActiveFilters: false,
                isDisabled: viewModel.filterControlsDisabled,
                showSeeAllButton: true,
                showFilterButton: false,  // No filter for famous restaurants
                onFilterTap: {},
                onSeeAllTap: { viewModel.openItemList() }
            )

            // Reel Picker
            if !viewModel.shuffledItems.isEmpty {
                ReelPicker(
                    items: viewModel.shuffledItems,
                    isSpinning: viewModel.isSpinning,
                    reelIndex: $viewModel.reelIndex
                )
                .padding(.vertical, 16)
                .id(viewModel.shuffledItems.map { $0.id }.joined())
            }

            // Spin Button
            SpinButton(
                isSpinning: viewModel.isSpinning,
                gradientRotation: viewModel.gradientRotation,
                isDisabled: !viewModel.canSpin,
                action: { viewModel.spin() }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .padding(.top, 24)
    }

    // MARK: - Sheet Views

    @ViewBuilder
    private var itemDetailSheet: some View {
        if let store = viewModel.selectedItem {
            NavigationStack {
                ResultView(
                    store: store,
                    mall: nil,  // Famous restaurants don't have a specific mall
                    suggestedMallNames: viewModel.getSuggestedMallNames(
                        for: store.id,
                        language: appEnvironment.currentLanguage
                    ),
                    showSpinAgain: true
                )
            }
        }
    }

    @ViewBuilder
    private var itemListSheet: some View {
        NavigationStack {
            ListView(
                stores: viewModel.allItems,
                mall: Mall(
                    mallId: "famous",
                    name: LocalizedName(th: "ร้านดัง", en: "Famous Restaurants"),
                    displayName: "Famous Restaurants",
                    city: "Bangkok",
                    assetKey: "famous",
                    tags: [],
                    logoUrl: nil
                )
            )
        }
    }
}

#Preview {
    NavigationStack {
        FamousStoresSpinView()
    }
    .environmentObject(AppEnvironment())
}
