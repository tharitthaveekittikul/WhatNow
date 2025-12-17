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

    init(fetchMallsUseCase: FetchMallsUseCase = DependencyContainer.shared.fetchMallsUseCase) {
        self.fetchMallsUseCase = fetchMallsUseCase
    }

    func loadMalls() async {
        isLoading = true
        errorMessage = nil

        do {
            malls = try await fetchMallsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
