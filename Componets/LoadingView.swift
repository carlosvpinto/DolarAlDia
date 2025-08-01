//
//  LoadingView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 7/29/25.
//

import SwiftUI

// Una vista de carga moderna y reutilizable.
struct LoadingView: View {
    var body: some View {
        ZStack {
            // Fondo oscuro y semitransparente que cubre toda la pantalla.
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 15) {
                // El indicador de progreso circular.
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5) // Hacemos el círculo un poco más grande.

                // Texto descriptivo.
                Text("Cargando datos...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            // Usamos el efecto "Material" de Apple para un fondo de vidrio esmerilado.
            // Se adapta automáticamente al modo claro/oscuro.
            .padding(30)
            .background(.thinMaterial)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        }
    }
}
