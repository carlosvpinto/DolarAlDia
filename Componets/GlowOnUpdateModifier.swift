//
//  GlowOnUpdateModifier.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 8/13/25.
//
import SwiftUI

// 1. Definimos la estructura del modificador
struct GlowOnUpdateModifier: ViewModifier {
    // Recibe un booleano que nos dirá si la animación debe estar activa
    let isAnimating: Bool
    
    // La función 'body' aplica los cambios a la vista
    func body(content: Content) -> some View {
        content
            .fontWeight(.bold)
            // Si está animando, el color es verde; si no, es el color secundario por defecto.
            .foregroundColor(isAnimating ? .green : .secondary)
            // Si está animando, la escala aumenta; si no, es normal.
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            // Si está animando, se añade una sombra verde; si no, la sombra es transparente.
            .shadow(
                color: isAnimating ? .green.opacity(0.5) : .clear,
                radius: 5, x: 0, y: 0
            )
    }
}

// 2. Creamos una extensión en 'View' para que sea más fácil de llamar
extension View {
    // Ahora, en lugar de .modifier(GlowOnUpdateModifier(...)),
    // podremos escribir simplemente .glowOnUpdate(...)
    func glowOnUpdate(isAnimating: Bool) -> some View {
        self.modifier(GlowOnUpdateModifier(isAnimating: isAnimating))
    }
}
