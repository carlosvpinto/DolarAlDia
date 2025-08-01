//
//  UserSession.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 7/29/25.
//

import SwiftUI

// Esta clase será nuestra única fuente de verdad para el estado del usuario.
// Al ser un ObservableObject, las vistas pueden suscribirse a sus cambios.
class UserSession: ObservableObject {
    
    // @Published notifica a las vistas cada vez que este valor cambia.
    @Published var hayUsuarioGuardado: Bool = false
    
    private let userDataManager = UserDataManager()
    
    init() {
        // Al iniciar la sesión, verificamos inmediatamente si hay un usuario.
        verificarUsuarioGuardado()
    }
    
    // Esta función ahora vive aquí y actualiza nuestra propiedad @Published.
    func verificarUsuarioGuardado() {
        // Comparamos el nuevo estado con el antiguo para evitar notificaciones innecesarias.
        let tieneUsuario = userDataManager.loadDefaultUser() != nil
        if tieneUsuario != hayUsuarioGuardado {
            hayUsuarioGuardado = tieneUsuario
            print("Estado del usuario actualizado: \(hayUsuarioGuardado)")
        }
    }
}
