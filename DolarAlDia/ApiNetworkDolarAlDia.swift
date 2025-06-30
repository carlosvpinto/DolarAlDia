//
//  Untitled.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 6/30/25.
//

import Foundation

class ApiNetworkDolarAlDia {

    // Estructura principal del modelo
    struct DollarResponse: Codable {
        let datetime: DateTime
        let monitors: Monitors
    }

    // Estructura de fecha y hora
    struct DateTime: Codable {
        let date: String
        let time: String
    }

    // Estructura de los monitores (solo los que aparecen en tu JSON de ejemplo)
    struct Monitors: Codable {
        let bcv: MonitorDetail
        let bcvEur: MonitorDetail
        let enparalelovzla: MonitorDetail

        enum CodingKeys: String, CodingKey {
            case bcv
            case bcvEur = "bcv_eur"
            case enparalelovzla
        }
    }

    // Detalles de cada monitor
    struct MonitorDetail: Codable, Identifiable {
        var id: String { title }
        let change: Double
        let changeOld: Double
        let color: String
        let image: String?
        let lastUpdate: String
        let lastUpdateOld: String?
        let percent: Double
        let percentOld: Double
        let price: Double
        let priceOld: Double
        let priceOlder: Double?
        let symbol: String
        let title: String

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

    // Función para obtener la información del dólar
    func getDollarRates() async throws -> DollarResponse {
        let url = URL(string: "https://api.dolaraldiavzla.com/api/v1/dollar?page=alcambio")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Si la API requiere headers, agrégalos aquí

        let (data, _) = try await URLSession.shared.data(for: request)
        let dollarResponse = try JSONDecoder().decode(DollarResponse.self, from: data)
        return dollarResponse
    }
}
