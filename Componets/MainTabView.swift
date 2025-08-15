//
//  MainTabView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 7/28/25.
//

import SwiftUI

// Asegúrate de que tus constantes estén definidas en algún lugar accesible.
// Estas nos ayudan a evitar errores de tipeo.
import SwiftUI

struct MainTabView: View {
    // Recibe la sección seleccionada como un Binding para comunicarse con ContentView
    @Binding var selectedSection: String

    // Recibe todos los demás estados que necesitan las vistas hijas
    @Binding var dolares: String
    @Binding var bolivares: String
    @Binding var tasaBCV: String
    @Binding var tasaEuro: String
    @Binding var selectedButton: String

    var body: some View {
        
        // El 'selection' está vinculado a la variable de estado de ContentView.
        TabView(selection: $selectedSection) {
            
            // Pestaña 1: Inicio
            DolarAlDiaView(
                dolares: $dolares,
                bolivares: $bolivares,
                tasaBCV: $tasaBCV,
                tasaEuro: $tasaEuro,
                selectedButton: $selectedButton
            )
            .tabItem {
                Label("Inicio", systemImage: "house")
            }
            .tag(Constants.DOLARALDIA)
            
            // Volvemos a usar un 'systemImage' simple y robusto.
            PlatformRatesView()
                .tabItem {
                    Label("Plataformas", systemImage: "globe.americas.fill")
                }
                .tag(Constants.PLATAFORMAS)
            
            // Pestaña 3: Bancos
            MonitorBcvListView()
                .tabItem {
                    Label("Bancos", systemImage: "dollarsign.circle")
                }
                .tag(Constants.PRECIOBCV)

            // Pestaña 4: Historia BCV
            BCVHistoryView(
                imgUrl: "https://res.cloudinary.com/dcpyfqx87/image/upload/v1729921478/monitors/public_id:bcv.webp",
                navigationTitle: "Historia Dólar BCV",
                page: "bcv",
                monitor: "usd"
            )
            .tabItem {
                Label("Historia", systemImage: "clock")
            }
            .tag(Constants.HISTORIA_BCV)
            
            // Pestaña 5: Pago Móvil
            UserListView()
                .tabItem {
                    Label("Pago Móvil", systemImage: "list.bullet.rectangle")
                }
                .tag(Constants.LISTAPMOVILES)
        }
        .accentColor(.blue) // Color del ícono y texto activo
    }
}
