//
//  SettingsView.swift
//  WhatNow
//
//  Settings screen for app configuration
//

import SafariServices
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSupportForm = false
    @State private var supportFormURL: URL?
    @State private var showWebView = false
    @State private var webViewURL: URL?

    init() {
        _viewModel = StateObject(wrappedValue: SettingsViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Appearance Section
                settingsSection(title: "Appearance".localized(for: viewModel.state.selectedLanguage)) {
                    HStack(spacing: 12) {
                        ForEach(AppearanceMode.allCases) { mode in
                            appearanceModeButton(
                                mode: mode,
                                isSelected: viewModel.state.selectedAppearance == mode
                            ) {
                                viewModel.updateAppearanceMode(mode)
                            }
                        }
                    }
                }

                // Language Section
                settingsSection(title: "Language".localized(for: viewModel.state.selectedLanguage)) {
                    NavigationLink {
                        LanguagePickerView(
                            selectedLanguage: viewModel.state.selectedLanguage
                        ) { language in
                            viewModel.updateLanguage(language)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(viewModel.state.selectedLanguage.flag)
                                .font(.system(size: 24))

                            Text(viewModel.state.selectedLanguage.displayName)
                                .font(.appBody)
                                .foregroundColor(.App.text)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.App.textTertiary)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.App.surface)
                        .cornerRadius(12)
                    }
                }

                // WhatNow Pro Section
                if !viewModel.state.isProUser {
                    settingsSection(title: "WhatNow Pro".localized(for: viewModel.state.selectedLanguage)) {
                        proUpgradeCard
                    }
                } else {
                    settingsSection(title: "WhatNow Pro".localized(for: viewModel.state.selectedLanguage)) {
                        proStatusCard
                    }
                }

                // About Section
                settingsSection(title: "About".localized(for: viewModel.state.selectedLanguage)) {
                    VStack(spacing: 12) {
                        infoRow(
                            title: "Version".localized(for: viewModel.state.selectedLanguage),
                            value: viewModel.state.appVersion
                        )

                        actionRow(
                            title: "Rate the App".localized(for: viewModel.state.selectedLanguage),
                            icon: "star.fill"
                        ) {
                            Task {
                                await appEnvironment.ratingService.openReviewPage(
                                    appID: DefaultRatingService.appStoreID
                                )
                            }
                        }

                        actionRow(
                            title: "Privacy Policy".localized(for: viewModel.state.selectedLanguage),
                            icon: "hand.raised.fill"
                        ) {
                            webViewURL = URL(string: "https://whatnow-random.vercel.app/privacy")
                            showWebView = true
                        }

                        actionRow(
                            title: "Terms of Service".localized(for: viewModel.state.selectedLanguage),
                            icon: "doc.text.fill"
                        ) {
                            webViewURL = URL(string: "https://whatnow-random.vercel.app/terms")
                            showWebView = true
                        }

                        actionRow(
                            title: "Contact Support".localized(for: viewModel.state.selectedLanguage),
                            icon: "envelope.fill"
                        ) {
                            supportFormURL = viewModel.createSupportFormURL()
                            showSupportForm = true
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
        .background(Color.App.background.ignoresSafeArea())
        .navigationTitle("Settings".localized(for: viewModel.state.selectedLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .withBannerAd(placement: .settings)
        .onAppear {
            if viewModel.appEnvironment == nil {
                viewModel.appEnvironment = appEnvironment
            }
        }
        .task {
            await viewModel.loadSettings()
        }
        .sheet(isPresented: $showSupportForm) {
            if let url = supportFormURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showWebView) {
            if let url = webViewURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .alert("Restore Purchases".localized(for: viewModel.state.selectedLanguage), isPresented: Binding(
            get: { viewModel.state.restoreResultMessage != nil },
            set: { if !$0 { viewModel.dismissRestoreResult() } }
        )) {
            Button("OK", role: .cancel) {
                viewModel.dismissRestoreResult()
            }
        } message: {
            if let message = viewModel.state.restoreResultMessage {
                Text(message)
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var proUpgradeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Pro Icon and Title
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .foregroundColor(.App.text)
                    .font(.system(size: 28))

                Text("Upgrade to Pro".localized(for: viewModel.state.selectedLanguage))
                    .font(.appTitle)
                    .foregroundColor(.App.text)
            }

            // Benefits List
            VStack(alignment: .leading, spacing: 8) {
                benefitRow(icon: "xmark.circle.fill", text: "Remove all ads".localized(for: viewModel.state.selectedLanguage))
                benefitRow(icon: "star.fill", text: "Unlock upcoming Pro features".localized(for: viewModel.state.selectedLanguage))
                benefitRow(icon: "heart.fill", text: "Support development".localized(for: viewModel.state.selectedLanguage))
            }

            // Price and Purchase Button
            if let product = viewModel.state.proProduct {
                VStack(spacing: 12) {
                    Text(product.priceFormatted)
                        .font(.appLargeTitle)
                        .foregroundColor(.App.text)

                    Button {
                        print("🟦 PURCHASE BUTTON TAPPED")
                        Task {
                            await viewModel.purchasePro()
                        }
                    } label: {
                        Text(viewModel.state.isPurchasing ? "Processing...".localized(for: viewModel.state.selectedLanguage) : "Purchase".localized(for: viewModel.state.selectedLanguage))
                            .font(.appHeadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.App.text)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.state.isPurchasing)

                    Button {
                        print("🟩 RESTORE BUTTON TAPPED")
                        Task {
                            await viewModel.restorePurchases()
                        }
                    } label: {
                        Text("Restore Purchases".localized(for: viewModel.state.selectedLanguage))
                            .font(.caption)
                            .foregroundColor(.App.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
            } else if viewModel.state.isLoadingProduct {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("Failed to load product".localized(for: viewModel.state.selectedLanguage))
                    .font(.appBody)
                    .foregroundColor(.App.textTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(Color.App.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.App.text.opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var proStatusCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .foregroundColor(.App.text)
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 4) {
                Text("WhatNow Pro".localized(for: viewModel.state.selectedLanguage))
                    .font(.appTitle)
                    .foregroundColor(.App.text)

                Text("Thank you for your support!".localized(for: viewModel.state.selectedLanguage))
                    .font(.appSubheadline)
                    .foregroundColor(.App.textSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.App.text)
                .font(.system(size: 28))
        }
        .padding(20)
        .background(Color.App.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.App.text.opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.App.text)
                .font(.system(size: 16))
                .frame(width: 24)

            Text(text)
                .font(.appBody)
                .foregroundColor(.App.textSecondary)
        }
    }

    @ViewBuilder
    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.appHeadline)
                .foregroundColor(.App.textSecondary)
                .padding(.horizontal, 4)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func appearanceModeButton(
        mode: AppearanceMode,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .App.text : .App.textTertiary)

                Text(mode.displayName(for: viewModel.state.selectedLanguage))
                    .font(.caption)
                    .foregroundColor(isSelected ? .App.text : .App.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.App.surface : Color.App.surface.opacity(0.5))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.App.text : Color.clear, lineWidth: 2)
            )
        }
    }

    @ViewBuilder
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.appBody)
                .foregroundColor(.App.textSecondary)

            Spacer()

            Text(value)
                .font(.appBody)
                .foregroundColor(.App.textTertiary)
        }
        .padding()
        .background(Color.App.surface)
        .cornerRadius(12)
    }

    @ViewBuilder
    private func actionRow(
        title: String,
        icon: String,
        destructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(destructive ? .red : .App.text)
                    .frame(width: 24)

                Text(title)
                    .font(.appBody)
                    .foregroundColor(destructive ? .red : .App.text)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.App.textTertiary)
                    .font(.caption)
            }
            .padding()
            .background(Color.App.surface)
            .cornerRadius(12)
        }
    }
}

// MARK: - Language Picker View

private struct LanguagePickerView: View {
    let selectedLanguage: Language
    let onSelect: (Language) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Language.allCases) { language in
                        Button {
                            onSelect(language)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Text(language.flag)
                                    .font(.system(size: 24))

                                Text(language.displayName)
                                    .font(.appBody)
                                    .foregroundColor(.App.text)

                                Spacer()

                                if language == selectedLanguage {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.App.text)
                                }
                            }
                            .padding()
                            .background(Color.App.surface)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Select Language".localized(for: selectedLanguage))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Safari View

private struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true

        let safari = SFSafariViewController(url: url, configuration: config)
        safari.preferredControlTintColor = UIColor(Color.App.text)
        return safari
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: Context
    ) {}
}

// MARK: - Helper Types

private struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - Previews

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppEnvironment())
    }
}
