//
//  BotonInfoPrecio.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/2/24.
//
import SwiftUI

struct BotonInfoPrecio: View {
    var mostrar: Bool
    var valorDolar: String
    var nombreDolar: String
    var simboloFlecha: String
    var variacionPorcentaje: String
    var isSelected: Bool
    
    // --- NUEVO ---
    // Añadimos esta propiedad para saber la dirección de la animación
    var mostrarTasasFuturas: Bool
    
    var action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 5) {
            Text(nombreDolar)
                .bold()
                .font(.title3)
            
            Button(action: {
                action()
            }, label: {
                HStack(spacing: 4) { // Usamos un HStack para combinar el "Bs" y el valor
                    Text("Bs")
                    Text(valorDolar)
                        // --- ANIMACIÓN APLICADA AQUÍ ---
                        .contentTransition(.numericText(countsDown: !mostrarTasasFuturas))
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .bold()
                .font(.title2)
                .foregroundColor(.white)
            })
            .background(isSelected ? Color.blue : Color.gray)
            .cornerRadius(20)
            .scaleEffect(isSelected ? 0.95 : 1)
            
            if mostrar {
                HStack(spacing: 5) {
                    Text(simboloFlecha)
                        .foregroundColor(simboloFlecha == "▲" ? .green : .red)
                    
                    Text("\(variacionPorcentaje)%")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        // --- ANIMACIÓN APLICADA AQUÍ ---
                        .contentTransition(.numericText(countsDown: !mostrarTasasFuturas))
                }
            }
        }
    }
}

// --- MODIFICADO ---
#Preview {
    BotonInfoPrecio(
        mostrar: true,
        valorDolar: "30.00",
        nombreDolar: "Dolar Bcv",
        simboloFlecha: "▲",
        variacionPorcentaje: "0.5",
        isSelected: true,
        mostrarTasasFuturas: false, // Valor para la preview
        action: {
            print("Botón presionado")
        }
    )
}


