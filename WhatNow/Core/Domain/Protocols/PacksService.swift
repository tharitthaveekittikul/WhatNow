//
//  PacksService.swift
//  WhatNow
//
//  Domain Protocol - Packs Service
//

import Foundation

/// Service protocol for fetching data packs from the API
protocol PacksService {
    /// Fetch the list of malls
    func fetchMalls() async throws -> [Mall]

    /// Fetch a specific mall's stores
    func fetchMallStores(mallId: String) async throws -> MallPack
}
