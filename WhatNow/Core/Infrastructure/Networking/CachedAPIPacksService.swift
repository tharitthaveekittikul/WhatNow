//
//  CachedAPIPacksService.swift
//  WhatNow
//
//  Infrastructure - Cached API Packs Service with Logging
//

@preconcurrency import Foundation

/// API-based implementation with caching and logging using Actor pattern
actor CachedAPIPacksService: PacksService {
    private let baseURL: String
    private let session: URLSession
    private let cache: CacheService
    private let logger: Logger

    // Cached results to prevent duplicate requests
    private var cachedMalls: [Mall]?
    private var cachedMallPacks: [String: MallPack] = [:]

    // Track if we're currently fetching
    private var isFetchingMalls = false
    private var fetchingMallIds = Set<String>()

    // Cache configuration
    private let cacheMaxAge: TimeInterval = 7 * 24 * 60 * 60  // 7 days

    // Cache keys
    private enum CacheKey {
        static let mallsIndex = "malls_index"
        static func mall(_ mallId: String) -> String { "mall_\(mallId)" }
    }

    init(
        baseURL: String =
            "https://whatnow-api-867193034636.asia-southeast1.run.app",
        session: URLSession = .shared,
        cache: CacheService,
        logger: Logger
    ) {
        self.baseURL = baseURL
        self.session = session
        self.cache = cache
        self.logger = logger
    }

    func fetchMalls() async throws -> [Mall] {
        // Return in-memory cached result if available
        if let cached = cachedMalls {
            logger.debug("💾 Memory cache hit: malls", category: .networking)
            return cached
        }

        // If already fetching, wait and return result
        if isFetchingMalls {
            logger.debug(
                "⏳ Request already in progress, waiting...",
                category: .networking
            )
            // Busy-wait (actor serializes access)
            while isFetchingMalls {
                try await Task.sleep(nanoseconds: 50_000_000)  // 50ms
            }
            if let cached = cachedMalls {
                return cached
            }
            // If still no cache after waiting, something went wrong - proceed
        }

        isFetchingMalls = true
        defer { isFetchingMalls = false }

        // Try to load from cache first (with time-based expiration check)
        // If cache exists and is not expired, use it directly
        if let cached = try? await loadFromCache(
            key: CacheKey.mallsIndex,
            type: MallsIndex.self
        ) {
            logger.info(
                "📦 Cache hit: malls_index (v\(cached.version), age: \(Int(Date().timeIntervalSince(cached.cachedAt)))s) - using cached data",
                category: .networking
            )
            cachedMalls = cached.data.malls
            return cached.data.malls
        }

        // Cache expired or doesn't exist - fetch from API
        logger.info(
            "🌐 Cache miss or expired, fetching from API",
            category: .networking
        )
        let mallsIndex = try await fetchMallsFromAPI()

        logger.info(
            "✅ Decoded \(mallsIndex.malls.count) malls (v\(mallsIndex.version)), caching...",
            category: .networking
        )
        try? await saveToCache(
            mallsIndex,
            forKey: CacheKey.mallsIndex,
            version: mallsIndex.version
        )

        cachedMalls = mallsIndex.malls
        return mallsIndex.malls
    }

    func fetchMallStores(mallId: String) async throws -> MallPack {
        // Return in-memory cached result if available
        if let cached = cachedMallPacks[mallId] {
            logger.debug(
                "💾 Memory cache hit: mall_\(mallId)",
                category: .networking
            )
            return cached
        }

        // If already fetching this mall, wait
        if fetchingMallIds.contains(mallId) {
            logger.debug(
                "⏳ Request for \(mallId) already in progress, waiting...",
                category: .networking
            )
            while fetchingMallIds.contains(mallId) {
                try await Task.sleep(nanoseconds: 50_000_000)  // 50ms
            }
            if let cached = cachedMallPacks[mallId] {
                return cached
            }
            // If still no cache after waiting, proceed
        }

        fetchingMallIds.insert(mallId)
        defer { fetchingMallIds.remove(mallId) }

        // Try to load from cache first (with time-based expiration check)
        // If cache exists and is not expired, use it directly
        if let cached = try? await loadFromCache(
            key: CacheKey.mall(mallId),
            type: MallPack.self
        ) {
            logger.info(
                "📦 Cache hit: mall_\(mallId) (v\(cached.version), age: \(Int(Date().timeIntervalSince(cached.cachedAt)))s) - using cached data",
                category: .networking
            )
            cachedMallPacks[mallId] = cached.data
            return cached.data
        }

        // Cache expired or doesn't exist - fetch from API
        logger.info(
            "🌐 Cache miss or expired, fetching from API",
            category: .networking
        )
        let mallPack = try await fetchMallPackFromAPI(mallId: mallId)

        logger.info(
            "✅ Decoded \(mallPack.categories.count) categories (v\(mallPack.version)), caching...",
            category: .networking
        )
        try? await saveToCache(
            mallPack,
            forKey: CacheKey.mall(mallId),
            version: mallPack.version
        )

        cachedMallPacks[mallId] = mallPack
        return mallPack
    }

    // MARK: - Private Helper Methods

    private func fetchMallsFromAPI() async throws -> MallsIndex {
        logger.info(
            "🌐 API Request: GET /v1/packs/malls/index",
            category: .networking
        )

        let url = URL(string: "\(baseURL)/v1/packs/malls/index")!
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("❌ Invalid response type", category: .networking)
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            logger.error(
                "❌ API Error: HTTP \(httpResponse.statusCode)",
                category: .networking
            )
            throw APIError.httpError(httpResponse.statusCode)
        }

        logger.info(
            "✅ API Response: HTTP \(httpResponse.statusCode), decoding...",
            category: .networking
        )

        return try decodeResponse(data: data, type: MallsIndex.self)
    }

    private func fetchMallPackFromAPI(mallId: String) async throws -> MallPack {
        logger.info(
            "🌐 API Request: GET /v1/packs/malls/\(mallId)",
            category: .networking
        )

        let url = URL(string: "\(baseURL)/v1/packs/malls/\(mallId)")!
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("❌ Invalid response type", category: .networking)
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            logger.error(
                "❌ API Error: HTTP \(httpResponse.statusCode)",
                category: .networking
            )
            throw APIError.httpError(httpResponse.statusCode)
        }

        logger.info(
            "✅ API Response: HTTP \(httpResponse.statusCode), decoding...",
            category: .networking
        )

        do {
            return try decodeResponse(data: data, type: MallPack.self)
        } catch {
            logger.error(
                "❌ Decoding failed: \(error)",
                category: .networking,
                error: error
            )
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.debug(
                    "📄 Raw response: \(jsonString.prefix(1000))",
                    category: .networking
                )
            }
            throw error
        }
    }

    private nonisolated func decodeResponse<T: Decodable>(
        data: Data,
        type: T.Type
    ) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return try decoder.decode(T.self, from: data)
    }

    private func loadFromCache<T: Codable>(
        key: String,
        type: T.Type
    ) async throws -> CachedData<T>? {
        try await cache.load(forKey: key, type: type, maxAge: cacheMaxAge)
    }

    private func saveToCache<T: Codable>(
        _ data: T,
        forKey key: String,
        version: Int
    ) async throws {
        try await cache.save(data, forKey: key, version: version)
    }
}
