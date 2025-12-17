//
//  CachedAPIPacksService.swift
//  WhatNow
//
//  Infrastructure - Cached API Packs Service with Logging
//

import Foundation

/// API-based implementation with caching and logging using Actor pattern
actor CachedAPIPacksService: PacksService {
    private let baseURL: String
    private let session: URLSession
    private let cache: CacheService
    private let logger: Logger

    // Track in-flight requests to prevent duplicates
    private var inFlightMallsRequest: Task<[Mall], Error>?
    private var inFlightMallStoresRequests: [String: Task<MallPack, Error>] = [:]

    // Cache keys
    private enum CacheKey {
        static let mallsIndex = "malls_index"
        static func mall(_ mallId: String) -> String { "mall_\(mallId)" }
    }

    init(
        baseURL: String = "https://whatnow-api-867193034636.asia-southeast1.run.app",
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
        // Check if there's already an in-flight request
        if let existingTask = inFlightMallsRequest {
            logger.debug("⏳ Reusing in-flight request for malls index")
            return try await existingTask.value
        }

        // Try to load from cache first (before logging to avoid duplicate logs)
        if let cached = try? cache.load(forKey: CacheKey.mallsIndex, type: MallsIndex.self) {
            logger.info("📦 Cache hit: malls_index (v\(cached.version))")
            return cached.data.malls
        }

        logger.info("🌐 API Request: GET /v1/packs/malls/index")

        // Create and store the task
        let task = Task<[Mall], Error> {
            let url = URL(string: "\(baseURL)/v1/packs/malls/index")!

            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("❌ Invalid response type")
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("❌ API Error: HTTP \(httpResponse.statusCode)")
                throw APIError.httpError(httpResponse.statusCode)
            }

            logger.info("✅ API Response: HTTP \(httpResponse.statusCode), decoding...")

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys

            let mallsIndex = try decoder.decode(MallsIndex.self, from: data)

            logger.info("✅ Decoded \(mallsIndex.malls.count) malls, caching...")

            // Cache the response
            try? cache.save(mallsIndex, forKey: CacheKey.mallsIndex, version: mallsIndex.version)

            return mallsIndex.malls
        }

        inFlightMallsRequest = task

        do {
            let result = try await task.value
            inFlightMallsRequest = nil
            return result
        } catch {
            inFlightMallsRequest = nil
            logger.error("❌ Failed to fetch malls: \(error.localizedDescription)")
            throw error
        }
    }

    func fetchMallStores(mallId: String) async throws -> MallPack {
        // Check if there's already an in-flight request for this mall
        if let existingTask = inFlightMallStoresRequests[mallId] {
            logger.debug("⏳ Reusing in-flight request for mall: \(mallId)")
            return try await existingTask.value
        }

        // Try to load from cache first (before logging)
        if let cached = try? cache.load(forKey: CacheKey.mall(mallId), type: MallPack.self) {
            logger.info("📦 Cache hit: mall_\(mallId) (v\(cached.version))")
            return cached.data
        }

        logger.info("🌐 API Request: GET /v1/packs/malls/\(mallId)")

        // Create and store the task
        let task = Task<MallPack, Error> {
            let url = URL(string: "\(baseURL)/v1/packs/malls/\(mallId)")!

            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("❌ Invalid response type")
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("❌ API Error: HTTP \(httpResponse.statusCode)")
                throw APIError.httpError(httpResponse.statusCode)
            }

            logger.info("✅ API Response: HTTP \(httpResponse.statusCode), decoding...")

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys

            do {
                let mallPack = try decoder.decode(MallPack.self, from: data)
                logger.info("✅ Decoded \(mallPack.categories.count) categories, caching...")

                // Cache the response
                try? cache.save(mallPack, forKey: CacheKey.mall(mallId), version: mallPack.version)

                return mallPack
            } catch {
                logger.error("❌ Decoding failed: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    logger.debug("📄 Raw response: \(jsonString.prefix(1000))")
                }
                throw error
            }
        }

        inFlightMallStoresRequests[mallId] = task

        do {
            let result = try await task.value
            inFlightMallStoresRequests[mallId] = nil
            return result
        } catch {
            inFlightMallStoresRequests[mallId] = nil
            throw error
        }
    }
}
