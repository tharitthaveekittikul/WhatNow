//
//  SpinView.swift
//  WhatNow
//
//  Spin View - Pure presentation layer following MVVM
//

import SwiftUI

struct SpinView: View {
    @StateObject private var viewModel: SpinViewModel
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @State private var hasAppeared = false

    // MARK: - Initialization

    /// Initialize with a Mall (most common use case)
    init(mall: Mall) {
        let config = SpinConfiguration(
            context: .mall(mall),
            title: mall.name,
            showSeeAllButton: true,
            filteringEnabled: true,
            spinType: .mallStores
        )
        _viewModel = StateObject(wrappedValue: SpinViewModel(configuration: config))
    }

    /// Initialize with custom configuration (for future use cases)
    init(configuration: SpinConfiguration) {
        _viewModel = StateObject(wrappedValue: SpinViewModel(configuration: configuration))
    }

    // MARK: - Body

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
        .navigationTitle("Random Store".localized(for: appEnvironment.currentLanguage))
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
            // Re-shuffle items when view appears
            if !viewModel.allItems.isEmpty {
                viewModel.reshuffleItems()
            }
        }
        .onChange(of: viewModel.filter) { _ in
            // Re-apply filters and shuffle when filter changes (synchronous)
            viewModel.applyFiltersAndShuffle()
        }
        .id(appEnvironment.languageDidChange) // Refresh when language changes
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
            // Header with filter and see all buttons
            SpinHeader(
                title: viewModel.displayTitle(for: appEnvironment.currentLanguage),
                subtitle: viewModel.displaySubtitle(for: appEnvironment.currentLanguage),
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
                reelPickerView
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

    private var reelPickerView: some View {
        ReelPicker(
            items: viewModel.shuffledItems,
            isSpinning: viewModel.isSpinning,
            reelIndex: $viewModel.reelIndex
        )
        .padding(.vertical, 16)
        .id(viewModel.shuffledItems.map { $0.id }.joined()) // Force refresh when stores change
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("No stores match filters".localized(for: appEnvironment.currentLanguage))
                .font(.appTitle3)
                .foregroundColor(.App.text)
                .multilineTextAlignment(.center)

            Text("Try adjusting your filters".localized(for: appEnvironment.currentLanguage))
                .font(.appCallout)
                .foregroundColor(.App.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: CGFloat(5) * 80 + 32) // Match ReelPicker height
    }

    // MARK: - Sheet Views

    @ViewBuilder
    private var itemDetailSheet: some View {
        if let store = viewModel.selectedItem,
           case .mall(let mall) = viewModel.configuration.context {
            NavigationStack {
                StoreDetailView(store: store, mall: mall, showSpinAgain: true)
            }
        }
    }

    @ViewBuilder
    private var itemListSheet: some View {
        if case .mall(let mall) = viewModel.configuration.context {
            NavigationStack {
                StoreListView(stores: viewModel.allItems, mall: mall)
            }
        }
    }

    private var filterSheet: some View {
        FilterSheet(stores: viewModel.allItems, filter: $viewModel.filter)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SpinView(
            mall: Mall(
                mallId: "siam-paragon",
                name: LocalizedName(th: "สยามพารากอน", en: "Siam Paragon"),
                displayName: "สยามพารากอน",
                city: "Bangkok",
                assetKey: "mall_paragon",
                tags: ["bts", "tourist"]
            )
        )
    }
    .environmentObject(AppEnvironment())
}
