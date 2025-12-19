//
//  PurchaseModels.swift
//  WhatNow
//
//  Domain models for in-app purchases
//

import Foundation

/// Represents a product available for purchase
struct PurchaseProduct: Identifiable, Equatable, Sendable {
    let id: String
    let displayName: String
    let description: String
    let price: Decimal
    let priceFormatted: String
    let type: ProductType

    enum ProductType: Sendable {
        case consumable
        case nonConsumable
        case autoRenewableSubscription
        case nonRenewingSubscription
    }
}

/// Result of a purchase transaction
enum PurchaseResult: Equatable, Sendable {
    case success
    case cancelled
    case pending
    case failed(PurchaseError)
}

/// Errors that can occur during purchase
enum PurchaseError: Error, Equatable, Sendable {
    case productNotFound
    case purchaseFailed(String)
    case verificationFailed
    case unknown

    var localizedDescription: String {
        switch self {
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .verificationFailed:
            return "Failed to verify purchase"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
