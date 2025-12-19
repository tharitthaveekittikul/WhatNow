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
            let mallNames = cached.data.malls.prefix(3).map { $0.displayName }.joined(separator: ", ")
            let preview = cached.data.malls.count > 3 ? "\(mallNames)... (\(cached.data.malls.count) total)" : mallNames
            logger.info(
                "📦 Cache hit: malls_index (v\(cached.version), age: \(Int(Date().timeIntervalSince(cached.cachedAt)))s)",
                category: .networking
            )
            logger.debug(
                "   └─ Cached data: [\(preview)]",
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

        let mallNames = mallsIndex.malls.prefix(3).map { $0.displayName }.joined(separator: ", ")
        let preview = mallsIndex.malls.count > 3 ? "\(mallNames)... (\(mallsIndex.malls.count) total)" : mallNames
        logger.info(
            "✅ Decoded \(mallsIndex.malls.count) malls (v\(mallsIndex.version)), caching...",
            category: .networking
        )
        logger.debug(
            "   └─ Response data: [\(preview)]",
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
            let storeCount = cached.data.categories.flatMap { $0.items }.count
            let categoryNames = cached.data.categories.prefix(2).map { $0.name.en ?? $0.name.th ?? "Unknown" }.joined(separator: ", ")
            let categoryPreview = cached.data.categories.count > 2 ? "\(categoryNames)... (\(cached.data.categories.count) categories)" : categoryNames
            logger.info(
                "📦 Cache hit: mall_\(mallId) (v\(cached.version), age: \(Int(Date().timeIntervalSince(cached.cachedAt)))s)",
                category: .networking
            )
            logger.debug(
                "   └─ Cached data: \(storeCount) stores in [\(categoryPreview)]",
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

        let storeCount = mallPack.categories.flatMap { $0.items }.count
        let categoryNames = mallPack.categories.prefix(2).map { $0.name.en ?? $0.name.th ?? "Unknown" }.joined(separator: ", ")
        let categoryPreview = mallPack.categories.count > 2 ? "\(categoryNames)... (\(mallPack.categories.count) categories)" : categoryNames
        logger.info(
            "✅ Decoded \(mallPack.categories.count) categories (v\(mallPack.version)), caching...",
            category: .networking
        )
        logger.debug(
            "   └─ Response data: \(storeCount) stores in [\(categoryPreview)]",
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

    // MARK: - Famous Stores

    func fetchFamousStores() async throws -> FamousStoresPack {
        let key = "famous_stores"

        // Check disk cache first
        if let cached = try? await loadFromCache(key: key, type: FamousStoresPack.self) {
            let storeNames = cached.data.items.prefix(3).map { $0.name }.joined(separator: ", ")
            let preview = cached.data.items.count > 3 ? "\(storeNames)... (\(cached.data.items.count) total)" : storeNames
            logger.info(
                "📦 Cache hit: \(key) (v\(cached.version), age: \(Int(Date().timeIntervalSince(cached.cachedAt)))s)",
                category: .networking
            )
            logger.debug(
                "   └─ Cached data: [\(preview)]",
                category: .networking
            )
            return cached.data
        }

        // Fetch from API
        logger.info("🌐 API Request: GET /v1/packs/food/famous-stores", category: .networking)

        do {
            let url = URL(string: "\(baseURL)/v1/packs/food/famous-stores")!
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.parse(from: data, statusCode: httpResponse.statusCode)
            }

            let pack = try decodeResponse(data: data, type: FamousStoresPack.self)
            let storeNames = pack.items.prefix(3).map { $0.name }.joined(separator: ", ")
            let preview = pack.items.count > 3 ? "\(storeNames)... (\(pack.items.count) total)" : storeNames
            logger.info("✅ Decoded \(pack.items.count) famous stores (v\(pack.version)), caching...", category: .networking)
            logger.debug(
                "   └─ Response data: [\(preview)]",
                category: .networking
            )
            try? await saveToCache(pack, forKey: key, version: pack.version)
            return pack
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            logger.error("❌ Decoding failed: \(error)", category: .networking)
            throw APIError.decodingError(error)
        } catch {
            logger.error("❌ Network error: \(error)", category: .networking)
            throw APIError.networkError(error)
        }
    }

    // MARK: - Activities

    func fetchActivityCategories() async throws -> ActivitiesIndex {
        let key = "activities_index"

        // Check disk cache first
        if let cached = try? await loadFromCache(key: key, type: ActivitiesIndex.self) {
            let categoryNames = cached.data.categories.prefix(3).map { $0.nameEN }.joined(separator: ", ")
            let preview = cached.data.categories.count > 3 ? "\(categoryNames)... (\(cached.data.categories.count) total)" : categoryNames
            logger.info(
                "📦 Cache hit: \(key) (v\(cached.version), age: \(Int(Date().timeIntervalSince(cached.cachedAt)))s)",
                category: .networking
            )
            logger.debug(
                "   └─ Cached data: [\(preview)]",
                category: .networking
            )
            return cached.data
        }

        // Fetch from API
        logger.info("🌐 API Request: GET /v1/packs/activities/index", category: .networking)
        let index = try await fetchFromAPI(ActivitiesIndex.self, endpoint: "/v1/packs/activities/index")
        let categoryNames = index.categories.prefix(3).map { $0.nameEN }.joined(separator: ", ")
        let preview = index.categories.count > 3 ? "\(categoryNames)... (\(index.categories.count) total)" : categoryNames
        logger.info("✅ Decoded \(index.categories.count) activity categories (v\(index.version)), caching...", category: .networking)
        logger.debug(
            "   └─ Response data: [\(preview)]",
            category: .networking
        )
        try? await saveToCache(index, forKey: key, version: index.version)
        return index
    }

    func fetchActivities(categoryId: String) async throws -> ActivityPack {
        let key = "activity_\(categoryId)"

        // Check disk cache first
        if let cached = try? await loadFromCache(key: key, type: ActivityPack.self) {
            let activityNames = cached.data.items.prefix(3).map { $0.nameTH }.joined(separator: ", ")
            let preview = cached.data.items.count > 3 ? "\(activityNames)... (\(cached.data.items.count) total)" : activityNames
            logger.info(
                "📦 Cache hit: \(key) (v\(cached.version), age: \(Int(Date().timeIntervalSince(cached.cachedAt)))s)",
                category: .networking
            )
            logger.debug(
                "   └─ Cached data: [\(preview)]",
                category: .networking
            )
            return cached.data
        }

        // Fetch from API
        logger.info("🌐 API Request: GET /v1/packs/activities/\(categoryId)", category: .networking)
        let pack = try await fetchFromAPI(ActivityPack.self, endpoint: "/v1/packs/activities/\(categoryId)")
        let activityNames = pack.items.prefix(3).map { $0.nameTH }.joined(separator: ", ")
        let preview = pack.items.count > 3 ? "\(activityNames)... (\(pack.items.count) total)" : activityNames
        logger.info("✅ Decoded \(pack.items.count) activities (v\(pack.version)), caching...", category: .networking)
        logger.debug(
            "   └─ Response data: [\(preview)]",
            category: .networking
        )
        try? await saveToCache(pack, forKey: key, version: pack.version)
        return pack
    }

    // MARK: - Configuration & Metadata

    func fetchAppConfig() async throws -> AppConfig {
        let key = "app_config"

        // Check disk cache first
        if let cached = try? await loadFromCache(key: key, type: AppConfig.self) {
            logger.info(
                "📦 Cache hit: \(key) (v\(cached.version), age: \(Int(Date().timeIntervalSince(cached.cachedAt)))s) - using cached data",
                category: .networking
            )
            return cached.data
        }

        // Fetch from API
        logger.info("🌐 API Request: GET /v1/packs/config", category: .networking)
        let config = try await fetchFromAPI(AppConfig.self, endpoint: "/v1/packs/config")
        logger.info("✅ Decoded app config (v\(config.version)), caching...", category: .networking)
        try? await saveToCache(config, forKey: key, version: config.version)
        return config
    }

    func fetchPriceRanges() async throws -> PriceRangesPack {
        let key = "price_ranges"

        // Check disk cache first
        if let cached = try? await loadFromCache(key: key, type: PriceRangesPack.self) {
            logger.info(
                "📦 Cache hit: \(key) (v\(cached.version), age: \(Int(Date().timeIntervalSince(cached.cachedAt)))s) - using cached data",
                category: .networking
            )
            return cached.data
        }

        // Fetch from API
        logger.info("🌐 API Request: GET /v1/packs/meta/price-ranges", category: .networking)
        let pack = try await fetchFromAPI(PriceRangesPack.self, endpoint: "/v1/packs/meta/price-ranges")
        logger.info("✅ Decoded \(pack.ranges.count) price ranges (v\(pack.version)), caching...", category: .networking)
        try? await saveToCache(pack, forKey: key, version: pack.version)
        return pack
    }

    func fetchTags() async throws -> TagsPack {
        let key = "tags"

        // Check disk cache first
        if let cached = try? await loadFromCache(key: key, type: TagsPack.self) {
            logger.info(
                "📦 Cache hit: \(key) (v\(cached.version), age: \(Int(Date().timeIntervalSince(cached.cachedAt)))s) - using cached data",
                category: .networking
            )
            return cached.data
        }

        // Fetch from API
        logger.info("🌐 API Request: GET /v1/packs/meta/tags", category: .networking)
        let pack = try await fetchFromAPI(TagsPack.self, endpoint: "/v1/packs/meta/tags")
        logger.info("✅ Decoded tags (v\(pack.version)), caching...", category: .networking)
        try? await saveToCache(pack, forKey: key, version: pack.version)
        return pack
    }

    func fetchCatalog() async throws -> CatalogPack {
        let key = "catalog"

        // Check disk cache first
        if let cached = try? await loadFromCache(key: key, type: CatalogPack.self) {
            logger.info(
                "📦 Cache hit: \(key) (v\(cached.version), age: \(Int(Date().timeIntervalSince(cached.cachedAt)))s) - using cached data",
                category: .networking
            )
            return cached.data
        }

        // Fetch from API
        logger.info("🌐 API Request: GET /v1/packs/catalog", category: .networking)
        let catalog = try await fetchFromAPI(CatalogPack.self, endpoint: "/v1/packs/catalog")
        logger.info("✅ Decoded catalog (v\(catalog.version)), caching...", category: .networking)
        try? await saveToCache(catalog, forKey: key, version: catalog.version)
        return catalog
    }

    // MARK: - Private Helper Methods

    /// Generic fetch from API with error handling
    private func fetchFromAPI<T: Decodable>(_ type: T.Type, endpoint: String) async throws -> T {
        do {
            let url = URL(string: "\(baseURL)\(endpoint)")!
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("❌ Invalid response type", category: .networking)
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let error = APIError.parse(from: data, statusCode: httpResponse.statusCode)
                if let requestId = error.requestId {
                    logger.error(
                        "❌ API Error: HTTP \(httpResponse.statusCode) [requestId: \(requestId)]",
                        category: .networking
                    )
                } else {
                    logger.error(
                        "❌ API Error: HTTP \(httpResponse.statusCode)",
                        category: .networking
                    )
                }
                throw error
            }

            return try decodeResponse(data: data, type: type)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            logger.error("❌ Decoding failed: \(error)", category: .networking)
            throw APIError.decodingError(error)
        } catch {
            logger.error("❌ Network error: \(error)", category: .networking)
            throw APIError.networkError(error)
        }
    }

    // MARK: - Private Helper Methods

    private func fetchMallsFromAPI() async throws -> MallsIndex {
        logger.info(
            "🌐 API Request: GET /v1/packs/malls/index",
            category: .networking
        )

        do {
            let url = URL(string: "\(baseURL)/v1/packs/malls/index")!
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("❌ Invalid response type", category: .networking)
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let error = APIError.parse(from: data, statusCode: httpResponse.statusCode)
                if let requestId = error.requestId {
                    logger.error(
                        "❌ API Error: HTTP \(httpResponse.statusCode) [requestId: \(requestId)]",
                        category: .networking
                    )
                } else {
                    logger.error(
                        "❌ API Error: HTTP \(httpResponse.statusCode)",
                        category: .networking
                    )
                }
                throw error
            }

            logger.info(
                "✅ API Response: HTTP \(httpResponse.statusCode), decoding...",
                category: .networking
            )

            return try decodeResponse(data: data, type: MallsIndex.self)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            logger.error("❌ Decoding failed: \(error)", category: .networking)
            throw APIError.decodingError(error)
        } catch {
            logger.error("❌ Network error: \(error)", category: .networking)
            throw APIError.networkError(error)
        }
    }

    private func fetchMallPackFromAPI(mallId: String) async throws -> MallPack {
        logger.info(
            "🌐 API Request: GET /v1/packs/malls/\(mallId)",
            category: .networking
        )

        do {
            let url = URL(string: "\(baseURL)/v1/packs/malls/\(mallId)")!
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("❌ Invalid response type", category: .networking)
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let error = APIError.parse(from: data, statusCode: httpResponse.statusCode)
                if let requestId = error.requestId {
                    logger.error(
                        "❌ API Error: HTTP \(httpResponse.statusCode) [requestId: \(requestId)]",
                        category: .networking
                    )
                } else {
                    logger.error(
                        "❌ API Error: HTTP \(httpResponse.statusCode)",
                        category: .networking
                    )
                }
                throw error
            }

            logger.info(
                "✅ API Response: HTTP \(httpResponse.statusCode), decoding...",
                category: .networking
            )

            return try decodeResponse(data: data, type: MallPack.self)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            logger.error("❌ Decoding failed: \(error)", category: .networking, error: error)
            throw APIError.decodingError(error)
        } catch {
            logger.error("❌ Network error: \(error)", category: .networking, error: error)
            throw APIError.networkError(error)
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
