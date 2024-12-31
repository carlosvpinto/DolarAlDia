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
        VStack(spacing: 30) {
            // Encabezado con logo
            VStack(spacing: 10) {
                Image("logoredondo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
                
                Text(mensaje)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)  // Cambia automáticamente según el modo
                    .padding(.top, 10)
            }
            
            // Sección de diferencias
            VStack(alignment: .leading, spacing: 15) {
                // Diferencia en Bs
                HStack {
                    Text("Diferencia en Bs:")
                        .font(.headline)
                        .foregroundColor(Color.primary)  // Cambia automáticamente
                    Spacer()
                    Text("\(diferenciaBs, specifier: "%.2f") Bs")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                Divider()
                
                // Diferencia en Dólares
                HStack {
                    Text("Diferencia en Dólares:")
                        .font(.headline)
                        .foregroundColor(Color.primary)  // Cambia automáticamente
                    Spacer()
                    Text("\(diferenciaDolares, specifier: "%.2f") USD")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                Divider()
                
                // Diferencia Porcentual
                HStack {
                    Text("Diferencia Porcentual:")
                        .font(.headline)
                        .foregroundColor(Color.primary)  // Cambia automáticamente
                    Spacer()
                    Text("\(diferenciaPorcentual, specifier: "%.2f")%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))  // Cambia automáticamente
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))  // Cambia automáticamente
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 5)
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    ResultSheet(mensaje: "Diferencia en Cambio", diferenciaBs: 47.5, diferenciaDolares: 57.0, diferenciaPorcentual: 16.0)
}
