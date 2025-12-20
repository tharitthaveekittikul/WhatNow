//
//  SettingsViewModel.swift
//  WhatNow
//
//  ViewModel for managing user settings
//

internal import Combine
import Foundation
import SwiftUI
import UIKit

@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - State

    struct State: Equatable {
        var selectedAppearance: AppearanceMode
        var selectedLanguage: Language
        var appVersion: String
        var buildNumber: String
        var deviceModel: String
        var iosVersion: String
        var timeZone: String
        var isProUser: Bool
        var proProduct: PurchaseProduct?
        var isLoadingProduct: Bool
        var isPurchasing: Bool
        var restoreResultMessage: String?

        static func initial(settingsStore: SettingsStore) -> State {
            State(
                selectedAppearance: settingsStore.appearanceMode,
                selectedLanguage: settingsStore.language,
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1",
                deviceModel: UIDevice.current.model,
                iosVersion: UIDevice.current.systemVersion,
                timeZone: TimeZone.current.identifier,
                isProUser: false,
                proProduct: nil,
                isLoadingProduct: false,
                isPurchasing: false,
                restoreResultMessage: nil
            )
        }
    }

    @Published private(set) var state: State

    // MARK: - Dependencies

    private var settingsStore: SettingsStore
    private let purchaseService: PurchaseService
    var appEnvironment: AppEnvironment?

    // MARK: - Initialization

    init(
        settingsStore: SettingsStore? = nil,
        purchaseService: PurchaseService? = nil,
        appEnvironment: AppEnvironment? = nil
    ) {
        let store = settingsStore ?? DependencyContainer.shared.settingsStore
        self.settingsStore = store
        self.purchaseService = purchaseService ?? DependencyContainer.shared.purchaseService
        self.appEnvironment = appEnvironment
        self.state = State.initial(settingsStore: store)
    }

    // MARK: - Actions

    func loadSettings() async {
        await loadProProduct()
        await checkProStatus()
    }

    func updateAppearanceMode(_ mode: AppearanceMode) {
        state.selectedAppearance = mode
        settingsStore.appearanceMode = mode
        appEnvironment?.colorScheme = mode.colorScheme
    }

    func updateLanguage(_ language: Language) {
        state.selectedLanguage = language
        settingsStore.language = language
    }

    // MARK: - Pro Purchase

    func loadProProduct() async {
        state.isLoadingProduct = true

        do {
            let products = try await purchaseService.fetchProducts(productIds: ["whatnow_pro"])
            state.proProduct = products.first
        } catch {
            // Failed to load product
        }

        state.isLoadingProduct = false
    }

    func checkProStatus() async {
        state.isProUser = await purchaseService.hasPurchased(productId: "whatnow_pro")
    }

    func purchasePro() async {
        print("🔵 SettingsViewModel.purchasePro() called")
        guard !state.isPurchasing else { return }

        state.isPurchasing = true

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

        state.isPurchasing = false
    }

    func restorePurchases() async {
        print("🟢 SettingsViewModel.restorePurchases() called")
        state.isPurchasing = true
        state.restoreResultMessage = nil

        do {
            try await purchaseService.restorePurchases()
            let wasProBefore = state.isProUser
            await checkProStatus()

            // Show appropriate message based on result
            if state.isProUser && !wasProBefore {
                state.restoreResultMessage = "WhatNow Pro restored successfully!"
            } else if state.isProUser {
                state.restoreResultMessage = "You already have WhatNow Pro"
            } else {
                state.restoreResultMessage = "No purchases to restore"
            }
        } catch {
            state.restoreResultMessage = "Failed to restore purchases"
        }

        state.isPurchasing = false
    }

    func dismissRestoreResult() {
        state.restoreResultMessage = nil
    }

    // MARK: - Support

    func createSupportFormURL(storeName: String? = nil, mallName: String? = nil, location: String? = nil) -> URL? {
        let formBase = "https://docs.google.com/forms/d/e/1FAIpQLSeiBB9cJTxxyzQqVxUgs1L4Bi-yxr-RUqPzI_eOU5RA_eb_7g/viewform"

        let isProUser = state.isProUser
        let appLanguage = state.selectedLanguage.rawValue
        let appLocale = "\(appLanguage)_\(Locale.current.regionCode ?? "TH")"

        var entries: [String: String] = [
            "entry.644868148": state.appVersion,
            "entry.573002577": state.buildNumber,
            "entry.1516834508": state.deviceModel,
            "entry.797688444": state.iosVersion,
            "entry.114735768": appLocale,
            "entry.266300204": state.timeZone,
            "entry.2042691400": isProUser ? "Yes" : "No",
        ]

        // Add store-specific entries if provided
        if let storeName = storeName {
            entries["entry.1754396415"] = storeName
        }
        if let mallName = mallName {
            entries["entry.1745886589"] = mallName
        }
        if let location = location {
            entries["entry.1618588487"] = location
        }

        var components = URLComponents(string: formBase)
        components?.queryItems = entries.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }

        return components?.url
    }
}
