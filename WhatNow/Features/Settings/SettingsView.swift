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

                                Text(mode.displayName)
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
                    Text("Appearance")
                        .font(.appHeadline)
                        .foregroundColor(.App.textSecondary)
                }
                .listRowBackground(Color.App.surface)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Inject appEnvironment on appear
            if viewModel.appEnvironment == nil {
                viewModel.appEnvironment = appEnvironment
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppEnvironment())
    }
}
