//
//  ModelDual.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 5/12/25.
//

import Foundation
struct DollarHistoryPoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
    let type: DollarType

    enum DollarType: String {
        case bcv = "BCV"
        case paralelo = "Paralelo"
    }
}

