//
//  HomeView.swift
//  WhatNow
//
//  Home View - Main decision screen
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.App.background
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // Title
                    VStack(spacing: 8) {
                        Text("WhatNow")
                            .font(.appLargeTitle)
                            .foregroundColor(.App.text)

                        Text("อะไรดี")
                            .font(.appTitle3)
                            .foregroundColor(.App.textSecondary)
                    }

                    Spacer()

                    // Decision cards
                    VStack(spacing: 20) {
                        NavigationLink(destination: FoodCategoryView()) {
                            DecisionCardContent(
                                title: DecisionCategory.food.title,
                                emoji: DecisionCategory.food.emoji,
                                accentColor: .App.accentWarm
                            )
                        }
                        .buttonStyle(CardButtonStyle())

                        NavigationLink(destination: Text("Activities Coming Soon!").font(.appTitle)) {
                            DecisionCardContent(
                                title: DecisionCategory.activity.title,
                                emoji: DecisionCategory.activity.emoji,
                                accentColor: .App.accentSky
                            )
                        }
                        .buttonStyle(CardButtonStyle())
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
        }
    }
}

/// Card content without button wrapper (for use with NavigationLink)
struct DecisionCardContent: View {
    let title: String
    let emoji: String
    let accentColor: Color

    var body: some View {
        VStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 60))

            Text(title)
                .font(.appTitle2)
                .foregroundColor(.App.text)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(accentColor)
        )
    }
}

#Preview {
    HomeView()
}
