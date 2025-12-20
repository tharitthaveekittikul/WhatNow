//
//  DecisionCard.swift
//  WhatNow
//
//  Design System - Decision Card Component
//

import SwiftUI

/// A compact card component for decision options (similar to appearance mode buttons)
struct DecisionCard: View {
    let title: String
    let emoji: String
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 48))

                Text(title)
                    .font(.appCallout)
                    .foregroundColor(.App.text)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(accentColor.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(accentColor.opacity(0.4), lineWidth: 1)
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
