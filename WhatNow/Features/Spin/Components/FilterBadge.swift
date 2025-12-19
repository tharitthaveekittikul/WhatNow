//
//  FilterBadge.swift
//  WhatNow
//
//  Reusable badge component showing filter count
//

import SwiftUI

struct FilterBadge: View {
    let count: Int

    var body: some View {
        Circle()
            .fill(Color.App.accentSky)
            .frame(width: 18, height: 18)
            .overlay(
                Text("\(count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.App.text)
            )
    }
}

#Preview {
    HStack(spacing: 16) {
        FilterBadge(count: 1)
        FilterBadge(count: 3)
        FilterBadge(count: 99)
    }
    .padding()
    .background(Color.App.background)
}
