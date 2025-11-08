//
//  APIService.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/2/24.
//

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

    // --- MODELO GENERAL DE DETALLE (Reutilizable para Dólar y Plataformas) ---
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
        
        enum CodingKeys: String, CodingKey {
            case change, color, image, percent, price, symbol, title
            case lastUpdate = "last_update"
            case priceOld = "price_old"
            case priceOlder = "price_older"
        }
    }
    
    // MARK: - Modelos para Plataformas (Binance, Bybit)
    
    struct PlatformResponse: Codable {
        let datetime: DateTime
        let platforms: [String: MonitorDetail]
    }
    
    // MARK: - Modelos para Monitores Internacionales (USDT, EUR, etc.)
    // ************************* NUEVO CÓDIGO AÑADIDO *************************

    // El modelo principal para la nueva respuesta de la API.
    struct RespuestaDolarUSDT: Codable {
        let datetime: DateTime // Reutilizamos la estructura DateTime existente
        let monitors: [String: InternationalMonitorDetail] // Diccionario dinámico de monitores
    }

    // Un modelo de detalle más completo para los monitores internacionales,
    // ya que tienen campos adicionales como 'percent_old', 'change_old', etc.
    struct InternationalMonitorDetail: Codable, Identifiable {
        var id: String { title }
        let change: Double
        let changeOld: Double
        let color: String
        let image: String?
        let lastUpdate: String
        let lastUpdateOld: String
        let percent: Double
        let percentOld: Double
        let price: Double
        let priceOld: Double
        let priceOlder: Double
        let symbol: String
        let title: String

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
    // *********************** FIN DEL NUEVO CÓDIGO AÑADIDO ***********************
    
    // Estructura DateTime reutilizable para todas las respuestas.
    struct DateTime: Codable {
        let date: String
        let time: String
    }
    
    // MARK: - Funciones de Llamada a la API
    
    // ************************* NUEVO CÓDIGO AÑADIDO *************************
    // Función para obtener la información de los monitores internacionales.
    func getInternationalRates() async throws -> RespuestaDolarUSDT {
        // !!! IMPORTANTE: REEMPLAZA ESTA URL CON LA CORRECTA !!!
        guard let url = URL(string: "https://api.dolaraldiavzla.com/api/v1/tipo-cambio") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Asumo que también requiere autorización. Si no, puedes eliminar esta línea.
        request.setValue("Bearer 2x9Qjpxl5F8CoKK6T395KA", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        
        let internationalResponse = try JSONDecoder().decode(RespuestaDolarUSDT.self, from: data)
        return internationalResponse
    }
    // *********************** FIN DEL NUEVO CÓDIGO AÑADIDO ***********************

    // Para obtener la información de las plataformas (Binance, Bybit, etc.)
    func getPlatformRates() async throws -> PlatformResponse {
        
        guard let url = URL(string: "https://api.dolaraldiavzla.com/api/v1/market-p2p") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
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
