//
//  SpinButton.swift
//  WhatNow
//
//  Reusable animated SPIN button component
//

import SwiftUI

struct SpinButton: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment

    let isSpinning: Bool
    let gradientRotation: Double
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Sparkle icon with smooth rotation
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .semibold))
                    .rotationEffect(.degrees(isSpinning ? 180 : 0))
                    .scaleEffect(isSpinning ? 1.1 : 1.0)
                    .opacity(isSpinning ? 0.95 : 1.0)
                    .animation(
                        isSpinning
                            ? .linear(duration: 2).repeatForever(autoreverses: false)
                            : .spring(response: 0.4, dampingFraction: 0.7),
                        value: isSpinning
                    )

                // Text with smooth morph
                Text(isSpinning ? "Spinning…".localized(for: appEnvironment.currentLanguage) : "SPIN".localized(for: appEnvironment.currentLanguage))
                    .font(.appTitle3.weight(.bold))
                    .contentTransition(.interpolate)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    // Base gradient with color transition
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            AngularGradient(
                                gradient: Gradient(colors: isSpinning ? [
                                    Color(hex: "FF6B6B"), // Red
                                    Color(hex: "FFD93D"), // Yellow
                                    Color(hex: "6BCF7F"), // Green
                                    Color(hex: "4ECDC4"), // Cyan
                                    Color(hex: "4A90E2"), // Blue
                                    Color(hex: "9B6FD6"), // Purple
                                    Color(hex: "FF6B6B")  // Red (loop)
                                ] : [
                                    Color.App.text,
                                    Color.App.textSecondary,
                                    Color.App.text
                                ]),
                                center: .center,
                                angle: .degrees(gradientRotation)
                            )
                        )

                    // Subtle shimmer overlay when spinning
                    if isSpinning {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0),
                                        Color.white.opacity(0.25),
                                        Color.white.opacity(0)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .blur(radius: 10)
                            .hueRotation(.degrees(gradientRotation / 2))
                    }
                }
            )
            // Glow effect
            .shadow(
                color: isSpinning ? Color(hex: "9B6FD6").opacity(0.5) : Color.black.opacity(0.2),
                radius: isSpinning ? 28 : 10,
                x: 0,
                y: isSpinning ? 10 : 5
            )
            .scaleEffect(isSpinning ? 0.98 : 1.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.75), value: isSpinning)
        }
        .disabled(isDisabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        SpinButton(
            isSpinning: false,
            gradientRotation: 0,
            isDisabled: false,
            action: {}
        )

        SpinButton(
            isSpinning: true,
            gradientRotation: 45,
            isDisabled: true,
            action: {}
        )
    }
    .padding()
    .background(Color.App.background)
    .environmentObject(AppEnvironment())
}
