//
//  APIService.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/2/24.
//

import Foundation

class ApiNetwork {
    
    // MARK: - Modelos para el Dólar (BCV, Paralelo)
    
    struct DollarResponse: Codable {
        let datetime: DateTime
        let monitors: Monitors
    }
    
    struct Monitors: Codable {
        let bcv: MonitorDetail
        let enparalelovzla: MonitorDetail
    }

    // --- MODELO GENERAL DE DETALLE (Reutilizable) ---
    // Este modelo ahora puede ser usado tanto por monitores como por plataformas.
    struct MonitorDetail: Codable, Identifiable {
        var id: String { title }
        let change: Double
        let color: String
        let image: String? // Hacemos la imagen opcional para que sea compatible con ambas respuestas
        let lastUpdate: String
        let percent: Double
        let price: Double
        let priceOld: Double
        let priceOlder: Double?
        let symbol: String
        let title: String
        
        enum CodingKeys: String, CodingKey {
            case change, color, image, percent, price, symbol, title
            case lastUpdate = "last_update"
            case priceOld = "price_old"
            case priceOlder = "price_older"
        }
    }
    
    // MARK: - Nuevos Modelos para Plataformas (Binance, Bybit)
    
    // El modelo de respuesta principal es un poco diferente.
    struct PlatformResponse: Codable {
        let datetime: DateTime
        let platforms: [String: MonitorDetail] // La clave es que 'platforms' es un diccionario dinámico
    }
    
    // La estructura DateTime la podemos reutilizar.
    struct DateTime: Codable {
        let date: String
        let time: String
    }
    
    
    // Para obtener la información de las plataformas (Binance, Bybit, etc.)
    func getPlatformRates() async throws -> PlatformResponse {
        
        guard let url = URL(string: "https://api.dolaraldiavzla.com/api/v1/market-p2p") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Asumo que también requiere autorización. Si no, puedes eliminar esta línea.
        request.setValue("Bearer 2x9Qjpxl5F8CoKK6T395KA", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        
        let platformResponse = try JSONDecoder().decode(PlatformResponse.self, from: data)
        return platformResponse
    }
    
    
    func getDollarRatesBasedOnTime() async throws -> DollarResponse {
        let calendar = Calendar.current
        let now = Date()
        
        let weekday = calendar.component(.weekday, from: now)
        let isWeekend = weekday == 1 || weekday == 7
        
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        
        let currentTimeInMinutes = hour * 60 + minute
        
    
        if isWeekend || currentTimeInMinutes >= (15 * 60) {
            return try await getDollarAlCambio()
        } else {
            return try await getDollarRates()
        }
    }

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
        let url = URL(string: "https://api.dolaraldiavzla.com/api/v1/dollar?page=alcambio&format_date=default&rounded_price=true")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer 2x9Qjpxl5F8CoKK6T395KA", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        
        let dollarResponse = try JSONDecoder().decode(DollarResponse.self, from: data)
        return dollarResponse
    }
}
