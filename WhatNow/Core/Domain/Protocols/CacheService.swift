//
//  CacheService.swift
//  WhatNow
//
//  Domain Protocol - Cache Service
//

import Foundation

/// Service protocol for caching data with version control
protocol CacheService {
    /// Save data to cache with version
    func save<T: Codable>(_ data: T, forKey key: String, version: Int) throws

    /// Load data from cache
    func load<T: Codable>(forKey key: String, type: T.Type) throws -> CachedData<T>?

    /// Check if cached data exists and is valid
    func isValid(forKey key: String, requiredVersion: Int) -> Bool

    /// Clear all cache
    func clearAll() throws

    /// Clear specific cache entry
    func clear(forKey key: String) throws
}

/// Cached data wrapper with metadata
struct CachedData<T: Codable>: Codable {
    let data: T
    let version: Int
    let cachedAt: Date
}
