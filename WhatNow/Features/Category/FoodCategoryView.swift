//
//  FoodCategoryView.swift
//  WhatNow
//
//  Food Category View - Mall and Famous Store selection
//

import SwiftUI

struct FoodCategoryView: View {
    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Title
                Text("กินอะไรดี")
                    .font(.appLargeTitle)
                    .foregroundColor(.App.text)

                Spacer()

                // Source type cards
                VStack(spacing: 20) {
                    NavigationLink(destination: MallSelectionView()) {
                        DecisionCardContent(
                            title: FoodSourceType.mall.title,
                            emoji: FoodSourceType.mall.emoji,
                            accentColor: .App.accentLavender
                        )
                    }
                    .buttonStyle(CardButtonStyle())

                    NavigationLink(destination: Text("Famous Stores Coming Soon!").font(.appTitle)) {
                        DecisionCardContent(
                            title: FoodSourceType.famous.title,
                            emoji: FoodSourceType.famous.emoji,
                            accentColor: .App.accentWarm
                        )
                    }
                    .buttonStyle(CardButtonStyle())
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationTitle("กินอะไรดี")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FoodCategoryView()
    }
}
