//
//  APIService.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/2/24.
//

import Foundation

class ApiNetwork {
    
    // Estructura principal del modelo (similar a `Wrapper`)
    struct DollarResponse: Codable {
        let datetime: DateTime
        let monitors: Monitors
    }
    
    // Estructura de fecha y hora
    struct DateTime: Codable {
        let date: String
        let time: String
    }
    
    // Estructura de los monitores (similar a `results`)
    struct Monitors: Codable {
        let bcv: MonitorDetail
        let enparalelovzla: MonitorDetail
    }
    
    // Detalles de cada monitor de tipo dólar (similar a `Superhero`)
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

   
    
    func getDollarRatesBasedOnTime() async throws -> DollarResponse {
        let calendar = Calendar.current
        let now = Date()
        
        let weekday = calendar.component(.weekday, from: now)
        let isWeekend = weekday == 1 || weekday == 7
        
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        
        let currentTimeInMinutes = hour * 60 + minute
        
        if isWeekend || currentTimeInMinutes >= (15 * 60 + 1) {
            return try await getDollarAlCambio()
        } else {
            return try await getDollarRates()
        }
    }

    // Función para obtener la información del dólar
    func getDollarRates() async throws -> DollarResponse {
        let url = URL(string: "https://api.dolaraldiavzla.com/api/v1/dollar")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer 2x9Qjpxl5F8CoKK6T395KA", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        
        let dollarResponse = try JSONDecoder().decode(DollarResponse.self, from: data)
        return dollarResponse
    }

    func getDollarAlCambio() async throws -> DollarResponse {
        let url = URL(string: "https://pydolarve.org/api/v1/dollar?page=alcambio&format_date=default&rounded_price=true")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer 2x9Qjpxl5F8CoKK6T395KA", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        
        let dollarResponse = try JSONDecoder().decode(DollarResponse.self, from: data)
        return dollarResponse
    }

}
