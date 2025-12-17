//
//  Logger.swift
//  WhatNow
//
//  Domain Protocol - Logger
//

import Foundation

/// Logger protocol for app-wide logging
protocol Logger: Sendable {
    func debug(
        _ message: String,
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    )

    func info(
        _ message: String,
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    )

    func warning(
        _ message: String,
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    )

    func error(
        _ message: String,
        category: LogCategory,
        error: Error?,
        file: String,
        function: String,
        line: Int
    )
}

// MARK: - Convenience Extensions

extension Logger {
    func debug(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        debug(message, category: category, file: file, function: function, line: line)
    }

    func info(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        info(message, category: category, file: file, function: function, line: line)
    }

    func warning(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        warning(message, category: category, file: file, function: function, line: line)
    }

    func error(
        _ message: String,
        category: LogCategory = .general,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        self.error(message, category: category, error: error, file: file, function: function, line: line)
    }
}
