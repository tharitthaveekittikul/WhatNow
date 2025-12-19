//
//  PurchaseService.swift
//  WhatNow
//
//  Domain protocol for in-app purchases (StoreKit)
//

import Foundation

/// Service for managing in-app purchases
protocol PurchaseService: Sendable {

    /// Fetch available products from App Store
    /// - Parameter productIds: Array of product identifiers
    /// - Returns: Array of available products
    func fetchProducts(productIds: [String]) async throws -> [PurchaseProduct]

    /// Purchase a product
    /// - Parameter productId: The product identifier to purchase
    /// - Returns: Purchase result
    func purchase(productId: String) async -> PurchaseResult

    /// Restore previous purchases
    func restorePurchases() async throws

    /// Check if user has purchased a specific product
    /// - Parameter productId: The product identifier to check
    /// - Returns: True if purchased and valid
    func hasPurchased(productId: String) async -> Bool
}
