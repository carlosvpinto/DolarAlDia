//
//  BCVHistoryModels.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 5/10/25.
//
import Foundation

struct BCVHistoryResponse: Decodable {
    let datetime: DateTimeInfo
    let history: [BCVHistoryItem]
}

struct DateTimeInfo: Decodable {
    let date: String
    let time: String
}

struct BCVHistoryItem: Identifiable, Decodable {
    var id = UUID()
    let last_update: String
    let price: Double
    let price_high: Double
    let price_low: Double

    private enum CodingKeys: String, CodingKey {
        case last_update, price, price_high, price_low
    }
}
