//
//  CustomSpinViewModel.swift
//  WhatNow
//
//  ViewModel for Custom Spin
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class CustomSpinViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var items: [CustomSpinItem] = []
    @Published var isSpinning = false
    @Published var reelIndex = 0
    @Published var gradientRotation: Double = 0
    @Published var showResult = false
    @Published var selectedItem: CustomSpinItem?

    // MARK: - Properties

    let list: CustomSpinList
    private var gradientTimer: Timer?
    private let spinTracker: SpinSessionTracker
    private let interstitialAdManager: InterstitialAdManager

    // MARK: - Initialization

    init(
        list: CustomSpinList,
        spinTracker: SpinSessionTracker? = nil,
        interstitialAdManager: InterstitialAdManager? = nil
    ) {
        self.list = list
        self.items = list.items
        self.spinTracker = spinTracker ?? DependencyContainer.shared.spinSessionTracker
        self.interstitialAdManager = interstitialAdManager ?? DependencyContainer.shared.interstitialAdManager
        reshuffleItems()
    }

    // MARK: - Public Methods

    func reshuffleItems() {
        items = list.items.shuffled()
        reelIndex = 0
    }

    func spin() {
        guard !isSpinning, !items.isEmpty else { return }

        isSpinning = true
        startGradientAnimation()

        // Select random target
        let targetIndex = Int.random(in: 0..<items.count)
        selectedItem = items[targetIndex]

        // Animate to target
        animateToTarget(targetIndex)
    }

    // MARK: - Private Methods

    private func animateToTarget(_ targetIndex: Int) {
        // Fast spin phase
        withAnimation(.easeInOut(duration: 0.3)) {
            reelIndex = targetIndex + items.count * 3  // Spin multiple times
        }

        // Slow deceleration phase
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 2.5)) {
                self.reelIndex = targetIndex + self.items.count * 5
            }

            // Complete spin
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.completeSpinning()
            }
        }
    }

    private func completeSpinning() {
        isSpinning = false
        stopGradientAnimation()

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Track spin completion and show interstitial ad if needed
        Task {
            await interstitialAdManager.recordSpin()

            let shouldShow = await interstitialAdManager.shouldShowInterstitialAfterSpin()
            if shouldShow {
                let shown = await interstitialAdManager.showInterstitial()
                if shown {
                    await interstitialAdManager.recordInterstitialShown()
                }
            }

            // Show result AFTER ad is dismissed (or if no ad was shown)
            await MainActor.run {
                showResult = true
            }
        }
    }

    private func startGradientAnimation() {
        gradientTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            self.gradientRotation += 2
        }
    }

    private func stopGradientAnimation() {
        gradientTimer?.invalidate()
        gradientTimer = nil
        gradientRotation = 0
    }
}
