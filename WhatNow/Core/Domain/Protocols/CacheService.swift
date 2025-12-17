//
//  CacheService.swift
//  WhatNow
//
//  Domain Protocol - Cache Service
//

@preconcurrency import Foundation

/// Service protocol for caching data with version control
protocol CacheService: Sendable {
    func save<T: Codable>(_ data: T, forKey key: String, version: Int) async throws
    func load<T: Codable>(forKey key: String, type: T.Type) async throws -> CachedData<T>?

    func isValid(forKey key: String, requiredVersion: Int) async -> Bool
    func clearAll() async throws
    func clear(forKey key: String) async throws
}


/// Cached data wrapper with metadata
struct CachedData<T: Codable>: Codable, Sendable {
    let data: T
    let version: Int
    let cachedAt: Date
}
