//
//  APIPacksService.swift
//  WhatNow
//
//  Infrastructure - API Packs Service Implementation
//

import Foundation

/// API-based implementation of PacksService
final class APIPacksService: PacksService {
    private let baseURL: String
    private let session: URLSession

    init(
        baseURL: String = "https://whatnow-api-867193034636.asia-southeast1.run.app",
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetchMalls() async throws -> [Mall] {
        let url = URL(string: "\(baseURL)/v1/packs/malls/index")!

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        let mallsIndex = try decoder.decode(MallsIndex.self, from: data)
        return mallsIndex.malls
    }

    func fetchMallStores(mallId: String) async throws -> MallPack {
        let url = URL(string: "\(baseURL)/v1/packs/malls/\(mallId)")!

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        return try decoder.decode(MallPack.self, from: data)
    }
}

/// API errors
enum APIError: Error, LocalizedError {
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "Server error: HTTP \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError:
            return "Network error occurred"
        }
    }
}
