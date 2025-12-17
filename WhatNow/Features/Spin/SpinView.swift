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
    @State private var selectedIndex = 0
    @State private var spinOffset: CGFloat = 0
    @State private var hasAppeared = false

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
                        selectedIndex: $selectedIndex
                    )

                    Spacer()

                    // Spin Button
                    Button(action: spin) {
                        HStack(spacing: 12) {
                            Image(systemName: isSpinning ? "arrow.triangle.2.circlepath" : "sparkles")
                                .font(.system(size: 24, weight: .semibold))
                                .rotationEffect(.degrees(isSpinning ? 360 : 0))
                                .animation(
                                    isSpinning ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                                    value: isSpinning
                                )

                            Text(isSpinning ? "Spinning..." : "SPIN")
                                .font(.appTitle3)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.App.text,
                                            Color.App.textSecondary
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isSpinning)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
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

        // Random number of spins (simulate fast spin then slow down)
        let baseSpins = 20
        let randomExtra = Int.random(in: 0..<viewModel.stores.count)
        let targetIndex = (selectedIndex + baseSpins + randomExtra) % viewModel.stores.count

        // Animate with easing
        withAnimation(.easeInOut(duration: 0.3)) {
            // Fast start
            selectedIndex = (selectedIndex + 5) % viewModel.stores.count
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 2.5)) {
                selectedIndex = targetIndex
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                isSpinning = false
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
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
