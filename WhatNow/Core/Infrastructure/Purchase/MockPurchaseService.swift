//
//  MockPurchaseService.swift
//  WhatNow
//
//  Mock implementation of PurchaseService for testing
//

import Foundation

actor MockPurchaseService: PurchaseService {

    private var purchasedProducts: Set<String> = []

    nonisolated func fetchProducts(productIds: [String]) async throws -> [PurchaseProduct] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        return [
            PurchaseProduct(
                id: "whatnow_pro",
                displayName: "WhatNow Pro",
                description: "Remove all ads and unlock upcoming Pro features",
                price: 79.00,
                priceFormatted: "฿79.00",
                type: .nonConsumable
            )
        ]
    }

    func purchase(productId: String) async -> PurchaseResult {
        // Simulate purchase flow
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Mock success
        purchasedProducts.insert(productId)
        return .success
    }

    func restorePurchases() async throws {
        // Stub - would restore from StoreKit in production
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    func hasPurchased(productId: String) async -> Bool {
        purchasedProducts.contains(productId)
    }
}
