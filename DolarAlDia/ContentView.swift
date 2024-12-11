//
//  ContentView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/1/24.
//
import SwiftUI

struct ContentView: View {
    @State private var selectedSection: String = "Dolar Al Día"

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                Spacer() // Mueve el contenido principal hacia abajo

                // Aquí mostramos la vista según la sección seleccionada en el menú
                if selectedSection == "Dolar Al Día" {
                    DolarAlDiaView()
                }
                if selectedSection == "Precio en Paginas" {
                    HStack {
                        MonitorListView()
                    }.padding(.vertical, 8)
                }
                if selectedSection == "Precio del BCV" {
                    HStack{
                        MonitorBcvListView()
                    }.padding(.vertical, 8)
                }
                // Nueva sección: Formulario de Usuarios
                if selectedSection == "Formulario de Usuarios" {
                    UserFormView() // Aquí añadimos la vista del formulario
                }
                // Nueva sección: Lista de Usuarios
                if selectedSection == "Lista de Usuarios" {
                    UserListView() // Aquí añadimos la vista de la lista de usuarios
                }
            }
            .padding(.top, 50) // Añade espacio entre el menú y el contenido principal

            MenuView(selectedSection: $selectedSection) // Coloca el menú arriba del contenido principal
        }
    }
}

#Preview { ContentView() }
//#Preview { MenuView(selectedSection: .constant("Dolar Al Día")) }
