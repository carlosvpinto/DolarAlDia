//
//  Untitled.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 6/30/25.
//

import Foundation

class ApiNetworkDolarAlDia {

    struct DollarResponse: Codable {
        let datetime: DateTime
        let monitors: Monitors
    }

    struct DateTime: Codable {
        let date: String
        let time: String
    }
    
    typealias Monitors = [String: MonitorDetail]

    struct MonitorDetail: Codable, Identifiable {
        var id: String { title }
        let change: Double
        let color: String
        let image: String?
        let lastUpdate: String
        let percent: Double
        let price: Double
        let priceOld: Double
        let priceOlder: Double?
        let symbol: String
        let title: String

        // --- CORRECCIÓN AQUÍ ---
        // Estas propiedades ahora son opcionales (?) porque la API puede no enviarlas.
        // Esto soluciona la advertencia que estás viendo.
        let changeOld: Double?
        let lastUpdateOld: String?
        let percentOld: Double?
        
        enum CodingKeys: String, CodingKey {
            case change
            case changeOld = "change_old"
            case color
            case image
            case lastUpdate = "last_update"
            case lastUpdateOld = "last_update_old"
            case percent
            case percentOld = "percent_old"
            case price
            case priceOld = "price_old"
            case priceOlder = "price_older"
            case symbol
            case title
        }
    }

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
