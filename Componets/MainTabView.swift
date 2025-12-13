//
//  MainTabView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 7/28/25.
//
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
        
        TabView(selection: $selectedSection) {
            
            // Pestaña 1: Inicio (Sin cambios)
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
            
            // Pestaña 2: Plataformas (Sin cambios)
            PlatformRatesView()
                .tabItem {
                    Label("Plataformas", systemImage: "globe.americas.fill")
                }
                .tag(Constants.PLATAFORMAS)
            
            // ================================================================
            // 👇 CAMBIO: La pestaña de "Bancos" ahora es la de "Más Opciones"
            // ================================================================
            MoreMenuView() // Usamos la nueva vista que creamos
                .tabItem {
                    // El ícono de tres rayas y el nuevo texto
                    Label("Más", systemImage: "line.3.horizontal")
                }
                .tag(Constants.MAS_OPCIONES)
            
    
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
            
            // Pestaña 5: Pago Móvil (Sin cambios)
            UserListView()
                .tabItem {
                    Label("Pago Móvil", systemImage: "list.bullet.rectangle")
                }
                .tag(Constants.LISTAPMOVILES)
        }
        .accentColor(.blue)
    }
}
