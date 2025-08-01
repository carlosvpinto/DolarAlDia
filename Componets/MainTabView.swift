//
//  MainTabView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 7/28/25.
//

import SwiftUI

// Asegúrate de que tus constantes estén definidas en algún lugar accesible.
// Estas nos ayudan a evitar errores de tipeo.
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
            // **** LA VISTA SE COLOCA AQUÍ ****
            DolarAlDiaView(
                dolares: $dolares,
                bolivares: $bolivares,
                tasaBCV: $tasaBCV,
                tasaEuro: $tasaEuro,
                selectedButton: $selectedButton
            )
            .tabItem { // Esto define el botón de la barra
                Label("Inicio", systemImage: "house")
            }
            .tag(Constants.DOLARALDIA) // Este tag debe coincidir con el estado

            // Pestaña 2: Precio Oficial
            // **** LA VISTA SE COLOCA AQUÍ ****
            MonitorBcvListView()
                .tabItem {
                    Label("Bancos", systemImage: "dollarsign.circle")
                }
                .tag(Constants.PRECIOBCV)

            // Pestaña 3: Historia BCV
            // **** LA VISTA SE COLOCA AQUÍ ****
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
            
            // Pestaña 4: Pago Móvil
            // **** LA VISTA SE COLOCA AQUÍ ****
            UserListView()
                .tabItem {
                    Label("Pago Móvil", systemImage: "list.bullet.rectangle")
                }
                .tag(Constants.LISTAPMOVILES)
        }
        .accentColor(.blue) // Color del ícono y texto activo
    }
}
// Vista previa para el lienzo de Xcode
//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
 //       MainTabView()
  //  }
//}
