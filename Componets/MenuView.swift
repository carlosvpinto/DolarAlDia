//
//  MenuView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/8/24.
//

import SwiftUI

struct MenuView: View {
    @Binding var selectedSection: String
    @Binding var isMenuOpen: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Ícono del menú hamburguesa en la parte superior izquierda
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isMenuOpen.toggle()
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .resizable()
                    .frame(width: 30, height: 20)
                    .padding()
            }

            // Menú desplegable que aparece desde la parte superior izquierda
            if isMenuOpen {
                VStack(alignment: .leading, spacing: 10) {
                    // Imagen y nombre de la app con un pequeño retraso en la animación
                    HStack {
                        Image("logoredondo") // Ícono de la app
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("Dolar Al Dia")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 80)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5).delay(0.3), value: isMenuOpen)

                    Divider()
                        .frame(height: 2)
                        .padding(.horizontal)

                    // Opciones del menú
                    menuOption(label: "Inicio", systemImage: "house", section: Constants.DOLARALDIA)
                    menuOption(label: "Precio en Paginas", systemImage: "network", section: Constants.PRECIOPAGINAS)
                    menuOption(label: "Precio en Oficial", systemImage: "dollarsign.bank.building", section: Constants.PRECIOBCV)
                    menuOption(label: "Pago Movil", systemImage: "person.text.rectangle", section: Constants.PAGOSMOVILES)
                    menuOption(label: "Pago Movil lista", systemImage: "list.bullet.rectangle", section: Constants.LISTAPMOVILES)
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .frame(maxWidth: 500) // Ancho del menú
                .transition(.move(edge: .leading)) // Transición desde la izquierda
                .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.5), value: isMenuOpen)
            }
        }
        .background(Color.white)
        .foregroundColor(.black)
        .cornerRadius(10)
        .padding()
        .font(.title3)
        .zIndex(1) // Asegura que el menú esté por encima del contenido principal
    }

    // Función para las opciones del menú
    private func menuOption(label: String, systemImage: String, section: String) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.4)) {
                selectedSection = section
                isMenuOpen.toggle()
            }
        }) {
            Label(label, systemImage: systemImage)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(selectedSection == section ? Color.blue.opacity(0.2) : Color.clear)
                .cornerRadius(10)
                .scaleEffect(isMenuOpen ? 1 : 0.95)
                .animation(.easeInOut(duration: 0.3), value: isMenuOpen)
                .transition(.opacity.combined(with: .slide))
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
    }
}


