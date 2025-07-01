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

    // Función para obtener la información del dólar con headers
    func getDollarRates() async throws -> DollarResponse {
        let url = URL(string: "https://api.dolaraldiavzla.com/api/v1/dollar?page=alcambio")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Header igual que en tu ejemplo
        request.setValue("Bearer 2x9Qjpxl5F8CoKK6T395KA", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let dollarResponse = try JSONDecoder().decode(DollarResponse.self, from: data)
        return dollarResponse
    }
}

