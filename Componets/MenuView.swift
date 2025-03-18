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
        if isMenuOpen {
            GeometryReader { geometry in
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
                    menuOption(label: "Precio en Paginas", systemImage: "network", section: Constants.PRECIOPAGINAS)
                    menuOption(label: "Precio en Oficial", systemImage: "dollarsign.bank.building", section: Constants.PRECIOBCV)
                    menuOption(label: "Pago Movil", systemImage: "person.text.rectangle", section: Constants.PAGOSMOVILES)
                    menuOption(label: "Pago Movil lista", systemImage: "list.bullet.rectangle", section: Constants.LISTAPMOVILES)
                }
                .frame(width: min(geometry.size.width * 0.8, 300), height: geometry.size.height)
                .background(Color.white)
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
                .background(selectedSection == section ? Color.blue.opacity(0.2) : Color.clear)
                .cornerRadius(10)
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
    }
}
