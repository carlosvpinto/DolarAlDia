//
//  ExtendedFAB.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 11/9/25.
//
import SwiftUI

struct ExtendedFAB: View {
    // Estado interno para controlar la expansión
    @State private var isExpanded = false
    
    // La acción que se ejecutará al tocar el botón
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) { // Añadimos un poco de espaciado
                // ***** CAMBIO 1: Icono más pequeño *****
                Image(systemName: "gift.fill")
                    .font(.headline) // Tamaño reducido (era .body por defecto)
                
                // El texto solo aparece si el botón está expandido
                if isExpanded {
                    // ***** CAMBIO 2: Letras más pequeñas *****
                    Text("Obtener Premium")
                        .fontWeight(.semibold)
                        .font(.callout) // Tamaño reducido
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
        }
        // ***** CAMBIO 3: Botón más compacto (menos padding) *****
        .padding(.horizontal, 16) // Era 20
        .padding(.vertical, 12)   // Era 15
        .background(Color.blue)
        .foregroundColor(.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
        .onAppear {
            startAttentionSequence()
        }
    }
    
    /// Anima el botón para que se expanda y luego se contraiga,
    /// atrayendo la atención del usuario.
    private func startAttentionSequence() {
        // Espera un poco después de que aparezca la vista
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isExpanded = true
            
            // ***** CAMBIO 4: Movimiento más corto (menos tiempo expandido) *****
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // Era 4.0
                isExpanded = false
            }
        }
    }
}

#Preview {
    ExtendedFAB(action: { print("Botón pulsado") })
}
