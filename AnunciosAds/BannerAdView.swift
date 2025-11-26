//
//  BannerAdView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 10/13/25.
//
// BannerAdView.swift

import SwiftUI
import GoogleMobileAds

// Usamos UIViewRepresentable para envolver la vista del banner de UIKit (GADBannerView)
struct BannerAdView: UIViewRepresentable {
    
    // 1. El ID de tu bloque de anuncios de banner de AdMob
    // USA ESTE ID DE PRUEBA MIENTRAS DESARROLLAS
    //private let adUnitID = "ca-app-pub-3940256099942544/2934735716"
    private let adUnitIDBanner = Constants.adUnitIDBanner

    func makeUIView(context: Context) -> BannerView {
        // 2. Crear la vista del banner
        let bannerView = BannerView(adSize: AdSizeBanner) // Tamaño estándar de banner (320x50)
        bannerView.adUnitID = adUnitIDBanner
        
        // 3. Encontrar el "root view controller" para que el banner sepa dónde mostrarse
        bannerView.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first?
            .rootViewController
        
        // 4. Cargar el anuncio
        bannerView.load(Request())
        
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // Esta función se deja vacía para un banner simple
    }
}
