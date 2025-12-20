//
//  CustomSpinListView.swift
//  WhatNow
//
//  Custom Spin List View
//

import SwiftUI

struct CustomSpinListView: View {
    @StateObject private var viewModel = CustomSpinListViewModel()
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @State private var hasAppeared = false
    @State private var listToDelete: CustomSpinList?
    @State private var showDeleteConfirmation = false

    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .tint(.App.text)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text("Error".localized(for: appEnvironment.currentLanguage))
                        .font(.appTitle2)
                        .foregroundColor(.App.text)

                    Text(errorMessage)
                        .font(.appBody)
                        .foregroundColor(.App.textSecondary)
                        .multilineTextAlignment(.center)

                    Button("Try Again".localized(for: appEnvironment.currentLanguage)) {
                        Task {
                            await viewModel.loadLists()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
            } else if viewModel.lists.isEmpty {
                EmptyStateView()
            } else {
                CustomSpinListContent(
                    lists: viewModel.lists,
                    onDelete: { list in
                        listToDelete = list
                        showDeleteConfirmation = true
                    }
                )
            }
        }
        .navigationTitle("Your Spin".localized(for: appEnvironment.currentLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: AppRoute.customSpinEditor(list: nil)) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.App.text)
                }
            }
        }
        .task {
            guard !hasAppeared else { return }
            hasAppeared = true
            await viewModel.loadLists()
        }
        .onAppear {
            // Reload lists when view appears (e.g., after creating/editing a list)
            if hasAppeared {
                Task {
                    await viewModel.loadLists()
                }
            }
        }
        .id(appEnvironment.languageDidChange)
        .withBannerAd(placement: .customSpinList)
        .alert(
            "Delete List".localized(for: appEnvironment.currentLanguage),
            isPresented: $showDeleteConfirmation,
            presenting: listToDelete
        ) { list in
            Button("Cancel".localized(for: appEnvironment.currentLanguage), role: .cancel) { }
            Button("Delete".localized(for: appEnvironment.currentLanguage), role: .destructive) {
                Task {
                    await viewModel.deleteList(id: list.id)
                }
            }
        } message: { list in
            Text("Are you sure you want to delete \"\(list.name)\"?".localized(for: appEnvironment.currentLanguage))
        }
    }
}

struct CustomSpinListContent: View {
    let lists: [CustomSpinList]
    let onDelete: (CustomSpinList) -> Void
    @EnvironmentObject private var appEnvironment: AppEnvironment

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(lists) { list in
                    NavigationLink(value: AppRoute.customSpin(list: list)) {
                        CustomSpinListCard(list: list)
                    }
                    .buttonStyle(CardButtonStyle())
                    .swipeActions(edge: .trailing) {
                        NavigationLink(value: AppRoute.customSpinEditor(list: list)) {
                            Label("Edit".localized(for: appEnvironment.currentLanguage), systemImage: "pencil")
                        }
                        .tint(.blue)

                        Button(role: .destructive) {
                            onDelete(list)
                        } label: {
                            Label("Delete".localized(for: appEnvironment.currentLanguage), systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct CustomSpinListCard: View {
    let list: CustomSpinList
    @EnvironmentObject private var appEnvironment: AppEnvironment

    var body: some View {
        HStack(spacing: 16) {
            // Emoji icon
            Text(list.emoji)
                .font(.system(size: 48))
                .frame(width: 56, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.App.accentLavender.opacity(0.3))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(list.name)
                    .font(.appHeadline)
                    .foregroundColor(.App.text)

                Text("\(list.items.count) items".localized(for: appEnvironment.currentLanguage))
                    .font(.appCallout)
                    .foregroundColor(.App.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.App.textTertiary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.App.surface)
        )
    }
}

struct EmptyStateView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(.App.accentLavender)

            VStack(spacing: 8) {
                Text("Create Your First List".localized(for: appEnvironment.currentLanguage))
                    .font(.appTitle2)
                    .foregroundColor(.App.text)

                Text("Add your own items to spin and decide".localized(for: appEnvironment.currentLanguage))
                    .font(.appBody)
                    .foregroundColor(.App.textSecondary)
                    .multilineTextAlignment(.center)
            }

            NavigationLink(value: AppRoute.customSpinEditor(list: nil)) {
                Label("Create List".localized(for: appEnvironment.currentLanguage), systemImage: "plus.circle.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxWidth: 280)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        CustomSpinListView()
            .environmentObject(AppEnvironment())
    }
}
