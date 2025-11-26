//
//  DolarAlDiaData.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/12/24.
//
import Foundation

class DolarAlDiaData: ObservableObject {
    @Published var dolares: String = ""
    @Published var bolivares: String = ""
    @Published var tasaBCV: String = ""
    @Published var tasaParalelo: String = ""
    @Published var porcentajeEuro: String = ""
    @Published var porcentajeBcv: String = ""
    @Published var simboloBcv: String = ""
    @Published var simboloParalelo: String = ""
    @Published var fechaActualizacionParalelo: String = "29/11/2024, 01:39 PM"
    @Published private var fechaActualizacionBCV: String = "02/12/2024"
}

