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
    
    // Propiedad para la dirección de la animación
    var mostrarTasasFuturas: Bool
    
    var action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
       
        VStack(spacing: 2) {
            Text(nombreDolar)
                .bold()
               
                .font(.headline)
            
            Button(action: {
                action()
            }, label: {
             
                HStack(spacing: 3) {
                    Text("Bs")
                    Text(valorDolar)
                        .contentTransition(.numericText(countsDown: !mostrarTasasFuturas))
                }
               
                .frame(maxWidth: .infinity, maxHeight: 40)
                .bold()
           
                .font(.title3)
                .foregroundColor(.white)
            })
            .background(isSelected ? Color.blue : Color.gray)
     
            .cornerRadius(15)
            .scaleEffect(isSelected ? 0.95 : 1)
            
            if mostrar {
              
                HStack(spacing: 2) {
                    Text(simboloFlecha)
                        .foregroundColor(simboloFlecha == "▲" ? .green : .red)
                    
                    Text("\(variacionPorcentaje)%")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
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


