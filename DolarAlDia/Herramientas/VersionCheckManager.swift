//
//  VersionCheckManager.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 11/26/25.
//

// VersionCheckManager.swift (nuevo archivo)

import Foundation
import Combine
/*
class VersionCheckManager: ObservableObject {
    
    // Esta propiedad avisará a nuestra vista si se necesita una actualización.
    @Published var needsUpdate: Bool = false
    
    // Almacena la URL de tu app en la App Store
    let appStoreURL = URL(string: "https://apps.apple.com/us/app/dolar-al-dia-venezuela/id6743636151")! // ⚠️ REEMPLAZA ESTO
    
    func checkAppVersion() {
        // 1. Obtiene la versión requerida desde Remote Config
        guard let requiredVersionString = RemoteConfigManager.shared.config.configValue(forKey: "ios_minimum_required_version").stringValue else {
            print("❌ No se encontró la versión requerida en Remote Config.")
            return
        }
        
        // 2. Obtiene la versión actual de la app
        let currentVersionString = AppInfo.version
        
        print("🔍 Versión Actual: \(currentVersionString), Versión Requerida: \(requiredVersionString)")
        
        // 3. Compara las versiones
        //    .numeric compara "1.10" como mayor que "1.9", que es lo que queremos.
        if currentVersionString.compare(requiredVersionString, options: .numeric) == .orderedAscending {
            // La versión actual es MENOR que la requerida.
            print("🔴 ¡Actualización requerida!")
            DispatchQueue.main.async {
                self.needsUpdate = true
            }
        } else {
            // La versión actual es igual o mayor. Todo está bien.
            print("✅ La app está actualizada.")
            DispatchQueue.main.async {
                self.needsUpdate = false
            }
        }
    }
}
*/
