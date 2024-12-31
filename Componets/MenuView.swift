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
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
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
                    .transition(.opacity) // Efecto de desvanecimiento
                    .animation(.easeInOut(duration: 0.5).delay(0.3), value: isMenuOpen) // Animación con retraso de 0.3 segundos

                    Divider()
                        .frame(height: 2)
                        .padding(.horizontal)

                    // Opciones del menú con transición de escala y deslizamiento
                    menuOption(label: "Inicio", systemImage: "house", section: Constants.DOLARALDIA)
                    menuOption(label: "Precio en Paginas", systemImage: "network", section: Constants.PRECIOPAGINAS)
                    menuOption(label: "Precio en Oficial", systemImage: "dollarsign.bank.building", section: Constants.PRECIOBCV)
                    menuOption(label: "Pago Movil", systemImage: "person.text.rectangle", section: Constants.PAGOSMOVILES)
                    menuOption(label: "Pago Movil lista", systemImage: "list.bullet.rectangle", section: Constants.LISTAPMOVILES)
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .transition(.move(edge: .leading)) // Transición desde la izquierda
                .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.5), value: isMenuOpen) // Animación para el menú principal
            }
        }
        .background(Color.white) // Fondo del menú
        .foregroundColor(.black)  // Color de texto
        .cornerRadius(10)
        .padding()
        .font(.title3)
    }

    // Función para las opciones del menú con animación y cambio de fondo cuando es seleccionada
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
                .background(selectedSection == section ? Color.blue.opacity(0.2) : Color.clear) // Fondo azul si está seleccionada
                .cornerRadius(10)
                .scaleEffect(isMenuOpen ? 1 : 0.95) // Transición de escala suave
                .animation(.easeInOut(duration: 0.3), value: isMenuOpen) // Animación actualizada
                .transition(.opacity.combined(with: .slide)) // Deslizamiento y desvanecimiento
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
    }
}

#Preview { MenuView(selectedSection: .constant("Dolar Al Día")) }
