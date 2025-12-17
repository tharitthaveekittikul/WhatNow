//
//  ConsoleLogger.swift
//  WhatNow
//
//  Infrastructure - Console Logger
//

import Foundation
import OSLog

/// OSLog-based logger implementation
final class ConsoleLogger: Logger, @unchecked Sendable {
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.cloudy.WhatNow"

    // Cache OSLog instances per category
    private let loggers: [LogCategory: os.Logger]

    init() {
        var loggers: [LogCategory: os.Logger] = [:]
        for category in [
            LogCategory.general,
            .networking,
            .persistence,
            .ui,
            .business
        ] {
            loggers[category] = os.Logger(subsystem: subsystem, category: category.rawValue)
        }
        self.loggers = loggers
    }

    func debug(
        _ message: String,
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    ) {
        let logger = getLogger(for: category)
        let fileName = (file as NSString).lastPathComponent
        logger.debug("[\(fileName):\(line)] \(function) - \(message)")
    }

    func info(
        _ message: String,
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    ) {
        let logger = getLogger(for: category)
        let fileName = (file as NSString).lastPathComponent
        logger.info("[\(fileName):\(line)] \(function) - \(message)")
    }

    func warning(
        _ message: String,
        category: LogCategory,
        file: String,
        function: String,
        line: Int
    ) {
        let logger = getLogger(for: category)
        let fileName = (file as NSString).lastPathComponent
        logger.warning("[\(fileName):\(line)] \(function) - \(message)")
    }

    func error(
        _ message: String,
        category: LogCategory,
        error: Error?,
        file: String,
        function: String,
        line: Int
    ) {
        let logger = getLogger(for: category)
        let fileName = (file as NSString).lastPathComponent
        let errorDetails = error.map { " | Error: \($0.localizedDescription)" } ?? ""
        logger.error("[\(fileName):\(line)] \(function) - \(message)\(errorDetails)")
    }

    private func getLogger(for category: LogCategory) -> os.Logger {
        loggers[category] ?? os.Logger(subsystem: subsystem, category: "general")
    }
}
