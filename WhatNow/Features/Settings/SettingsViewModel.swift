//
//  SettingsViewModel.swift
//  WhatNow
//
//  ViewModel for Settings
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var selectedAppearance: AppearanceMode {
        didSet {
            settingsStore.appearanceMode = selectedAppearance
            // Update app environment directly
            appEnvironment?.colorScheme = selectedAppearance.colorScheme
        }
    }

    @Published var selectedLanguage: Language {
        didSet {
            settingsStore.language = selectedLanguage
        }
    }

    // Pro purchase state
    @Published var isProUser = false
    @Published var proProduct: PurchaseProduct?
    @Published var isLoadingProduct = false
    @Published var isPurchasing = false
    @Published var restoreResultMessage: String?

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return "\(version)"
    }

    private var settingsStore: SettingsStore
    private let purchaseService: PurchaseService
    var appEnvironment: AppEnvironment?

    init(
        settingsStore: SettingsStore? = nil,
        purchaseService: PurchaseService? = nil,
        appEnvironment: AppEnvironment? = nil
    ) {
        let store = settingsStore ?? DependencyContainer.shared.settingsStore
        self.settingsStore = store
        self.purchaseService = purchaseService ?? DependencyContainer.shared.purchaseService
        self.appEnvironment = appEnvironment
        self.selectedAppearance = store.appearanceMode
        self.selectedLanguage = store.language
    }

    // MARK: - Pro Purchase

    func loadProProduct() async {
        isLoadingProduct = true

        do {
            let products = try await purchaseService.fetchProducts(productIds: ["whatnow_pro"])
            proProduct = products.first
        } catch {
            // Failed to load product
        }

        isLoadingProduct = false
    }

    func checkProStatus() async {
        isProUser = await purchaseService.hasPurchased(productId: "whatnow_pro")
    }

    func purchasePro() async {
        print("🔵 SettingsViewModel.purchasePro() called")
        guard !isPurchasing else { return }

        isPurchasing = true

        let result = await purchaseService.purchase(productId: "whatnow_pro")

        switch result {
        case .success:
            await checkProStatus()
        case .cancelled:
            break
        case .pending:
            break
        case .failed:
            break
        }

        isPurchasing = false
    }

    func restorePurchases() async {
        print("🟢 SettingsViewModel.restorePurchases() called")
        isPurchasing = true
        restoreResultMessage = nil

        do {
            try await purchaseService.restorePurchases()
            let wasProBefore = isProUser
            await checkProStatus()

            // Show appropriate message based on result
            if isProUser && !wasProBefore {
                restoreResultMessage = "WhatNow Pro restored successfully!"
            } else if isProUser {
                restoreResultMessage = "You already have WhatNow Pro"
            } else {
                restoreResultMessage = "No purchases to restore"
            }
        } catch {
            restoreResultMessage = "Failed to restore purchases"
        }

        isPurchasing = false
    }

    func dismissRestoreResult() {
        restoreResultMessage = nil
    }
}
