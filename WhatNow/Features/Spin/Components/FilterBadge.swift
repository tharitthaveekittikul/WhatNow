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
            .fill(Color(light: Color(hex: "4A90E2"), dark: Color(hex: "5BA3F5")))
            .frame(width: 18, height: 18)
            .overlay(
                Text("\(count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
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
