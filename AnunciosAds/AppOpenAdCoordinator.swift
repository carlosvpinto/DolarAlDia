//
//  AppOpenAdCoordinator.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 11/29/25.
//
// AppOpenAdCoordinator.swift

import GoogleMobileAds
import UIKit

class AppOpenAdCoordinator: NSObject, FullScreenContentDelegate {

    static let shared = AppOpenAdCoordinator()

    private var appOpenAd: AppOpenAd?
    private var isLoadingAd = false
    private var isShowingAd = false
    
    // Google requiere que un anuncio de inicio no se muestre si tiene más de 4 horas.
    private var loadTime: Date?
    
    //👇 NUEVA PROPIEDAD
    private var isFirstLaunch = true
    // Añade una propiedad para AdState
    
    // 👇 Propiedad para acceder al estado de la recompensa
    private weak var adState: AdState?
        

    override private init() {
        super.init()
    }
    
    // Nueva función para configurar AdState
    func configure(with adState: AdState) {
        self.adState = adState
    }

    /// Carga un nuevo anuncio de inicio de app.
    func loadAd() {
        // Evitamos cargar un anuncio si ya estamos en proceso o si ya hay uno listo.
        guard !isLoadingAd, appOpenAd == nil else {
            print("INFO (AppOpen): Ya hay un anuncio cargando o listo. No se cargará uno nuevo.")
            return
        }
        
        isLoadingAd = true
        print("DEBUG (AppOpen): Iniciando la carga del anuncio de inicio...")
        
        let request = Request()
        AppOpenAd.load(with: Constants.adUnitIDAppOpen, request: request) { ad, error in
            self.isLoadingAd = false
            if let error = error {
                print("DEBUG (AppOpen): ❌ FALLÓ la carga. Error: \(error.localizedDescription)")
                self.appOpenAd = nil
                self.loadTime = nil
                return
            }
            
            print("DEBUG (AppOpen): ✅ Anuncio CARGADO y listo.")
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date()
            
            // 👇 LÓGICA MEJORADA
            // Si es la primera carga (lanzamiento de la app), intentamos mostrar el anuncio inmediatamente.
            if self.isFirstLaunch {
                print("DEBUG (AppOpen): Es el primer lanzamiento, intentando mostrar el anuncio ahora.")
                self.showAdIfReady()
                self.isFirstLaunch = false // Marcamos que ya no es el primer lanzamiento.
            }
        }
    }

    /// Intenta mostrar el anuncio si está listo y las condiciones son adecuadas.
    func showAdIfReady() {
        print("--- 🔍 DIAGNÓSTICO DE ANUNCIO DE INICIO (AppOpen) 🔍 ---")

        // Condición 1: ¿Remote Config nos permite mostrar el anuncio?
        guard RemoteConfigManager.shared.showAppOpenAd else {
            print("RESULTADO: ❌ No se mostró. Causa: Remote Config ('showAppOpenAd') está en 'false'.")
            print("--- FIN DEL DIAGNÓSTICO ---")
            return
        }
        print("✅ Condición 1/4 PASADA: Remote Config lo permite.")

        // Condición 2: ¿La app está en período sin anuncios (recompensa activa)?
        guard !(adState?.isAdFree ?? false) else {
            print("RESULTADO: ❌ No se mostró. Causa: La app está en período sin anuncios (recompensa activa).")
            print("--- FIN DEL DIAGNÓSTICO ---")
            return
        }
        print("✅ Condición 2/4 PASADA: No hay recompensa activa.")

        // Condición 3: ¿Ya hay otro anuncio de pantalla completa visible?
        guard !isShowingAd else {
            print("RESULTADO: ❌ No se mostró. Causa: Otro anuncio ya está visible.")
            print("--- FIN DEL DIAGNÓSTICO ---")
            return
        }
        print("✅ Condición 3/4 PASADA: No hay otro anuncio en pantalla.")

        // Condición 4: ¿Tenemos un anuncio cargado y válido?
        guard let ad = appOpenAd, let loadTime = loadTime, Date().timeIntervalSince(loadTime) < 14400 else {
            if appOpenAd == nil {
                print("RESULTADO: ⚠️ No hay anuncio listo. Se solicita uno nuevo.")
            } else {
                print("RESULTADO: ⚠️ Anuncio expirado. Se solicita uno nuevo.")
                self.appOpenAd = nil
            }
            loadAd() // Solicitamos un nuevo anuncio en ambos casos
            print("--- FIN DEL DIAGNÓSTICO ---")
            return
        }
        print("✅ Condición 4/4 PASADA: Hay un anuncio cargado y válido.")

        // Si todas las condiciones pasan, intentamos mostrar el anuncio.
        guard let root = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first?.windows.first?.rootViewController else {
            print("RESULTADO: ❌ No se pudo encontrar un Root ViewController.")
            print("--- FIN DEL DIAGNÓSTICO ---")
            return
        }
        
        print("RESULTADO: ✅ ¡Mostrando el anuncio!")
        print("--- FIN DEL DIAGNÓSTICO ---")
    
        ad.present(from: root)
    }

    // MARK: - GADFullScreenContentDelegate

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowingAd = true
        print("DEBUG (AppOpen): 👀 El anuncio se va a mostrar.")
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowingAd = false
        // El anuncio se ha cerrado. Lo ponemos en nil y precargamos el siguiente.
        appOpenAd = nil
        print("DEBUG (AppOpen): 👋 Anuncio cerrado por el usuario. Precargando el siguiente.")
        loadAd()
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        isShowingAd = false
        print("DEBUG (AppOpen): ❌ Error al presentar el anuncio: \(error.localizedDescription)")
        appOpenAd = nil
        loadAd()
    }
}
