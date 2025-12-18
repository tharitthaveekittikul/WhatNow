//
//  FileManagerCacheService.swift
//  WhatNow
//
//  Infrastructure - FileManager-based Cache Service
//

@preconcurrency import Foundation

/// FileManager-based cache implementation
actor FileManagerCacheService: CacheService {
    private let logger: Logger
    private let cacheDirectory: URL

    init(logger: Logger) {
        self.logger = logger

        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let directory = urls[0].appendingPathComponent(
            "WhatNowCache",
            isDirectory: true
        )

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        }

        self.cacheDirectory = directory
    }

    func save<T: Codable>(_ data: T, forKey key: String, version: Int)
        async throws
    {
        let cachedData = CachedData(
            data: data,
            version: version,
            cachedAt: Date()
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let encoded = try encoder.encode(cachedData)
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")

        try encoded.write(to: fileURL, options: .atomic)
        logger.debug(
            "💾 Saved to disk: \(key) (v\(version))",
            category: .persistence
        )
    }

    func load<T: Codable>(forKey key: String, type: T.Type, maxAge: TimeInterval? = nil) async throws
        -> CachedData<T>?
    {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        let fm = FileManager.default

        guard fm.fileExists(atPath: fileURL.path) else {
            logger.debug("📭 Cache miss: \(key) (file not found)", category: .persistence)
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let cached = try decoder.decode(CachedData<T>.self, from: data)

        // Check time-based expiration if maxAge is specified
        if let maxAge = maxAge {
            if cached.isExpired(maxAge: maxAge) {
                let age = Date().timeIntervalSince(cached.cachedAt)
                logger.info(
                    "⏰ Cache expired: \(key) (age: \(Int(age))s, max: \(Int(maxAge))s)",
                    category: .persistence
                )
                // Delete expired cache file
                try? fm.removeItem(at: fileURL)
                return nil
            }
        }

        return cached
    }

    func isValid(forKey key: String, requiredVersion: Int) async -> Bool {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        let fm = FileManager.default

        guard fm.fileExists(atPath: fileURL.path),
            let data = try? Data(contentsOf: fileURL),
            let metadata = try? JSONDecoder().decode(
                CacheMetadata.self,
                from: data
            )
        else {
            return false
        }
        return metadata.version >= requiredVersion
    }

    func clearAll() async throws {
        let fm = FileManager.default
        let contents = try fm.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: nil
        )
        for url in contents { try fm.removeItem(at: url) }
        logger.info("🗑️ Cleared all cache", category: .persistence)
    }

    func clear(forKey key: String) async throws {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        let fm = FileManager.default
        if fm.fileExists(atPath: fileURL.path) {
            try fm.removeItem(at: fileURL)
            logger.info(
                "🗑️ Cleared cache for key: \(key)",
                category: .persistence
            )
        }
    }

    private struct CacheMetadata: Codable, Sendable { let version: Int }
}
