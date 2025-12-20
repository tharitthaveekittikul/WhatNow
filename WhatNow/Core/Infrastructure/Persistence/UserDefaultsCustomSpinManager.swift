//
//  UserDefaultsCustomSpinManager.swift
//  WhatNow
//
//  Infrastructure - UserDefaults-based Custom Spin Manager
//

import Foundation

/// UserDefaults-based custom spin list persistence
actor UserDefaultsCustomSpinManager: CustomSpinManaging {
    private let defaults = UserDefaults.standard
    private let logger: Logger

    private enum Keys {
        static let lists = "app.customSpin.lists"
    }

    init(logger: Logger) {
        self.logger = logger
    }

    func fetchLists() async -> [CustomSpinList] {
        logger.debug("Fetching custom spin lists from UserDefaults")

        guard let data = defaults.data(forKey: Keys.lists) else {
            logger.debug("No custom spin lists found")
            return []
        }

        do {
            let lists = try JSONDecoder().decode([CustomSpinList].self, from: data)
            logger.debug("Loaded \(lists.count) custom spin lists")
            return lists.sorted { $0.updatedAt > $1.updatedAt }
        } catch {
            logger.error("Failed to decode custom spin lists: \(error.localizedDescription)")
            return []
        }
    }

    func saveList(_ list: CustomSpinList) async throws {
        logger.debug("Saving custom spin list: \(list.name)")

        var lists = await fetchLists()

        // Update existing or add new
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            var updatedList = list
            updatedList.updatedAt = Date()
            lists[index] = updatedList
            logger.debug("Updated existing list: \(list.name)")
        } else {
            lists.append(list)
            logger.debug("Added new list: \(list.name)")
        }

        let data = try JSONEncoder().encode(lists)
        defaults.set(data, forKey: Keys.lists)
    }

    func deleteList(id: UUID) async throws {
        logger.debug("Deleting custom spin list: \(id)")

        var lists = await fetchLists()
        lists.removeAll { $0.id == id }

        let data = try JSONEncoder().encode(lists)
        defaults.set(data, forKey: Keys.lists)

        logger.debug("Deleted list successfully")
    }

    func getList(id: UUID) async -> CustomSpinList? {
        let lists = await fetchLists()
        return lists.first { $0.id == id }
    }
}
