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

#Preview("All Malls Logos") {
    let mallLogos = [
        "https://cdn.brandfetch.io/id3GuyfxAj/w/180/h/180/theme/dark/logo.png?c=1bxid64Mup7aczewSAYMX&t=1764734785217",
        "https://cdn.brandfetch.io/idUxmS3_l8/w/558/h/72/theme/dark/logo.png?c=1bxid64Mup7aczewSAYMX&t=1761675749242",
        "https://cdn.brandfetch.io/idl4OesdFy/theme/dark/logo.svg?c=1bxid64Mup7aczewSAYMX&t=1763119917365",
        "https://cdn.brandfetch.io/id9sNpiqC0/theme/dark/logo.svg?c=1bxid64Mup7aczewSAYMX&t=1740111645120",
        "https://cdn.brandfetch.io/idrnDzHeZx/w/183/h/70/theme/dark/logo.png?c=1bxid64Mup7aczewSAYMX&t=1765420735594",
        "https://www.mbk-center.co.th/img/logo.svg",
        "https://cdn.brandfetch.io/idnVOzSnyI/w/391/h/89/theme/dark/logo.png?c=1bxid64Mup7aczewSAYMX&t=1759157210397",
        "https://cdn.brandfetch.io/idBCwV7F8S/w/61/h/53/theme/light/logo.png?c=1bxid64Mup7aczewSAYMX&t=1707562471732",
        "https://cdn.brandfetch.io/idv8PCZ742/w/238/h/29/theme/dark/logo.png?c=1bxid64Mup7aczewSAYMX&t=1734184158442"
    ]
    
    let mallNames = [
        "Siam Paragon", "centralwOrld", "ICONSIAM", "EmSphere",
        "MEGA Bangna", "MBK Center", "Terminal 21 Asok",
        "The Mall LifeStore", "One Bangkok"
    ]

    ScrollView {
        VStack(spacing: 30) {
            ForEach(0..<mallLogos.count, id: \.self) { index in
                VStack(spacing: 8) {
                    Text(mallNames[index])
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.secondary)
                    
                    AsyncImageWithFallback(
                        imageUrl: mallLogos[index],
                        size: 100
                    )
                    
                    Divider()
                        .padding(.horizontal, 40)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.App.background)
    }
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
