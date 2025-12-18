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
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @State private var isSpinning = false
    @State private var reelIndex: Int = 0  // Monotonic index that increases indefinitely
    @State private var hasAppeared = false
    @State private var gradientRotation: Double = 0
    @State private var selectedStore: Store?  // Store to show in detail view
    @State private var showStoreDetail = false
    @State private var showStoreList = false
    @State private var shuffledStores: [Store] = []  // Shuffled stores for fair display

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
                    Text("Error".localized(for: appEnvironment.currentLanguage))
                        .font(.appTitle2)
                        .foregroundColor(.App.text)

                    Text(errorMessage)
                        .font(.appBody)
                        .foregroundColor(.App.textSecondary)
                        .multilineTextAlignment(.center)

                    Button("Try Again".localized(for: appEnvironment.currentLanguage)) {
                        Task {
                            await viewModel.loadStores()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
            } else if !shuffledStores.isEmpty {
                VStack(spacing: 32) {
                    // Mall name with See All button
                    HStack {
                        Spacer()

                        VStack(spacing: 8) {
                            Text(mall.name.localized(for: appEnvironment.currentLanguage))
                                .font(.appTitle2)
                                .foregroundColor(.App.text)

                            Text("\(viewModel.stores.count) stores".localized(for: appEnvironment.currentLanguage))
                                .font(.appCallout)
                                .foregroundColor(.App.textSecondary)
                        }

                        Spacer()

                        // See All button
                        Button(action: { showStoreList = true }) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.App.text)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Color.App.surface)
                                )
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    // Reel Picker with shuffled stores
                    ReelPicker(
                        items: shuffledStores,
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
        .navigationTitle("Random Store".localized(for: appEnvironment.currentLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showStoreDetail) {
            if let store = selectedStore {
                NavigationStack {
                    StoreDetailView(store: store, mall: mall, showSpinAgain: true)
                }
            }
        }
        .sheet(isPresented: $showStoreList) {
            NavigationStack {
                StoreListView(stores: viewModel.stores, mall: mall)
            }
        }
        .task {
            guard !hasAppeared else { return }
            hasAppeared = true
            await viewModel.loadStores()
        }
        .onChange(of: viewModel.stores) { newStores in
            // Shuffle stores and set random starting position when stores load
            if !newStores.isEmpty {
                shuffledStores = newStores.shuffled()
                reelIndex = Int.random(in: 0..<shuffledStores.count)
            }
        }
        .onAppear {
            // Re-shuffle and randomize position every time view appears
            if !viewModel.stores.isEmpty {
                shuffledStores = viewModel.stores.shuffled()
                reelIndex = Int.random(in: 0..<shuffledStores.count)
            }
        }
        .id(appEnvironment.languageDidChange) // Refresh when language changes
    }

    private func spin() {
        guard !isSpinning, !shuffledStores.isEmpty else { return }

        isSpinning = true
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()

        let totalItems = shuffledStores.count

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

        // Calculate final selected store index safely from shuffled array
        let totalItems = shuffledStores.count
        let finalIndex = ((reelIndex % totalItems) + totalItems) % totalItems
        let store = shuffledStores[finalIndex]

        let storeName = store.name.localized(for: appEnvironment.currentLanguage)
        logger.info("🎰 Spin result: \(storeName) (Price: \(store.priceRange.displayText), Tags: \(store.tags.joined(separator: ", ")))")

        // Set selected store first, then show sheet after state commits
        selectedStore = store

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showStoreDetail = true
        }
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
