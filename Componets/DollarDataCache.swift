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
    let tasaBCV: Double
    let tasaEuro: Double
    let porcentajeBcv: String
    let porcentajeParalelo: String
    let simboloBcv: String
    let simboloParalelo: String
    let fechaActualizacionBCV: String
    let fechaActualizacionParalelo: String
    let timestamp: Date // Guardamos la fecha para saber cuándo se guardó
}


struct CacheManager {
    static let shared = CacheManager()
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "lastDollarRates" // Una clave única para guardar los datos

    // Guarda los datos en UserDefaults
    func save(data: DollarDataCache) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            userDefaults.set(encodedData, forKey: cacheKey)
        } catch {
            print("Error al guardar los datos en caché: \(error)")
        }
    }

    // Carga los datos desde UserDefaults
    func load() -> DollarDataCache? {
        guard let savedData = userDefaults.data(forKey: cacheKey) else {
            return nil
        }
        
        do {
            let decodedData = try JSONDecoder().decode(DollarDataCache.self, from: savedData)
            return decodedData
        } catch {
           
            return nil
        }
    }
}
