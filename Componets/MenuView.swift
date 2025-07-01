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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if isMenuOpen {
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image("logoredondo")
                                .resizable()
                                .frame(width: 40, height: 40)
                            Text("Dolar Al Dia")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 80)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )

                        Divider()
                            .frame(height: 2)
                            .padding(.horizontal)

                        menuOption(label: "Inicio", systemImage: "house", section: Constants.DOLARALDIA)
                      // menuOption(label: "Precio en Paginas", systemImage: "network", section: Constants.PRECIOPAGINAS) para que no aparezca
                        menuOption(label: "Precio en Oficial", systemImage: "dollarsign.bank.building", section: Constants.PRECIOBCV)

                        // Submenú Historia
                        Menu {
                            Button {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    selectedSection = Constants.HISTORIA_BCV
                                    isMenuOpen.toggle()
                                }
                            } label: {
                                Label("Dólar BCV", systemImage: "clock")
                            }
                              
                        } label: {
                            Label("Historia", systemImage: "clock")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    (selectedSection == "HISTORIA_BCV" || selectedSection == "HISTORIA_PARALELO") ?
                                    (colorScheme == .dark ? Color.gray.opacity(0.3) : Color.blue.opacity(0.2)) : Color.clear
                                )
                                .cornerRadius(10)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal)

                        menuOption(label: "Pago Movil lista", systemImage: "list.bullet.rectangle", section: Constants.LISTAPMOVILES)
                    }
                    .padding(.top, geometry.safeAreaInsets.top)

                    Spacer()
                }
                .frame(width: min(geometry.size.width * 0.8, 300), height: geometry.size.height)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .cornerRadius(10)
                .shadow(radius: 5)
                .transition(.move(edge: .leading))
            }
            .transition(.move(edge: .leading))
        }
    }

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
                .background(selectedSection == section ? (colorScheme == .dark ? Color.gray.opacity(0.3) : Color.blue.opacity(0.2)) : Color.clear)
                .cornerRadius(10)
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
    }
}
