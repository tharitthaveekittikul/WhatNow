//
//  MallSelectionViewModel.swift
//  WhatNow
//
//  ViewModel for Mall Selection
//

import Foundation
internal import Combine

@MainActor
final class MallSelectionViewModel: ObservableObject {
    @Published var malls: [Mall] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let fetchMallsUseCase: FetchMallsUseCase
    private var hasLoaded = false

    init(fetchMallsUseCase: FetchMallsUseCase = DependencyContainer.shared.fetchMallsUseCase) {
        self.fetchMallsUseCase = fetchMallsUseCase
    }

    func loadMalls() async {
        // Prevent duplicate loads
        guard !hasLoaded && !isLoading else { return }

        hasLoaded = true
        isLoading = true
        errorMessage = nil

        do {
            malls = try await fetchMallsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
            hasLoaded = false // Allow retry
        }

        isLoading = false
    }
}
