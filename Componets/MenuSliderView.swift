//
//  MenuSliderView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/17/24.
//

import SwiftUI

struct MenuSliderView: View {
    var body: some View {
        ZStack {
            // Fondo del menú lateral
            Color.gray.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            // Contenido del menú
            HStack {
                VStack(alignment: .leading) {
                    // Imagen y nombre de la app
                    HStack {
                        Image("logoredondo") // Ícono de la app
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("Dolar Al Dia")
                            .font(.headline)
                    }
                    .padding()
                    
                    // Opciones del menú
                    Button(action: {
                        // Acción para la opción 1
                    }) {
                        Label("Opción 1", systemImage: "house")
                    }
                    .padding(.top)
                    
                    Button(action: {
                        // Acción para la opción 2
                    }) {
                        Label("Opción 2", systemImage: "star")
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                .padding()
                .frame(width: 250)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
#Preview {
    MenuSliderView()
}
