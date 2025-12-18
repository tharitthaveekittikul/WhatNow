//
//  SpinView.swift
//  WhatNow
//
//  Spin View - Main spinning interface
//

import SwiftUI

struct SpinView: View {
    let mall: Mall

    @StateObject private var viewModel: SpinViewModel
    @State private var isSpinning = false
    @State private var reelIndex: Int = 0  // Monotonic index that increases indefinitely
    @State private var hasAppeared = false
    @State private var gradientRotation: Double = 0

    private let logger = DependencyContainer.shared.logger

    init(mall: Mall) {
        self.mall = mall
        _viewModel = StateObject(wrappedValue: SpinViewModel(mall: mall))
    }

    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .tint(.App.text)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text("Error")
                        .font(.appTitle2)
                        .foregroundColor(.App.text)

                    Text(errorMessage)
                        .font(.appBody)
                        .foregroundColor(.App.textSecondary)
                        .multilineTextAlignment(.center)

                    Button("Try Again") {
                        Task {
                            await viewModel.loadStores()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
            } else if !viewModel.stores.isEmpty {
                VStack(spacing: 32) {
                    // Mall name
                    VStack(spacing: 8) {
                        Text(mall.displayName)
                            .font(.appTitle2)
                            .foregroundColor(.App.text)

                        Text("\(viewModel.stores.count) stores")
                            .font(.appCallout)
                            .foregroundColor(.App.textSecondary)
                    }

                    Spacer()

                    // Reel Picker
                    ReelPicker(
                        items: viewModel.stores,
                        isSpinning: $isSpinning,
                        reelIndex: $reelIndex
                    )

                    Spacer()

                    // Spin Button
                    Button(action: spin) {
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
                            Text(isSpinning ? "Spinning…" : "SPIN")
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
                                                Color.App.accentSky,
                                                Color.App.accentLavender,
                                                Color.App.accentWarm,
                                                Color.App.accentSky
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
                                                    Color.white.opacity(0.15),
                                                    Color.white.opacity(0)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .blur(radius: 8)
                                        .hueRotation(.degrees(gradientRotation / 2))
                                }
                            }
                        )
                        // Glow effect
                        .shadow(
                            color: isSpinning ? Color.App.accentSky.opacity(0.5) : Color.black.opacity(0.2),
                            radius: isSpinning ? 24 : 10,
                            x: 0,
                            y: isSpinning ? 8 : 5
                        )
                        .scaleEffect(isSpinning ? 0.98 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: isSpinning)
                    }
                    .disabled(isSpinning)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .onChange(of: isSpinning) { spinning in
                        if spinning {
                            // Start gradient rotation animation
                            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                                gradientRotation = 360
                            }
                        } else {
                            // Reset gradient rotation
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                gradientRotation = 0
                            }
                        }
                    }
                }
                .padding(.top, 24)
            }
        }
        .navigationTitle("Random Store")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard !hasAppeared else { return }
            hasAppeared = true
            await viewModel.loadStores()
        }
    }

    private func spin() {
        guard !isSpinning, !viewModel.stores.isEmpty else { return }

        isSpinning = true
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()

        let totalItems = viewModel.stores.count

        // Calculate target with large rotation for suspense
        // Randomize: 10-16 full spins + random position within items
        let fullSpins = Int.random(in: 10...16)
        let randomExtra = Int.random(in: 0..<totalItems)
        let targetReelIndex = reelIndex + (totalItems * fullSpins) + randomExtra

        // Phase 1: Fast acceleration (0.3s) - advance 8 items quickly
        let phase1Duration = 0.3
        let phase1Target = reelIndex + 8

        // TODO: Optional enhancement - add tick haptics during spin
        // Could use a Timer to fire light haptics at regular intervals
        // or trigger sound effects for each item crossing

        generator.impactOccurred()

        if #available(iOS 17.0, *) {
            // iOS 17+: Use animation completion callbacks
            withAnimation(.easeIn(duration: phase1Duration)) {
                reelIndex = phase1Target
            } completion: {
                // Phase 2: Long deceleration (4.5s-5.5s) - suspenseful slowdown
                let phase2Duration = Double.random(in: 4.5...5.5)
                generator.impactOccurred()

                withAnimation(.timingCurve(0.22, 0.61, 0.36, 1.0, duration: phase2Duration)) {
                    reelIndex = targetReelIndex
                } completion: {
                    onSpinComplete()
                }
            }
        } else {
            // iOS 16: Fallback to DispatchQueue
            withAnimation(.easeIn(duration: phase1Duration)) {
                reelIndex = phase1Target
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + phase1Duration) {
                let phase2Duration = Double.random(in: 4.5...5.5)
                generator.impactOccurred()

                withAnimation(.timingCurve(0.22, 0.61, 0.36, 1.0, duration: phase2Duration)) {
                    reelIndex = targetReelIndex
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + phase2Duration) {
                    self.onSpinComplete()
                }
            }
        }
    }

    private func onSpinComplete() {
        isSpinning = false

        // Strong haptic at the end
        let endFeedback = UIImpactFeedbackGenerator(style: .heavy)
        endFeedback.impactOccurred()

        // Calculate final selected store index safely
        let totalItems = viewModel.stores.count
        let finalIndex = ((reelIndex % totalItems) + totalItems) % totalItems
        let selectedStore = viewModel.stores[finalIndex]

        logger.info("🎰 Spin result: \(selectedStore.displayName) (Price: \(selectedStore.priceRange.displayText), Tags: \(selectedStore.tags.joined(separator: ", ")))")
    }
}

#Preview {
    NavigationStack {
        SpinView(
            mall: Mall(
                mallId: "siam-paragon",
                name: LocalizedName(th: "สยามพารากอน", en: "Siam Paragon"),
                displayName: "สยามพารากอน",
                city: "Bangkok",
                assetKey: "mall_paragon",
                tags: ["bts", "tourist"]
            )
        )
    }
}
