//
//  LogModels.swift
//  WhatNow
//
//  Domain models for logging
//

import Foundation

/// Log category for organizing logs
enum LogCategory: String, Sendable {
    case general
    case networking
    case persistence
    case ui
    case business
}
