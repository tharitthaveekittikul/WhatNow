//
//  CustomSpinEditorViewModel.swift
//  WhatNow
//
//  ViewModel for Custom Spin Editor
//

import Foundation
import SwiftUI
internal import Combine


@MainActor
final class CustomSpinEditorViewModel: ObservableObject {
    @Published var name: String
    @Published var emoji: String
    @Published var items: [CustomSpinItem]
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let customSpinManager: CustomSpinManaging
    private let existingList: CustomSpinList?

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        items.filter { !$0.text.trimmingCharacters(in: .whitespaces).isEmpty }.count >= 2
    }

    init(list: CustomSpinList? = nil, customSpinManager: CustomSpinManaging? = nil) {
        self.existingList = list
        self.customSpinManager = customSpinManager ?? DependencyContainer.shared.customSpinManager

        self.name = list?.name ?? ""
        self.emoji = list?.emoji ?? "✨"
        self.items = list?.items ?? [CustomSpinItem(text: ""), CustomSpinItem(text: "")]
    }

    func addItem() {
        items.append(CustomSpinItem(text: ""))
    }

    func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }

    func save() async -> Bool {
        guard canSave else { return false }

        isSaving = true
        errorMessage = nil

        // Filter out empty items
        let validItems = items.filter { !$0.text.trimmingCharacters(in: .whitespaces).isEmpty }

        let list = CustomSpinList(
            id: existingList?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            items: validItems,
            emoji: emoji,
            createdAt: existingList?.createdAt ?? Date(),
            updatedAt: Date()
        )

        do {
            try await customSpinManager.saveList(list)
            isSaving = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
            return false
        }
    }
}
