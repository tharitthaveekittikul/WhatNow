//
//  CustomSpinEditorView.swift
//  WhatNow
//
//  Custom Spin Editor View
//

import SwiftUI

struct CustomSpinEditorView: View {
    let list: CustomSpinList?
    @StateObject private var viewModel: CustomSpinEditorViewModel
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    init(list: CustomSpinList?) {
        self.list = list
        _viewModel = StateObject(wrappedValue: CustomSpinEditorViewModel(list: list))
    }

    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // List Name & Emoji Section
                    VStack(spacing: 16) {
                        Text("List Details".localized(for: appEnvironment.currentLanguage))
                            .font(.appHeadline)
                            .foregroundColor(.App.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 12) {
                            // Emoji Picker
                            Text(viewModel.emoji)
                                .font(.system(size: 40))
                                .frame(width: 60, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.App.surface)
                                )
                                .onTapGesture {
                                    // Cycle through emojis
                                    let emojis = ["✨", "🎯", "🎲", "🎪", "🎨", "🎭", "🎬", "🎮", "🎸", "⚽️", "🍕", "📝"]
                                    if let index = emojis.firstIndex(of: viewModel.emoji) {
                                        viewModel.emoji = emojis[(index + 1) % emojis.count]
                                    } else {
                                        viewModel.emoji = emojis[0]
                                    }
                                }

                            // List Name
                            TextField("List Name".localized(for: appEnvironment.currentLanguage), text: $viewModel.name)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.App.surface)
                                )
                                .foregroundColor(.App.text)
                        }
                    }

                    // Items Section
                    VStack(spacing: 16) {
                        HStack {
                            Text("Items".localized(for: appEnvironment.currentLanguage))
                                .font(.appHeadline)
                                .foregroundColor(.App.textSecondary)

                            Spacer()

                            Text("Minimum 2 items".localized(for: appEnvironment.currentLanguage))
                                .font(.appCaption)
                                .foregroundColor(.App.textTertiary)
                        }

                        ForEach($viewModel.items.indices, id: \.self) { index in
                            HStack(spacing: 12) {
                                TextField("Item \(index + 1)".localized(for: appEnvironment.currentLanguage), text: $viewModel.items[index].text)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.App.surface)
                                    )
                                    .foregroundColor(.App.text)

                                Button {
                                    viewModel.deleteItem(at: IndexSet(integer: index))
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                }
                                .opacity(viewModel.items.count > 2 ? 1.0 : 0.3)
                                .disabled(viewModel.items.count <= 2)
                            }
                        }

                        Button {
                            viewModel.addItem()
                        } label: {
                            Label("Add Item".localized(for: appEnvironment.currentLanguage), systemImage: "plus.circle.fill")
                                .font(.appHeadline)
                                .foregroundColor(.App.text)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.App.text.opacity(0.3), lineWidth: 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(Color.App.surface)
                                        )
                                )
                        }
                    }

                    // Save Button
                    Button {
                        Task {
                            if await viewModel.save() {
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Save".localized(for: appEnvironment.currentLanguage))
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!viewModel.canSave || viewModel.isSaving)
                    .opacity(viewModel.canSave ? 1.0 : 0.5)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.appCallout)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
        }
        .navigationTitle((list == nil ? "Create List" : "Edit List").localized(for: appEnvironment.currentLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .id(appEnvironment.languageDidChange)
        .withBannerAd(placement: .customSpinEditor)
    }
}

#Preview {
    NavigationStack {
        CustomSpinEditorView(list: nil)
            .environmentObject(AppEnvironment())
    }
}
