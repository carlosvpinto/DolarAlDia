//
//  MenuView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/8/24.
//
import SwiftUI

struct MenuView: View {
    @Binding var selectedSection: String
    @State private var isMenuOpen: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            // Ícono del menú hamburguesa
            Button(action: {
                withAnimation {
                    isMenuOpen.toggle()
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .resizable()
                    .frame(width: 30, height: 20)
                    .padding()
            }

            // Menú desplegable
            if isMenuOpen {
                VStack(alignment: .leading, spacing: 10) {
                    Button(action: {
                        selectedSection = "Dolar Al Día"
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Text("Inicio")
                            .padding()
                    }

                    Button(action: {
                        selectedSection = "Precio en Paginas"
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Text("Precio en Paginas")
                            .padding()
                    }

                    Button(action: {
                        selectedSection = "Precio del BCV"
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Text("Precio del BCV")
                            .padding()
                    }
                    Button(action: {
                        selectedSection = "Formulario de Usuarios"
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Text("Formulario de Usuarios")
                            .padding()
                    }
                    Button(action: {
                        selectedSection = "Lista de Usuarios"
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Text("Lista de Usuarios")
                            .padding()
                    }
                    
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
        .background(Color.white) // Fondo del menú
        .foregroundColor(.black)  // Color de texto
        .cornerRadius(10)
        .padding()
        .font(.title3)
    }
}

#Preview { MenuView(selectedSection: .constant("Dolar Al Día")) }
