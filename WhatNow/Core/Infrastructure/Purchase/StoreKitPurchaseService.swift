//
//  StoreKitPurchaseService.swift
//  WhatNow
//
//  Real StoreKit 2 implementation for in-app purchases
//

import Foundation
import StoreKit

/// Real StoreKit implementation of PurchaseService
actor StoreKitPurchaseService: PurchaseService {

    // MARK: - Properties

    private let logger: Logger
    private var updateListenerTask: Task<Void, Error>?
    private var purchasedProductIDs: Set<String> = []
    private var initialLoadTask: Task<Void, Never>?

    // Product IDs
    static let whatNowProProductID = "whatnow_pro"

    // MARK: - Initialization

    init(logger: Logger) {
        self.logger = logger

        // Start listening for transaction updates
        self.updateListenerTask = Task {
            await self.listenForTransactions()
        }

        // Load current entitlements
        self.initialLoadTask = Task {
            await self.updatePurchasedProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
        initialLoadTask?.cancel()
    }

    // MARK: - PurchaseService

    nonisolated func fetchProducts(productIds: [String]) async throws -> [PurchaseProduct] {
        await logger.info("Fetching products: \(productIds)")

        do {
            let storeProducts = try await Product.products(for: productIds)

            let products = storeProducts.map { product -> PurchaseProduct in
                PurchaseProduct(
                    id: product.id,
                    displayName: product.displayName,
                    description: product.description,
                    price: product.price as Decimal,
                    priceFormatted: product.displayPrice,
                    type: Self.mapProductType(product.type)
                )
            }

            await logger.info("Fetched \(products.count) products")
            return products

        } catch {
            await logger.error("Failed to fetch products", error: error)
            throw error
        }
    }

    nonisolated func purchase(productId: String) async -> PurchaseResult {
        await logger.info("Starting purchase for: \(productId)")

        do {
            let products = try await Product.products(for: [productId])
            guard let product = products.first else {
                await logger.error("Product not found: \(productId)")
                return .failed(.productNotFound)
            }

            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try Self.checkVerified(verification)

                // Update purchased products
                await updatePurchasedProducts()

                // Finish the transaction
                await transaction.finish()

                await logger.info("Purchase successful: \(productId)")
                return .success

            case .userCancelled:
                await logger.info("Purchase cancelled by user: \(productId)")
                return .cancelled

            case .pending:
                await logger.info("Purchase pending: \(productId)")
                return .pending

            @unknown default:
                await logger.error("Unknown purchase result for: \(productId)")
                return .failed(.unknown)
            }

        } catch StoreKitError.userCancelled {
            await logger.info("Purchase cancelled by user: \(productId)")
            return .cancelled

        } catch {
            await logger.error("Purchase failed: \(productId)", error: error)
            return .failed(.purchaseFailed(error.localizedDescription))
        }
    }

    nonisolated func restorePurchases() async throws {
        await logger.info("Restoring purchases")

        // Sync with App Store
        try await AppStore.sync()

        // Update purchased products
        await updatePurchasedProducts()

        await logger.info("Purchases restored")
    }

    func hasPurchased(productId: String) async -> Bool {
        // Wait for initial load to complete if it hasn't already
        if let initialLoadTask = initialLoadTask {
            await initialLoadTask.value
            self.initialLoadTask = nil
        }
        return purchasedProductIDs.contains(productId)
    }

    // MARK: - Private Helpers

    private func listenForTransactions() async {
        // Listen for transaction updates
        for await result in Transaction.updates {
            do {
                let transaction = try Self.checkVerified(result)

                // Update purchased products
                await updatePurchasedProducts()

                // Finish the transaction
                await transaction.finish()

                await logger.info("Transaction updated: \(transaction.productID)")

            } catch {
                await logger.error("Transaction verification failed", error: error)
            }
        }
    }

    private func updatePurchasedProducts() async {
        var productIDs: Set<String> = []

        // Iterate through all transactions and check which ones are purchased
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try Self.checkVerified(result)

                // Add to purchased products if it's valid
                productIDs.insert(transaction.productID)

            } catch {
                await logger.error("Failed to verify transaction", error: error)
            }
        }

        purchasedProductIDs = productIDs
        await logger.info("Updated purchased products: \(productIDs)")
    }

    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check if the transaction is verified
        switch result {
        case .unverified:
            throw PurchaseError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    private static func mapProductType(_ type: Product.ProductType) -> PurchaseProduct.ProductType {
        switch type {
        case .consumable:
            return .consumable
        case .nonConsumable:
            return .nonConsumable
        case .autoRenewable:
            return .autoRenewableSubscription
        case .nonRenewable:
            return .nonRenewingSubscription
        default:
            return .nonConsumable
        }
    }
}
