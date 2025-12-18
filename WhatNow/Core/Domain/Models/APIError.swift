//
//  APIError.swift
//  WhatNow
//
//  Domain Model - API Error Response
//

import Foundation

/// API error response structure matching backend ErrorResponse
struct APIErrorResponse: Codable, Sendable {
    let error: APIErrorDetail
}

struct APIErrorDetail: Codable, Sendable {
    let code: ErrorCode
    let message: String
    let requestId: String
}

/// Error codes from the API
enum ErrorCode: String, Codable, Sendable {
    case notFound = "NOT_FOUND"
    case badRequest = "BAD_REQUEST"
    case internalError = "INTERNAL"
    case unknown = "UNKNOWN"  // Fallback for unknown codes
}

/// API errors with structured error details
enum APIError: Error, LocalizedError {
    case invalidResponse
    case httpError(Int, APIErrorDetail?)  // HTTP code + optional parsed error
    case decodingError(Error)
    case networkError(Error)
    case apiError(APIErrorDetail)  // Structured API error

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code, let detail):
            if let detail = detail {
                return "[\(detail.code.rawValue)] \(detail.message) (HTTP \(code))"
            }
            return "Server error: HTTP \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError(let detail):
            return "[\(detail.code.rawValue)] \(detail.message)"
        }
    }

    /// Request ID for debugging (if available)
    var requestId: String? {
        switch self {
        case .httpError(_, let detail):
            return detail?.requestId
        case .apiError(let detail):
            return detail.requestId
        default:
            return nil
        }
    }

    /// Error code (if available)
    var errorCode: ErrorCode? {
        switch self {
        case .httpError(_, let detail):
            return detail?.code
        case .apiError(let detail):
            return detail.code
        default:
            return nil
        }
    }
}

/// Helper extension to parse error responses
extension APIError {
    /// Parse error response from data
    static func parse(from data: Data, statusCode: Int) -> APIError {
        // Try to decode structured error response
        let decoder = JSONDecoder()
        if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
            return .apiError(errorResponse.error)
        }

        // Fallback: return generic HTTP error
        return .httpError(statusCode, nil)
    }
}
