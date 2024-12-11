//
//  HamburgerMenu.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/8/24.
//

import SwiftUI

struct HamburgerMenu: View {
    @Binding var showMenu: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                // Acción para navegar a la primera vista
            }) {
                HStack {
                    Image(systemName: "house")
                    Text("Inicio")
                        .font(.headline)
                }
                .padding()
            }

            Button(action: {
                // Acción para navegar a la segunda vista
            }) {
                HStack {
                    Image(systemName: "dollarsign.circle")
                    Text("Tasas de Dólar")
                        .font(.headline)
                }
                .padding()
            }

            Spacer()
        }
        .frame(maxWidth: 250)
        .background(Color.gray.opacity(0.8))
        .edgesIgnoringSafeArea(.all)
    }
}
