//
//  AdBannerView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 10/6/25.
//

import SwiftUI
import GoogleMobileAds

struct AdBannerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let view = BannerView(adSize: AdSizeBanner)
        let viewController = UIViewController()
        view.adUnitID = "ca-app-pub-3265312813580307/6346118437" // Reemplaza con tu ID de bloque de anuncios
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: AdSizeBanner.size)
        view.load(Request())
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
