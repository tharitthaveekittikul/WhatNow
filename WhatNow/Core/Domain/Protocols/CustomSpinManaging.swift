//
//  CustomSpinManaging.swift
//  WhatNow
//
//  Protocol - Custom Spin List Management
//

import Foundation

/// Protocol for managing custom spin lists
protocol CustomSpinManaging: Actor {
    /// Fetch all custom spin lists
    func fetchLists() async -> [CustomSpinList]

    /// Save a new or updated list
    func saveList(_ list: CustomSpinList) async throws

    /// Delete a list by ID
    func deleteList(id: UUID) async throws

    /// Get a specific list by ID
    func getList(id: UUID) async -> CustomSpinList?
}
