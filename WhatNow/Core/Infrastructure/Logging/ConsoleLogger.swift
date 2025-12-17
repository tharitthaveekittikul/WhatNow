//
//  ConsoleLogger.swift
//  WhatNow
//
//  Infrastructure - Console Logger
//

import Foundation
import OSLog

/// Console-based logger implementation using OSLog
final class ConsoleLogger: Logger {
    private let osLogger = OSLog(subsystem: "com.cloudy.WhatNow", category: "API")

    func log(_ message: String, level: LogLevel) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logMessage = "[\(timestamp)] \(level.rawValue): \(message)"

        // Also use OSLog for system console
        switch level {
        case .debug:
            os_log(.debug, log: osLogger, "%{public}@", logMessage)
        case .info:
            os_log(.info, log: osLogger, "%{public}@", logMessage)
        case .warning:
            os_log(.default, log: osLogger, "%{public}@", logMessage)
        case .error:
            os_log(.error, log: osLogger, "%{public}@", logMessage)
        }

        // Print to console for debug builds
        #if DEBUG
        print(logMessage)
        #endif
    }
}
