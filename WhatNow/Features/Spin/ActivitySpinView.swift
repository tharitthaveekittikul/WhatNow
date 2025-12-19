//
//  ActivitySpinView.swift
//  WhatNow
//
//  Activity Spin View - Random selection from activities
//

import SwiftUI

struct ActivitySpinView: View {
    let category: ActivityCategory
    @StateObject private var viewModel: SpinViewModel
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @State private var hasAppeared = false

    init(category: ActivityCategory) {
        self.category = category
        let config = SpinConfiguration(
            context: .activity(category: category.id),
            title: LocalizedName(
                th: category.nameTH,
                en: category.nameEN
            ),
            showSeeAllButton: true,
            filteringEnabled: false,  // No filtering for activities (can be enabled later)
            spinType: .activity
        )
        _viewModel = StateObject(wrappedValue: SpinViewModel(configuration: config))
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
        .navigationTitle(appEnvironment.currentLanguage == .thai ? category.nameTH : category.nameEN)
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
                title: appEnvironment.currentLanguage == .thai ? category.nameTH : category.nameEN,
                subtitle: viewModel.displaySubtitle(for: appEnvironment.currentLanguage),
                filterCount: 0,
                hasActiveFilters: false,
                isDisabled: viewModel.filterControlsDisabled,
                showSeeAllButton: true,
                showFilterButton: false,  // No filter for activities
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
                StoreDetailView(
                    store: store,
                    mall: Mall(
                        mallId: "activity-\(category.id)",
                        name: LocalizedName(
                            th: category.nameTH,
                            en: category.nameEN
                        ),
                        displayName: category.nameEN,
                        city: "Bangkok",
                        assetKey: category.assetKey ?? "activity",
                        tags: []
                    ),
                    showSpinAgain: true
                )
            }
        }
    }

    @ViewBuilder
    private var itemListSheet: some View {
        NavigationStack {
            StoreListView(
                stores: viewModel.allItems,
                mall: Mall(
                    mallId: "activity-\(category.id)",
                    name: LocalizedName(
                        th: category.nameTH,
                        en: category.nameEN
                    ),
                    displayName: category.nameEN,
                    city: "Bangkok",
                    assetKey: category.assetKey ?? "activity",
                    tags: []
                )
            )
        }
    }
}

#Preview {
    NavigationStack {
        ActivitySpinView(
            category: ActivityCategory(
                id: "indoor-activities",
                nameTH: "กิจกรรมในร่ม",
                nameEN: "Indoor Activities",
                assetKey: "indoor"
            )
        )
    }
    .environmentObject(AppEnvironment())
}
