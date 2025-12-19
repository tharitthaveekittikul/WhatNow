//
//  SettingsView.swift
//  WhatNow
//
//  Settings View
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init() {
        _viewModel = StateObject(wrappedValue: SettingsViewModel())
    }

    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            Form {
                // Appearance Section
                Section {
                    ForEach(AppearanceMode.allCases) { mode in
                        Button(action: {
                            // Inject appEnvironment on first use
                            if viewModel.appEnvironment == nil {
                                viewModel.appEnvironment = appEnvironment
                            }
                            viewModel.selectedAppearance = mode
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: mode.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(.App.text)
                                    .frame(width: 32)

                                Text(mode.displayName(for: viewModel.selectedLanguage))
                                    .font(.appBody)
                                    .foregroundColor(.App.text)

                                Spacer()

                                if viewModel.selectedAppearance == mode {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.App.text)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                } header: {
                    Text("Appearance".localized(for: viewModel.selectedLanguage))
                        .font(.appHeadline)
                        .foregroundColor(.App.textSecondary)
                }
                .listRowBackground(Color.App.surface)

                // Language Section
                Section {
                    NavigationLink {
                        LanguagePickerView(
                            selectedLanguage: viewModel.selectedLanguage
                        ) { language in
                            viewModel.selectedLanguage = language
                        }
                    } label: {
                        HStack(spacing: 16) {
                            Text(viewModel.selectedLanguage.flag)
                                .font(.system(size: 24))
                                .frame(width: 32)

                            Text(viewModel.selectedLanguage.displayName)
                                .font(.appBody)
                                .foregroundColor(.App.text)

                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text("Language".localized(for: viewModel.selectedLanguage))
                        .font(.appHeadline)
                        .foregroundColor(.App.textSecondary)
                }
                .listRowBackground(Color.App.surface)

                // About Section
                Section {
                    // Version
                    HStack {
                        Text("Version".localized(for: viewModel.selectedLanguage))
                            .font(.appBody)
                            .foregroundColor(.App.text)

                        Spacer()

                        Text(viewModel.appVersion)
                            .font(.appBody)
                            .foregroundColor(.App.textSecondary)
                    }
                    .padding(.vertical, 8)

                    // Rate the App
                    Button(action: {
                        // TODO: Implement rate app functionality
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.App.text)
                                .frame(width: 32)

                            Text("Rate the App".localized(for: viewModel.selectedLanguage))
                                .font(.appBody)
                                .foregroundColor(.App.text)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.App.textTertiary)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                    }

                    // Privacy Policy
                    Button(action: {
                        // TODO: Implement privacy policy
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.App.text)
                                .frame(width: 32)

                            Text("Privacy Policy".localized(for: viewModel.selectedLanguage))
                                .font(.appBody)
                                .foregroundColor(.App.text)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.App.textTertiary)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                    }

                    // Terms of Service
                    Button(action: {
                        // TODO: Implement terms of service
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.App.text)
                                .frame(width: 32)

                            Text("Terms of Service".localized(for: viewModel.selectedLanguage))
                                .font(.appBody)
                                .foregroundColor(.App.text)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.App.textTertiary)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                    }

                    // Contact Support
                    Button(action: {
                        // TODO: Implement contact support
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.App.text)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Contact Support".localized(for: viewModel.selectedLanguage))
                                    .font(.appBody)
                                    .foregroundColor(.App.text)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .disabled(true)
                } header: {
                    Text("About".localized(for: viewModel.selectedLanguage))
                        .font(.appHeadline)
                        .foregroundColor(.App.textSecondary)
                }
                .listRowBackground(Color.App.surface)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings".localized(for: viewModel.selectedLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Inject appEnvironment on appear
            if viewModel.appEnvironment == nil {
                viewModel.appEnvironment = appEnvironment
            }
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

            Form {
                ForEach(Language.allCases) { language in
                    Button {
                        onSelect(language)
                        dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            Text(language.flag)
                                .font(.system(size: 24))
                                .frame(width: 32)

                            Text(language.displayName)
                                .font(.appBody)
                                .foregroundColor(.App.text)

                            Spacer()

                            if language == selectedLanguage {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.App.text)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listRowBackground(Color.App.surface)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Select Language".localized(for: selectedLanguage))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppEnvironment())
    }
}
