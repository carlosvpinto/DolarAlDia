//
//  ApiNetworBcv.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/10/24.
//

import Foundation

class ApiNetworkBcv {

    // Estructura principal del modelo
    struct DollarResponseBcv: Codable {
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
        let activo: MonitorDetail
        let bancamiga: MonitorDetail
        let bancaribe: MonitorDetail
        let banesco: MonitorDetail
        let bangente: MonitorDetail
        let banplus: MonitorDetail
        let bdv: MonitorDetail
        let bnc: MonitorDetail
        let bvc: MonitorDetail
        let cny: MonitorDetail
        let eur: MonitorDetail
        let exterior: MonitorDetail
        let mercantilBanco: MonitorDetail
        let miBanco: MonitorDetail
        let otrasInstituciones: MonitorDetail
        let plaza: MonitorDetail
        let provincial: MonitorDetail
        let rub: MonitorDetail
        let sofitasa: MonitorDetail
        let tryCurrency: MonitorDetail
        let usd: MonitorDetail

        // Usando `CodingKeys` para mapear los nombres con guiones bajos a camelCase
        enum CodingKeys: String, CodingKey {
            case activo
            case bancamiga
            case bancaribe
            case banesco
            case bangente
            case banplus
            case bdv
            case bnc
            case bvc
            case cny
            case eur
            case exterior
            case mercantilBanco = "mercantil_banco"
            case miBanco = "mi_banco"
            case otrasInstituciones = "otras_instituciones"
            case plaza
            case provincial
            case rub
            case sofitasa
            case tryCurrency = "try"
            case usd
        }
    }

    // Detalles de cada monitor de tipo dólar
    struct MonitorDetail: Codable, Identifiable {
        var id: String {
            return title
        }
        let change: Double
        let color: String
        let image: String?
        let lastUpdate: String
        let percent: Double
        let price: Double
        let priceOld: Double?
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
    func getDollarRatesBcv() async throws -> DollarResponseBcv {
        // Cambiar la URL a la nueva con el parámetro "bcv"
        let url = URL(string: "https://pydolarve.org/api/v1/dollar?page=bcv")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer 2x9Qjpxl5F8CoKK6T395KA", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Decodificar los datos en `DollarResponseBcv`
        let dollarResponseBcv = try JSONDecoder().decode(DollarResponseBcv.self, from: data)
        return dollarResponseBcv
    }
}
