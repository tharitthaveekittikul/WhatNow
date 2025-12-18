//
//  MallSelectionView.swift
//  WhatNow
//
//  Mall Selection View
//

import SwiftUI

struct MallSelectionView: View {
    @StateObject private var viewModel = MallSelectionViewModel()
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
                    Text("Error", bundle: .main, comment: "Error title")
                        .font(.appTitle2)
                        .foregroundColor(.App.text)

                    Text(errorMessage)
                        .font(.appBody)
                        .foregroundColor(.App.textSecondary)
                        .multilineTextAlignment(.center)

                    Button(String(localized: "Try Again")) {
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
        .navigationTitle(String(localized: "Select Mall"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard !hasAppeared else { return }
            hasAppeared = true
            await viewModel.loadMalls()
        }
    }
}

struct MallListView: View {
    let malls: [Mall]
    @State private var searchText = ""

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
                        Text("No malls found", bundle: .main, comment: "Empty state message")
                            .font(.appHeadline)
                            .foregroundColor(.App.textSecondary)
                        Text("Try a different search term", bundle: .main, comment: "Empty state hint")
                            .font(.appCallout)
                            .foregroundColor(.App.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                }
            }
            .padding()
        }
        .searchable(text: $searchText, prompt: Text("Search malls", bundle: .main, comment: "Search prompt"))
    }
}

struct MallCardContent: View {
    let mall: Mall

    var body: some View {
        HStack(spacing: 16) {
            Text("🏬")
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                Text(mall.displayName)
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
