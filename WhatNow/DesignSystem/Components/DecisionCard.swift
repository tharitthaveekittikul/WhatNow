//
//  DecisionCard.swift
//  WhatNow
//
//  Design System - Decision Card Component
//

import SwiftUI

/// A card component for decision options
struct DecisionCard: View {
    let title: String
    let emoji: String
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
        .buttonStyle(CardButtonStyle())
    }
}

/// Button style for cards
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        DecisionCard(
            title: "กินอะไรดี",
            emoji: "🍽️",
            accentColor: .App.accentWarm
        ) {}

        DecisionCard(
            title: "ทำอะไรดี",
            emoji: "🎯",
            accentColor: .App.accentSky
        ) {}
    }
    .padding()
    .background(Color.App.background)
}
