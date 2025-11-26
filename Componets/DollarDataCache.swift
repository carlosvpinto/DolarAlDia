//
//  DollarDataCache.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 7/28/25.
//

import Foundation

// Esta estructura contiene todos los datos que queremos guardar y cargar.
// Al ser Codable, podemos convertirla a y desde JSON fácilmente.
struct DollarDataCache: Codable {
    // Datos BCV
    let tasaBCV: Double
    let porcentajeBcv: String
    let simboloBcv: String
    let fechaActualizacionBCV: String
    
    // Datos Euro
    let tasaEuro: Double
    let porcentajeEuro: String
    let simboloEuro: String
    // <-- CORRECCIÓN: Añadido para guardar la fecha del Euro
    let fechaActualizacionEuro: String
    
    // Datos USDT
    let tasaUSDT: Double
    let porcentajeUSDT: String
    let simboloUSDT: String
    let fechaActualizacionUSDT: String
    
    // Metadatos
    let timestamp: Date // Guardamos la fecha para saber cuándo se guardó
}


struct CacheManager {
    static let shared = CacheManager()
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "lastDollarRates" // Clave para los datos de tasas

    // Guarda los datos de las tasas en UserDefaults
    func save(data: DollarDataCache) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            userDefaults.set(encodedData, forKey: cacheKey)
            print("✅ Datos de tasas guardados en caché.")
        } catch {
            print("❌ Error al guardar los datos de tasas en caché: \(error)")
        }
    }

    // Carga los datos de las tasas desde UserDefaults
    func load() -> DollarDataCache? {
        guard let savedData = userDefaults.data(forKey: cacheKey) else {
            return nil
        }
        
        do {
            let decodedData = try JSONDecoder().decode(DollarDataCache.self, from: savedData)
            return decodedData
        } catch {
            // <-- MEJORA: Añadido para depurar errores de carga
            print("❌ Error al cargar los datos de tasas desde el caché: \(error)")
            return nil
        }
    }
    
    // --- Lógica para Platform Data Cache (Sin Cambios) ---
    private let platformCacheKey = "platformDataCache"

    // Función para guardar los datos de las plataformas
    func savePlatforms(data: PlatformDataCache) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            UserDefaults.standard.set(encodedData, forKey: platformCacheKey)
            print("✅ Datos de plataformas guardados en caché.")
        } catch {
            print("❌ Error al guardar datos de plataformas en caché: \(error)")
        }
    }

    // Función para cargar los datos de las plataformas
    func loadPlatforms() -> PlatformDataCache? {
        guard let savedData = UserDefaults.standard.data(forKey: platformCacheKey) else {
            return nil
        }
        
        do {
            let decodedData = try JSONDecoder().decode(PlatformDataCache.self, from: savedData)
            return decodedData
        } catch {
            print("❌ Error al cargar datos de plataformas desde el caché: \(error)")
            return nil
        }
    }
}
