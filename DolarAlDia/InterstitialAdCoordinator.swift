//
//  InterstitialAdCoordinator.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 10/6/25.
//
import Foundation
import GoogleMobileAds

// Esta clase manejará toda la lógica de cargar y mostrar anuncios intersticiales.
// Usamos NSObject y FullScreenContentDelegate para saber cuándo el usuario cierra el anuncio.
class InterstitialAdCoordinator: NSObject, FullScreenContentDelegate {

    // Usamos un 'singleton' para que solo haya una instancia de este coordinador en toda la app.
    static let shared = InterstitialAdCoordinator()

    private var interstitialAd: InterstitialAd?

    // En InterstitialAdCoordinator.swift

    func loadAd(completion: (() -> Void)? = nil) {
        guard interstitialAd == nil else {
            completion?()
            return
        }

        let adUnitID = "ca-app-pub-3940256099942544/4411468910" // ID de prueba
        
        let request = Request()
        InterstitialAd.load(with: adUnitID, request: request) { ad, error in
            if let error = error {
                print("Error al cargar el anuncio intersticial: \(error.localizedDescription)")
                return
            }
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            
            // Avisamos que el anuncio ya se cargó
            completion?()
        }
    }
    
    
    // Función para mostrar el anuncio si está listo.
    func showAd() {
        guard let ad = interstitialAd else {
            print("El anuncio no está listo para ser mostrado. Intenta cargarlo primero.")
            // Opcional: Carga el siguiente anuncio para la próxima vez.
            loadAd()
            return
        }

        // Buscamos el 'rootViewController' de la aplicación para presentar el anuncio.
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            ad.present(from: rootViewController)
        }
    }
    
    
 
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
           // Descartamos el anuncio usado para que se pueda cargar uno nuevo la próxima vez.
           interstitialAd = nil
       }
}
