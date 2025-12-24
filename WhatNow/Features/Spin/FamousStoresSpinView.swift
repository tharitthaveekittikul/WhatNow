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
            filteringEnabled: true,
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
        .sheet(isPresented: $viewModel.showFilterSheet) {
            filterSheet
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
        .onChange(of: viewModel.filter) { _ in
            viewModel.applyFiltersAndShuffle()
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
                filterCount: viewModel.activeFilterCount,
                hasActiveFilters: viewModel.hasActiveFilters,
                isDisabled: viewModel.filterControlsDisabled,
                showSeeAllButton: true,
                showFilterButton: true,
                onFilterTap: { viewModel.openFilterSheet() },
                onSeeAllTap: { viewModel.openItemList() }
            )

            // Active filter chips
            FilterChipsView(
                filter: viewModel.filter,
                onRemoveCategory: { viewModel.removeCategory($0) },
                onRemovePriceRange: { viewModel.removePriceRange($0) },
                onClearAll: { viewModel.clearAllFilters() }
            )
            .opacity(viewModel.filterControlsDisabled ? 0.5 : 1.0)

            // Reel Picker or empty state
            if !viewModel.shuffledItems.isEmpty {
                ReelPicker(
                    items: viewModel.shuffledItems,
                    isSpinning: viewModel.isSpinning,
                    reelIndex: $viewModel.reelIndex
                )
                .padding(.vertical, 16)
                .id(viewModel.shuffledItems.map { $0.id }.joined())
            } else {
                emptyStateView
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

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text(
                "No stores match filters".localized(
                    for: appEnvironment.currentLanguage
                )
            )
            .font(.appTitle3)
            .foregroundColor(.App.text)
            .multilineTextAlignment(.center)

            Text(
                "Try adjusting your filters".localized(
                    for: appEnvironment.currentLanguage
                )
            )
            .font(.appCallout)
            .foregroundColor(.App.textSecondary)
            .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: CGFloat(5) * 80 + 32)
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

    private var filterSheet: some View {
        FilterSheet(stores: viewModel.allItems, filter: $viewModel.filter)
    }
}

#Preview {
    NavigationStack {
        FamousStoresSpinView()
    }
    .environmentObject(AppEnvironment())
}
