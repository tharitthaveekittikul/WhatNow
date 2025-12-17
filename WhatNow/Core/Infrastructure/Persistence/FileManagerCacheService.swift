//
//  FileManagerCacheService.swift
//  WhatNow
//
//  Infrastructure - FileManager-based Cache Service
//

@preconcurrency import Foundation

/// FileManager-based cache implementation
final class FileManagerCacheService: CacheService, @unchecked Sendable {
    private let logger: Logger
    private let cacheDirectory: URL

    init(logger: Logger) {
        self.logger = logger

        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let directory = urls[0].appendingPathComponent("WhatNowCache", isDirectory: true)

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        self.cacheDirectory = directory
    }

    nonisolated func save<T: Codable & Sendable>(_ data: T, forKey key: String, version: Int) throws {
        let cachedData = CachedData(data: data, version: version, cachedAt: Date())
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let encoded = try encoder.encode(cachedData)
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")

        try encoded.write(to: fileURL, options: .atomic)
        logger.debug("💾 Saved to disk: \(key) (v\(version))", category: .persistence)
    }

    nonisolated func load<T: Codable & Sendable>(forKey key: String, type: T.Type) throws -> CachedData<T>? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let cachedData = try decoder.decode(CachedData<T>.self, from: data)
        // No logging here - let the service layer log cache hits

        return cachedData
    }

    nonisolated func isValid(forKey key: String, requiredVersion: Int) -> Bool {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let metadata = try? JSONDecoder().decode(CacheMetadata.self, from: data) else {
            return false
        }

        return metadata.version >= requiredVersion
    }

    nonisolated func clearAll() throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }
        logger.info("🗑️ Cleared all cache", category: .persistence)
    }

    nonisolated func clear(forKey key: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
            logger.info("🗑️ Cleared cache for key: \(key)", category: .persistence)
        }
    }
}

/// Metadata structure for quick version checking
private struct CacheMetadata: Codable, Sendable {
    let version: Int
}
