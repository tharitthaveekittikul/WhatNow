//
//  SpinViewModel.swift
//  WhatNow
//
//  ViewModel for Spin View
//

import Foundation
internal import Combine

@MainActor
final class SpinViewModel: ObservableObject {
    @Published var stores: [Store] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let mall: Mall
    private let fetchMallStoresUseCase: FetchMallStoresUseCase

    init(
        mall: Mall,
        fetchMallStoresUseCase: FetchMallStoresUseCase = DependencyContainer.shared.fetchMallStoresUseCase
    ) {
        self.mall = mall
        self.fetchMallStoresUseCase = fetchMallStoresUseCase
    }

    func loadStores() async {
        isLoading = true
        errorMessage = nil

        do {
            let mallPack = try await fetchMallStoresUseCase.execute(mallId: mall.mallId)
            // Get all stores from the "all" category
            if let allCategory = mallPack.categories.first(where: { $0.id == "all" }) {
                stores = allCategory.items
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
