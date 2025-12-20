//
//  CustomSpinListViewModel.swift
//  WhatNow
//
//  ViewModel for Custom Spin List
//

import Foundation
internal import Combine

@MainActor
final class CustomSpinListViewModel: ObservableObject {
    @Published var lists: [CustomSpinList] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let customSpinManager: CustomSpinManaging

    init(customSpinManager: CustomSpinManaging? = nil) {
        self.customSpinManager = customSpinManager ?? DependencyContainer.shared.customSpinManager
    }

    func loadLists() async {
        isLoading = true
        errorMessage = nil

        lists = await customSpinManager.fetchLists()

        isLoading = false
    }

    func deleteList(id: UUID) async {
        do {
            try await customSpinManager.deleteList(id: id)
            await loadLists()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
