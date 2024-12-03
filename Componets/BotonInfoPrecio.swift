//
//  BotonInfoPrecio.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/2/24.
//
import SwiftUI

struct BotonInfoPrecio: View {
    var valorDolar: String
    var nombreDolar: String
    var imagenFlecha: String
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
        }
    }
}


struct Counter: View {
    @State var subscribersNumber = 0
    
    var body: some View {
        Button(action: {
            subscribersNumber += 1
        }, label: {
            Text("Suscriptores: \(subscribersNumber)")
                .bold()
                .font(.title)
                .frame(height: 50)
                .foregroundColor(.white)
                .background(.red)
                .cornerRadius(20)
                .padding(30)  // Aquí agregas el padding de 30dp
        })
    }
}


//#Preview {
 //   BotonInfoPrecio(valorDolar:"57", nombreDolar: "Dolar Bcv", imagenFlecha: "arrow.up", variacionPorcentaje: "0,8")
//}
