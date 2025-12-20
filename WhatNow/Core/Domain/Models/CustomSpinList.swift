//
//  CustomSpinList.swift
//  WhatNow
//
//  Domain Model - Custom Spin Lists
//

import Foundation

/// Represents a single item in a custom spin list
struct CustomSpinItem: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String

    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}

/// Represents a custom user-created spin list
struct CustomSpinList: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var items: [CustomSpinItem]
    var emoji: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        items: [CustomSpinItem] = [],
        emoji: String = "✨",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.items = items
        self.emoji = emoji
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - SpinnableItem Conformance

extension CustomSpinItem: SpinnableItem {
    var displayName: String {
        text
    }

    var secondaryInfo: String {
        ""
    }

    var filterTags: [String] {
        []
    }
}
