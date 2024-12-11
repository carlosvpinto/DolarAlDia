//
//  ResultSheet.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/8/24.
//

import SwiftUI

struct ResultSheet: View {
    let mensaje: String
    let diferenciaBs: Double
    let diferenciaDolares: Double
    let diferenciaPorcentual: Double

    var body: some View {
        VStack(spacing: 20) {
            Image("logoredondo")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding()
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())

            Text(mensaje)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.primary)
                .padding(.top)

            VStack(alignment: .leading) {
                Text("Diferencia en Bs:")
                    .font(.headline)
                Text("\(diferenciaBs, specifier: "%.2f")")
                    .font(.subheadline)
                
                Text("Diferencia en Dólares:")
                    .font(.headline)
                Text("\(diferenciaDolares, specifier: "%.2f")")
                    .font(.subheadline)
                
                Text("Diferencia Porcentual:")
                    .font(.headline)
                Text("\(diferenciaPorcentual, specifier: "%.2f")%")
                    .font(.subheadline)
            }
            .padding()

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    ResultSheet(mensaje: "Diferencia en Cambio", diferenciaBs: 47.5, diferenciaDolares: 57.0, diferenciaPorcentual: 16.0)
}
