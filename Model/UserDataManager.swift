//
//  UserDataManager.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/10/24.
//

import Foundation

// Clase para manejar la persistencia de datos de los usuarios
class UserDataManager {
    private let userDefaultsKey = "userList"
    private let defaultUserKey = "defaultUser"

    // Guardar un usuario nuevo
    func save(user: UserData) {
        var users = load() // Cargar usuarios existentes
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user // Si el usuario existe, modificarlo
        } else {
            users.append(user) // Si no existe, agregarlo
        }
        saveUsers(users)
    }

    // Eliminar un usuario
    func delete(_ id: String) {
        var users = load() // Cargar usuarios existentes
        users.removeAll { $0.id == id } // Eliminar el usuario por ID
        saveUsers(users)
    }

    // Modificar un usuario
    func modify(user: UserData) {
        save(user: user) // Reutilizamos la función de guardar para modificar
    }

    // Cargar la lista de usuarios desde UserDefaults
    func load() -> [UserData] {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            let decoder = JSONDecoder()
            if let users = try? decoder.decode([UserData].self, from: data) {
                return users
            }
        }
        return [] // Retornar lista vacía si no hay datos guardados
    }

    // Guardar el usuario predeterminado
    func saveDefaultUser(_ user: UserData) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: defaultUserKey)
        }
    }

    // Cargar el usuario predeterminado
    func loadDefaultUser() -> UserData? {
        if let data = UserDefaults.standard.data(forKey: defaultUserKey) {
            let decoder = JSONDecoder()
            return try? decoder.decode(UserData.self, from: data)
        }
        return nil
    }

    // Guardar la lista de usuarios en UserDefaults
    private func saveUsers(_ users: [UserData]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(users) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}

