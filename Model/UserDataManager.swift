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
        var users = load()
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        } else {
            users.append(user)
        }
        saveUsers(users)
    }

    // --- FUNCIÓN CORREGIDA ---
    // Eliminar un usuario
    func delete(_ id: String) {
        // 1. Cargar usuarios existentes
        var users = load()
        
        // 2. Comprobar si el usuario a eliminar es el predeterminado
        if let defaultUser = loadDefaultUser(), defaultUser.id == id {
            // Si es el predeterminado, lo eliminamos de UserDefaults.
            UserDefaults.standard.removeObject(forKey: defaultUserKey)
            print("Usuario predeterminado eliminado.")
        }
        
        // 3. Eliminar el usuario de la lista principal
        users.removeAll { $0.id == id }
        
        // 4. Guardar la nueva lista de usuarios
        saveUsers(users)
        
        // 5. (Opcional pero recomendado) Si no queda un usuario por defecto
        // y todavía hay usuarios en la lista, establecer el primero como nuevo default.
        if loadDefaultUser() == nil, let newDefault = users.first {
            saveDefaultUser(newDefault)
            print("Se ha establecido un nuevo usuario predeterminado.")
        }
    }

    // Modificar un usuario
    func modify(user: UserData) {
        save(user: user)
    }

    // Cargar la lista de usuarios desde UserDefaults
    func load() -> [UserData] {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            let decoder = JSONDecoder()
            if let users = try? decoder.decode([UserData].self, from: data) {
                return users
            }
        }
        return []
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
