//
//  BannerAdView.swift
//  WhatNow
//
//  SwiftUI wrapper for Google Mobile Ads banner ads
//

import SwiftUI
import GoogleMobileAds

/// A SwiftUI view that displays a Google AdMob banner ad
struct BannerAdView: View {

    // MARK: - Properties

    let adUnitID: String
    let adSize: AdSize
    let logger: Logger

    // MARK: - Initialization

    /// Initialize a banner ad view
    /// - Parameters:
    ///   - adUnitID: The AdMob ad unit ID for this banner
    ///   - adSize: The size of the banner ad (default: standard banner)
    ///   - logger: Logger for tracking ad events
    init(adUnitID: String, adSize: AdSize = AdSize(size: CGSize(width: 320, height: 50), flags: 0), logger: Logger) {
        self.adUnitID = adUnitID
        self.adSize = adSize
        self.logger = logger
    }

    // MARK: - Body

    var body: some View {
        BannerViewController(adUnitID: adUnitID, adSize: adSize, logger: logger)
            .frame(width: adSize.size.width, height: adSize.size.height)
    }
}

// MARK: - UIViewControllerRepresentable

private struct BannerViewController: UIViewControllerRepresentable {

    let adUnitID: String
    let adSize: AdSize
    let logger: Logger

    func makeUIViewController(context: Context) -> BannerViewControllerWrapper {
        BannerViewControllerWrapper(adUnitID: adUnitID, adSize: adSize, logger: logger)
    }

    func updateUIViewController(_ uiViewController: BannerViewControllerWrapper, context: Context) {
        // No updates needed
    }
}

// MARK: - Banner View Controller Wrapper

private final class BannerViewControllerWrapper: UIViewController, BannerViewDelegate {

    private let adUnitID: String
    private let adSize: AdSize
    private let logger: Logger
    private var bannerView: BannerView!

    init(adUnitID: String, adSize: AdSize, logger: Logger) {
        self.adUnitID = adUnitID
        self.adSize = adSize
        self.logger = logger
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBannerView()
        loadAd()
    }

    private func setupBannerView() {
        bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(bannerView)

        // Center the banner view
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            bannerView.widthAnchor.constraint(equalToConstant: adSize.size.width),
            bannerView.heightAnchor.constraint(equalToConstant: adSize.size.height)
        ])
    }

    private func loadAd() {
        let request = Request()
        bannerView.load(request)
    }

    // MARK: - BannerViewDelegate

    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        logger.info("Banner ad loaded successfully", category: .networking)
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        logger.error("Banner ad failed to load", category: .networking, error: error)
    }

    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        logger.debug("Banner ad impression recorded", category: .networking)
    }

    func bannerViewWillPresentScreen(_ bannerView: BannerView) {
        logger.debug("Banner ad will present full screen", category: .networking)
    }

    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
        logger.debug("Banner ad will dismiss full screen", category: .networking)
    }

    func bannerViewDidDismissScreen(_ bannerView: BannerView) {
        logger.debug("Banner ad dismissed full screen", category: .networking)
    }
}

// MARK: - Adaptive Banner Helper

extension BannerAdView {
    /// Create a banner ad with adaptive size based on the current view width
    /// This is recommended for responsive design
    /// - Parameters:
    ///   - adUnitID: The AdMob ad unit ID
    ///   - logger: Logger for tracking ad events
    /// - Returns: A BannerAdView with adaptive sizing
    static func adaptive(adUnitID: String, logger: Logger) -> some View {
        let frame = UIScreen.main.bounds
        let viewWidth = frame.size.width

        // Create adaptive banner size using the portrait anchored adaptive banner
        // This automatically adjusts for current orientation
        let adaptiveSize = portraitAnchoredAdaptiveBanner(width: viewWidth)

        return BannerAdView(adUnitID: adUnitID, adSize: adaptiveSize, logger: logger)
            .frame(height: adaptiveSize.size.height)
    }
}

// MARK: - Previews

#Preview("Banner Ad") {
    VStack(spacing: 16) {
        Text("Content above ad")
            .font(.appBody)

        // Use test ad for preview
        BannerAdView(
            adUnitID: "ca-app-pub-3940256099942544/2934735716",
            logger: ConsoleLogger()
        )
        .background(Color.App.surfaceSoft)

        Text("Content below ad")
            .font(.appBody)
    }
    .padding()
    .background(Color.App.background)
}
