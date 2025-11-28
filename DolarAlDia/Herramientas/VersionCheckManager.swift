//
//  VersionCheckManager.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 11/26/25.
//

// VersionCheckManager.swift (nuevo archivo)

import Foundation
import Combine

class VersionCheckManager: ObservableObject {
    
    @Published var needsUpdate: Bool = false
    
    // ⚠️ RECUERDA REEMPLAZAR "TU-APP-ID" con el ID real de tu app.
    let appStoreURL = URL(string: "https://apps.apple.com/us/app/dolar-al-dia-venezuela/id6743636151")!
    
    func checkAppVersion() {
        // 👇 ESTA ES LA LÍNEA QUE CAMBIAMOS
        
        // CÓDIGO ANTIGUO (INCORRECTO):
        // guard let requiredVersionString = RemoteConfigManager.shared.config.configValue(...)
        
        // ✅ CÓDIGO NUEVO (SÚPER LIMPIO):
        //    Ahora simplemente accedemos a la nueva propiedad de nuestro manager.
        let requiredVersionString = RemoteConfigManager.shared.minimumRequiredVersion
        
        // El resto de la función no cambia...
        let currentVersionString = AppInfo.version
        
        print("🔍 Versión Actual: \(currentVersionString), Versión Requerida: \(requiredVersionString)")
        
        if currentVersionString.compare(requiredVersionString, options: .numeric) == .orderedAscending {
            print("🔴 ¡Actualización requerida!")
            DispatchQueue.main.async {
                self.needsUpdate = true
            }
        } else {
            print("✅ La app está actualizada.")
            DispatchQueue.main.async {
                self.needsUpdate = false
            }
        }
    }
}
