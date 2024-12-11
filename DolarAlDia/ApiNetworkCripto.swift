//
//  ApiNetworkCripto.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/9/24.
//

import Foundation

class ApiNetworkCripto {
    
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
    
    // Estructura de los monitores (contendrá todos los tipos de monitoreo)
    struct Monitors: Codable {
        let amazonGiftCard: MonitorDetail
        let bcv: MonitorDetail
        let binance: MonitorDetail
        let criptoDolar: MonitorDetail
        let dolarToday: MonitorDetail
        let enparalelovzla: MonitorDetail
        let paypal: MonitorDetail
        let skrill: MonitorDetail
        let uphold: MonitorDetail
        
        // Usando `CodingKeys` para mapear los nombres con guiones bajos a camelCase
        enum CodingKeys: String, CodingKey {
            case amazonGiftCard = "amazon_gift_card"
            case bcv
            case binance
            case criptoDolar = "cripto_dolar"
            case dolarToday = "dolar_today"
            case enparalelovzla
            case paypal
            case skrill
            case uphold
        }
    }
    
    // Detalles de cada monitor de tipo dólar
    struct MonitorDetail: Codable, Identifiable {
        var id: String {
            return title
        }
        let change: Double
        let color: String
        let image: String
        let lastUpdate: String
        let percent: Double
        let price: Double
        let priceOld: Double
        let symbol: String
        let title: String
        
        // Usando `CodingKeys` para mapear propiedades que cambian de nombre
        enum CodingKeys: String, CodingKey {
            case change
            case color
            case image
            case lastUpdate = "last_update"
            case percent
            case price
            case priceOld = "price_old"
            case symbol
            case title
        }
    }

    // Función para obtener la información del dólar
    func getDollarRatesCripto() async throws -> DollarResponse {
        // Cambiar la URL a la nueva con el parámetro "criptodolar"
        let url = URL(string: "https://pydolarve.org/api/v1/dollar?page=criptodolar")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer 2x9Qjpxl5F8CoKK6T395KA", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Decodificar los datos en `DollarResponse`
        let dollarResponse = try JSONDecoder().decode(DollarResponse.self, from: data)
        return dollarResponse
    }
}

