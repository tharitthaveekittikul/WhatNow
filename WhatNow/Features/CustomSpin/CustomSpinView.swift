//
//  CustomSpinView.swift
//  WhatNow
//
//  Custom Spin View - Spin through custom user items
//

import SwiftUI

struct CustomSpinView: View {
    @StateObject private var viewModel: CustomSpinViewModel
    @EnvironmentObject private var appEnvironment: AppEnvironment

    init(list: CustomSpinList) {
        _viewModel = StateObject(wrappedValue: CustomSpinViewModel(list: list))
    }

    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            if viewModel.items.isEmpty {
                emptyStateView
            } else {
                contentView
            }
        }
        //        .navigationTitle(viewModel.list.name)
        //        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    value: AppRoute.customSpinEditor(list: viewModel.list)
                ) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.App.text)
                }
            }
        }
        .sheet(isPresented: $viewModel.showResult) {
            resultSheet
        }
        .onAppear {
            viewModel.reshuffleItems()
        }
        .id(appEnvironment.languageDidChange)
        .withBannerAd(placement: .customSpin)
    }

    private var contentView: some View {
        VStack(spacing: 8) {
            // Header
            VStack(spacing: 8) {
                Text(viewModel.list.emoji)
                    .font(.system(size: 60))

                Text(viewModel.list.name)
                    .font(.appTitle2)
                    .foregroundColor(.App.text)

                Text(
                    "\(viewModel.items.count) items".localized(
                        for: appEnvironment.currentLanguage
                    )
                )
                .font(.appCallout)
                .foregroundColor(.App.textSecondary)
            }
        
            // Reel Picker
            ReelPicker(
                items: viewModel.items,
                isSpinning: viewModel.isSpinning,
                reelIndex: $viewModel.reelIndex
            )


            // Spin Button
            SpinButton(
                isSpinning: viewModel.isSpinning,
                gradientRotation: viewModel.gradientRotation,
                isDisabled: false,
                action: { viewModel.spin() }
            )
            .padding(.horizontal, 24)
            .padding(.bottom)

        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("No Items".localized(for: appEnvironment.currentLanguage))
                .font(.appTitle2)
                .foregroundColor(.App.text)

            Text(
                "Add items to start spinning".localized(
                    for: appEnvironment.currentLanguage
                )
            )
            .font(.appBody)
            .foregroundColor(.App.textSecondary)
            .multilineTextAlignment(.center)

            NavigationLink(
                value: AppRoute.customSpinEditor(list: viewModel.list)
            ) {
                Text("Edit List".localized(for: appEnvironment.currentLanguage))
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxWidth: 280)
        }
        .padding()
    }

    @ViewBuilder
    private var resultSheet: some View {
        if let selectedItem = viewModel.selectedItem {
            NavigationStack {
                CustomSpinResultView(
                    item: selectedItem,
                    listEmoji: viewModel.list.emoji,
                    onSpinAgain: {
                        viewModel.showResult = false
                        viewModel.reshuffleItems()
                    }
                )
            }
        }
    }
}

// MARK: - Custom Spin Result View

struct CustomSpinResultView: View {
    let item: CustomSpinItem
    let listEmoji: String
    let onSpinAgain: () -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appEnvironment: AppEnvironment

    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Result emoji and text
                VStack(spacing: 24) {
                    Text(listEmoji)
                        .font(.system(size: 120))

                    Text(item.text)
                        .font(.appLargeTitle)
                        .foregroundColor(.App.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                // Action buttons
                VStack(spacing: 16) {
                    Button {
                        dismiss()
                        onSpinAgain()
                    } label: {
                        Text(
                            "Spin Again".localized(
                                for: appEnvironment.currentLanguage
                            )
                        )
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button {
                        dismiss()
                    } label: {
                        Text(
                            "Done".localized(
                                for: appEnvironment.currentLanguage
                            )
                        )
                        .font(.appHeadline)
                        .foregroundColor(.App.textSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.App.textSecondary)
                }
            }
        }
        .id(appEnvironment.languageDidChange)
        .withBannerAd(placement: .customSpinResult)
    }
}

#Preview {
    NavigationStack {
        CustomSpinView(
            list: CustomSpinList(
                name: "Movie Night",
                items: [
                    CustomSpinItem(text: "Action"),
                    CustomSpinItem(text: "Comedy"),
                    CustomSpinItem(text: "Drama"),
                    CustomSpinItem(text: "Horror"),
                ],
                emoji: "🎬"
            )
        )
        .environmentObject(AppEnvironment())
    }
}
