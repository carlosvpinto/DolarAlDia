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
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 5) {
            Text(nombreDolar)
                .bold()
                .font(.title3)
            
            Button(action: {
                action() // Ejecutar la acción al presionar el botón
            }, label: {
                Text("Bs  \(valorDolar)")
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .bold()
                    .font(.title2)
                    .foregroundColor(.white)
                    .background(isSelected ? Color.blue : Color.gray)
                    .cornerRadius(20)
                    .scaleEffect(isSelected ? 0.95 : 1) // Efecto de presionado
            })
            
            // Verificación para mostrar solo si el simboloFlecha no está vacío
            if mostrar{
                HStack(spacing: 5) {
                    // Cambia el color del símbolo según sea ▲ o ▼
                    Text(simboloFlecha)
                        .foregroundColor(simboloFlecha == "▲" ? .green : .red)
                    
                    Text("\(variacionPorcentaje)%")
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
        }
    }
}


#Preview {
    BotonInfoPrecio(
        mostrar: true,
        valorDolar: "30.00",
        nombreDolar: "Dolar Bcv",
        simboloFlecha: "▲",
        variacionPorcentaje: "0.5",
        isSelected: true,
        action: {
            print("Botón presionado")
        }
    )
}


