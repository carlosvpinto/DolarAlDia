//
//  RemoteConfigManager.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 11/11/25.
//
import Foundation
import FirebaseRemoteConfig

class RemoteConfigManager {
    
    static let shared = RemoteConfigManager()
    
    private var remoteConfig: RemoteConfig
    
    // 👇 1. AÑADE LA NUEVA CLAVE AQUÍ
       private enum ParameterKeys: String {
           case showInterstitialAd
           case showBannerAd
           case showRewardedAd
           case ios_minimum_required_version // <-- Nueva clave
       }
    
    private init() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        setupDefaults()
    }
    
    /// Configura los valores por defecto. La app usará esto si no hay conexión
    /// o si es la primera vez que se abre.
    private func setupDefaults() {
        let defaultValues: [String: NSObject] = [
            ParameterKeys.showInterstitialAd.rawValue: true as NSObject,
            ParameterKeys.showBannerAd.rawValue: true as NSObject,
            ParameterKeys.showRewardedAd.rawValue: true as NSObject,
            // 👇 2. AÑADE UN VALOR POR DEFECTO PARA LA VERSIÓN
            ParameterKeys.ios_minimum_required_version.rawValue: "1.0" as NSObject
        ]
        remoteConfig.setDefaults(defaultValues)
    }
    
    /// Busca los últimos valores de la consola de Firebase.
    // En RemoteConfigManager.swift
    // En RemoteConfigManager.swift

    // En RemoteConfigManager.swift
    func fetchConfig(completion: (() -> Void)? = nil) {
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #endif
        remoteConfig.configSettings = settings

        remoteConfig.fetchAndActivate { status, error in
            if let error = error {
                print("❌ Error al obtener Remote Config: \(error.localizedDescription)")
                // Aún llamamos a completion() en caso de error para que la app continúe.
                completion?()
                return
            }
            
            switch status {
            case .successFetchedFromRemote:
                print("✅ Remote Config: Configuración activada con éxito.")
            case .error:
                print("❌ Remote Config: Error al activar la configuración.")
            @unknown default:
                print("⚠️ Remote Config: Estado desconocido.")
            }
            
            // 👇 LLAMA AL COMPLETION HANDLER AQUÍ, DESPUÉS DE QUE TODO HAYA TERMINADO.
            completion?()
        }
    }
    // MARK: - Propiedades de Acceso
    
    var showInterstitialAd: Bool {
        remoteConfig.configValue(forKey: ParameterKeys.showInterstitialAd.rawValue).boolValue
    }
    
    var showBannerAd: Bool {
        remoteConfig.configValue(forKey: ParameterKeys.showBannerAd.rawValue).boolValue
    }
    
    var showRewardedAd: Bool {
        remoteConfig.configValue(forKey: ParameterKeys.showRewardedAd.rawValue).boolValue
    }
    

    //    Esta propiedad nos dará directamente la versión requerida como un String.
    var minimumRequiredVersion: String {
        remoteConfig.configValue(forKey: ParameterKeys.ios_minimum_required_version.rawValue).stringValue ?? "1.0"
    }
}
