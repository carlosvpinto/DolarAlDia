//
//  Untitled.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 6/30/25.
//

import Foundation

class ApiNetworkDolarAlDia {

    // 1. El modelo principal de respuesta sigue siendo el mismo.
    struct DollarResponse: Codable {
        let datetime: DateTime
        let monitors: Monitors // Ahora 'Monitors' será un diccionario
    }

    struct DateTime: Codable {
        let date: String
        let time: String
    }
    
    // 2. ¡ESTE ES EL CAMBIO CLAVE!
    // En lugar de un struct con campos fijos, definimos 'Monitors' como un
    // diccionario donde la clave es el código de la moneda (String) y el valor
    // es el detalle del monitor. Esto lo hace flexible para cualquier moneda.
    typealias Monitors = [String: MonitorDetail]

    // 3. Hemos ajustado este struct para que coincida EXACTAMENTE con los campos
    // del nuevo JSON. Ahora los campos "old" y "priceOlder" no son opcionales.
    struct MonitorDetail: Codable, Identifiable {
        var id: String { title }
        let change: Double
        let color: String
        let image: String? // Sigue siendo opcional porque USDT puede tenerlo en null
        let lastUpdate: String
        let percent: Double
        let price: Double
        let priceOld: Double
        let priceOlder: Double // Ya no es opcional
        let symbol: String
        let title: String

        // Campos "old" que ahora siempre vienen en la respuesta
        let changeOld: Double
        let lastUpdateOld: String
        let percentOld: Double
        
        enum CodingKeys: String, CodingKey {
            case change, color, image, percent, price, symbol, title
            case changeOld = "change_old"
            case lastUpdate = "last_update"
            case lastUpdateOld = "last_update_old"
            case percentOld = "percent_old"
            case priceOld = "price_old"
            case priceOlder = "price_older"
        }
    }

    // 4. La función de llamada a la API NO NECESITA CAMBIOS.
    // La URL es la misma y ahora nuestros modelos pueden decodificar
    // correctamente la nueva respuesta.
    func getDollarRates() async throws -> DollarResponse {
        guard let url = URL(string: "https://api.dolaraldiavzla.com/api/v1/tipo-cambio") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer 2x9Qjpxl5F8CoKK6T395KA", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let dollarResponse = try JSONDecoder().decode(DollarResponse.self, from: data)
        return dollarResponse
    }
}
