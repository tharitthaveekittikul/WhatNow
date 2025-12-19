//
//  AsyncImageWithFallback.swift
//  WhatNow
//
//  Reusable async image component with fallback icon
//

import SwiftUI

/// Displays an async image with a fallback icon if the URL is nil or fails to load
struct AsyncImageWithFallback: View {
    let imageUrl: String?
    let fallbackIcon: String
    let size: CGFloat
    let cornerRadius: CGFloat
    let showGradientBackground: Bool

    init(
        imageUrl: String?,
        fallbackIcon: String = "fork.knife.circle.fill",
        size: CGFloat = 64,
        cornerRadius: CGFloat = 14,
        showGradientBackground: Bool = true
    ) {
        self.imageUrl = imageUrl
        self.fallbackIcon = fallbackIcon
        self.size = size
        self.cornerRadius = cornerRadius
        self.showGradientBackground = showGradientBackground
    }

    var body: some View {
        Group {
            if let urlString = imageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        loadingView
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    case .failure:
                        fallbackView
                    @unknown default:
                        fallbackView
                    }
                }
            } else {
                fallbackView
            }
        }
        .frame(width: size, height: size)
    }

    private var loadingView: some View {
        ZStack {
            if showGradientBackground {
                gradientBackground
            }
            ProgressView()
                .tint(.App.text.opacity(0.5))
        }
        .frame(width: size, height: size)
    }

    private var fallbackView: some View {
        ZStack {
            if showGradientBackground {
                gradientBackground
            }
            Image(systemName: fallbackIcon)
                .font(.system(size: size * 0.44, weight: .medium))
                .foregroundColor(.App.text.opacity(0.7))
                .symbolRenderingMode(.hierarchical)
        }
        .frame(width: size, height: size)
    }

    private var gradientBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.App.accentSky.opacity(0.25),
                        Color.App.accentLavender.opacity(0.25)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

#Preview("With URL") {
    VStack(spacing: 20) {
        AsyncImageWithFallback(
            imageUrl: "https://picsum.photos/200",
            size: 80
        )

        AsyncImageWithFallback(
            imageUrl: "https://picsum.photos/200",
            size: 120,
            cornerRadius: 60
        )
    }
    .padding()
    .background(Color.App.background)
}

#Preview("Fallback") {
    VStack(spacing: 20) {
        AsyncImageWithFallback(
            imageUrl: nil,
            size: 80
        )

        AsyncImageWithFallback(
            imageUrl: "invalid-url",
            fallbackIcon: "building.2.fill",
            size: 80
        )
    }
    .padding()
    .background(Color.App.background)
}
