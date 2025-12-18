//
//  MallSelectionView.swift
//  WhatNow
//
//  Mall Selection View
//

import SwiftUI

struct MallSelectionView: View {
    @StateObject private var viewModel = MallSelectionViewModel()
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @State private var hasAppeared = false

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
                            await viewModel.loadMalls()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
            } else {
                MallListView(malls: viewModel.malls)
            }
        }
        .navigationTitle("Select Mall".localized(for: appEnvironment.currentLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard !hasAppeared else { return }
            hasAppeared = true
            await viewModel.loadMalls()
        }
        .id(appEnvironment.languageDidChange) // Refresh when language changes
    }
}

struct MallListView: View {
    let malls: [Mall]
    @State private var searchText = ""
    @EnvironmentObject private var appEnvironment: AppEnvironment

    private var filteredMalls: [Mall] {
        if searchText.isEmpty {
            return malls
        } else {
            return malls.filter { mall in
                mall.displayName.localizedCaseInsensitiveContains(searchText) ||
                (mall.name.th?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (mall.name.en?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                mall.city.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(filteredMalls) { mall in
                    NavigationLink(value: AppRoute.spin(mall: mall)) {
                        MallCardContent(mall: mall)
                    }
                    .buttonStyle(CardButtonStyle())
                }

                if filteredMalls.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.App.textTertiary)
                        Text("No malls found".localized(for: appEnvironment.currentLanguage))
                            .font(.appHeadline)
                            .foregroundColor(.App.textSecondary)
                        Text("Try a different search term".localized(for: appEnvironment.currentLanguage))
                            .font(.appCallout)
                            .foregroundColor(.App.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                }
            }
            .padding()
        }
        .searchable(text: $searchText, prompt: Text("Search malls".localized(for: appEnvironment.currentLanguage)))
        .id(appEnvironment.languageDidChange) // Refresh when language changes
    }
}

struct MallCardContent: View {
    let mall: Mall
    @EnvironmentObject private var appEnvironment: AppEnvironment

    var body: some View {
        HStack(spacing: 16) {
            Text("🏬")
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                Text(mall.name.localized(for: appEnvironment.currentLanguage))
                    .font(.appHeadline)
                    .foregroundColor(.App.text)

                Text(mall.city)
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

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appHeadline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.App.text)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    NavigationStack {
        MallSelectionView()
    }
}
