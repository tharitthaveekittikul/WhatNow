//
//  FileManagerCacheService.swift
//  WhatNow
//
//  Infrastructure - FileManager-based Cache Service
//

import Foundation

/// FileManager-based cache implementation
final class FileManagerCacheService: CacheService {
    private let fileManager = FileManager.default
    private let logger: Logger

    private lazy var cacheDirectory: URL = {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let directory = urls[0].appendingPathComponent("WhatNowCache", isDirectory: true)

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory
    }()

    init(logger: Logger) {
        self.logger = logger
    }

    func save<T: Codable>(_ data: T, forKey key: String, version: Int) throws {
        let cachedData = CachedData(data: data, version: version, cachedAt: Date())
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let encoded = try encoder.encode(cachedData)
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")

        try encoded.write(to: fileURL, options: .atomic)
        logger.debug("💾 Saved to disk: \(key) (v\(version))")
    }

    func load<T: Codable>(forKey key: String, type: T.Type) throws -> CachedData<T>? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let cachedData = try decoder.decode(CachedData<T>.self, from: data)
        logger.debug("💿 Loaded from disk: \(key) (v\(cachedData.version))")

        return cachedData
    }

    func isValid(forKey key: String, requiredVersion: Int) -> Bool {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")

        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let metadata = try? JSONDecoder().decode(CacheMetadata.self, from: data) else {
            return false
        }

        return metadata.version >= requiredVersion
    }

    func clearAll() throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }
        logger.info("🗑️ Cleared all cache")
    }

    func clear(forKey key: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
            logger.info("🗑️ Cleared cache for key: \(key)")
        }
    }
}

/// Metadata structure for quick version checking
private struct CacheMetadata: Codable {
    let version: Int
}
