import SwiftUI

struct SpinButton: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    let isSpinning: Bool
    let gradientRotation: Double   // kept for compatibility
    let isDisabled: Bool
    let action: () -> Void

    @State private var isPressed = false
    @State private var internalRotation: Double = 0

    private let corner: CGFloat = 22
    private let height: CGFloat = 86   // bigger

    var body: some View {
        Button {
            guard !isDisabled else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            ZStack {
                // MARK: - Base background gradient (adaptive)
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(buttonBackgroundGradient)
                    .overlay(
                        // subtle press darken/lighten overlay
                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .fill(colorScheme == .dark
                                  ? Color.black.opacity(isPressed ? 0.18 : 0.0)
                                  : Color.white.opacity(isPressed ? 0.14 : 0.0)
                            )
                            .animation(.easeOut(duration: 0.12), value: isPressed)
                    )
                    .overlay(
                        // inner highlight stroke to feel premium
                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.14), lineWidth: 1)
                            .opacity(isDisabled ? 0.35 : 1)
                    )

                // MARK: - Center content
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .rotationEffect(.degrees(isSpinning ? 360 : 0))
                        .animation(
                            (isSpinning && !reduceMotion && !isDisabled)
                                ? .linear(duration: 1.6).repeatForever(autoreverses: false)
                                : .spring(response: 0.35, dampingFraction: 0.75),
                            value: isSpinning
                        )

                    Text(titleText)
                        .font(.appTitle3.weight(.bold))
                        .contentTransition(.interpolate)
                }
                .foregroundColor(contentForeground)
                .opacity(isDisabled ? 0.65 : 1.0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))

            // MARK: - Siri rainbow border (crisp)
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(
                        AngularGradient(
                            gradient: Gradient(colors: siriRainbowColors),
                            center: .center,
                            angle: .degrees(currentRotation)
                        ),
                        lineWidth: isSpinning ? 3.5 : 1.8
                    )
                    .opacity(isDisabled ? 0.12 : (isSpinning ? 1.0 : 0.35))
            )

            // MARK: - Glow ring (blurred)
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: siriRainbowColors.map { $0.opacity(0.85) }),
                            center: .center,
                            angle: .degrees(currentRotation)
                        ),
                        lineWidth: isSpinning ? 7 : 4
                    )
                    .blur(radius: isSpinning ? 12 : 14)
                    .opacity(isDisabled ? 0.0 : (isSpinning ? 0.55 : 0.18))
            )

            // MARK: - Depth
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.14),
                radius: isSpinning ? 26 : 16,
                x: 0,
                y: isSpinning ? 12 : 7
            )

            // MARK: - Press feedback
            .scaleEffect(isPressed ? 0.975 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .onAppear { syncRotation() }
        .onChange(of: isSpinning) { _ in syncRotation() }
    }

    // MARK: - Text
    private var titleText: String {
        (isSpinning ? "Spinning…" : "SPIN").localized(for: appEnvironment.currentLanguage)
    }

    // MARK: - Adaptive foreground on top of dark gradient
    private var contentForeground: Color {
        // Because the background is dark-ish gradient, white is the safest
        // But we soften in light mode a bit so it doesn't look too harsh
        return colorScheme == .dark ? Color.white : Color.white.opacity(0.95)
    }

    // MARK: - Background gradient (your idea, but adaptive)
    private var buttonBackgroundGradient: LinearGradient {
        // Use text/textSecondary as requested, but tweak per scheme:
        // - Light: keep it slightly softer (less “black”)
        // - Dark: keep it rich but not crush details
        let start = (colorScheme == .dark)
        ? Color.App.text
        : Color.App.text.opacity(0.92)

        let end = (colorScheme == .dark)
        ? Color.App.textSecondary.opacity(0.95)
        : Color.App.textSecondary.opacity(0.88)

        return LinearGradient(
            gradient: Gradient(colors: [start, end]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Rotation
    private var currentRotation: Double {
        gradientRotation + internalRotation
    }

    private func syncRotation() {
        guard !reduceMotion else { return }

        if isSpinning && !isDisabled {
            internalRotation = 0
            withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
                internalRotation = 360
            }
        } else {
            withAnimation(.easeOut(duration: 0.35)) {
                internalRotation = 0
            }
        }
    }

    // MARK: - Siri Palette
    private var siriRainbowColors: [Color] {
        [
            Color(hex: "FF375F"),
            Color(hex: "FF9F0A"),
            Color(hex: "FFD60A"),
            Color(hex: "30D158"),
            Color(hex: "64D2FF"),
            Color(hex: "5E5CE6"),
            Color(hex: "BF5AF2"),
            Color(hex: "FF375F")
        ]
    }
}


#Preview("SpinButton – Big Gradient (Light/Dark)") {
    VStack(spacing: 18) {
        SpinButton(isSpinning: false, gradientRotation: 0, isDisabled: false, action: {})
        SpinButton(isSpinning: true, gradientRotation: 0, isDisabled: false, action: {})
        SpinButton(isSpinning: true, gradientRotation: 0, isDisabled: true, action: {})
    }
    .padding(20)
    .background(Color.App.background)
    .environmentObject(AppEnvironment())
}

#Preview("SpinButton – Dark") {
    VStack(spacing: 18) {
        SpinButton(isSpinning: false, gradientRotation: 0, isDisabled: false, action: {})
        SpinButton(isSpinning: true, gradientRotation: 0, isDisabled: false, action: {})
    }
    .padding(20)
    .background(Color.App.background)
    .environmentObject(AppEnvironment())
    .preferredColorScheme(.dark)
}
