//
//  MoreMenuView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 11/9/25.
//
// MoreMenuView.swift
import SwiftUI

struct MoreMenuView: View {
    var body: some View {
        // Usamos NavigationView para poder navegar a las distintas pantallas
        NavigationView {
            List {
                // Opción 1: Bancos (la que movimos)
                NavigationLink(destination: MonitorBcvListView()) {
                    Label("Bancos", systemImage: "dollarsign.circle")
                }
                
                // Opción 2: Estado de la Suscripción
                NavigationLink(destination: SubscriptionStatusView()) {
                    Label("Estado de la Suscripción", systemImage: "crown")
                }
                
                // --- AÑADE AQUÍ FUTURAS OPCIONES ---
                // Ejemplo:
                // NavigationLink(destination: SettingsView()) {
                //     Label("Configuración", systemImage: "gear")
                // }
            }
            .navigationTitle("Más Opciones") // Título en la barra de navegación
        }
    }
}

struct MoreMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MoreMenuView()
    }
}
