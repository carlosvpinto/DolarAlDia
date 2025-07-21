//
//  UserData.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/10/24.
//

import Foundation

// Modelo de datos de usuario
struct UserData: Identifiable, Codable {
    var id: String = UUID().uuidString
    var alias: String
    var phone: String
    var idNumber: String
    var idType: String  // Agrega esta línea
    var bank: String
    var imageData: Data? // <-- NUEVO imagen
}

