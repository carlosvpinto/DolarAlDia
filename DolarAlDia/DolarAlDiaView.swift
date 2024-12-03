//
//  DolarAlDiaView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/1/24.
//
import SwiftUI

struct DolarAlDiaView: View {
    @State private var dolares: String = "4"
    @State private var bolivares: String = "208.40"
    @State private var tasaBCV: String = "47.61"
    @State private var tasaParalelo: String = "56.59"
    @State private var fechaActualizacionParalelo: String = "29/11/2024, 01:39 PM"
    @State private var fechaActualizacionBCV: String = "02/12/2024"
    
    @State private var isLoading: Bool = false // Estado para controlar el ProgressView
    @State private var selectedButton: String = "Dolar Bcv" // Estado para controlar el botón seleccionado
    
    @State private var showToast: Bool = false // Estado para mostrar el mensaje tipo Toast
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    let screenWidth = UIScreen.main.bounds.width
                    let padding: CGFloat = 40
                    let buttonWidth = (screenWidth - padding) / 2
                    
                    Image("logoredondo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    
                    BotonInfoPrecio(valorDolar: tasaPromedio(), nombreDolar: "Dolar Promedio", imagenFlecha: "arrow.up", variacionPorcentaje: "0,8", isSelected: selectedButton == "Dolar Promedio") {
                        selectedButton = "Dolar Promedio"
                    }
                    .padding(.top, 20)
                    .frame(maxWidth: buttonWidth)
                    
                    HStack(spacing: 20) {
                        BotonInfoPrecio(valorDolar: tasaBCV, nombreDolar: "Dolar Bcv", imagenFlecha: "arrow.up", variacionPorcentaje: "0,2", isSelected: selectedButton == "Dolar Bcv") {
                            selectedButton = "Dolar Bcv"
                        }
                        .frame(maxWidth: buttonWidth)
                        
                        BotonInfoPrecio(valorDolar: tasaParalelo, nombreDolar: "Dolar Paralelo", imagenFlecha: "arrow.up", variacionPorcentaje: "0,8", isSelected: selectedButton == "Dolar Paralelo") {
                            selectedButton = "Dolar Paralelo"
                        }
                        .frame(maxWidth: buttonWidth)
                    }
                    
                    // Campos de texto de dólares y bolívares
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Dólares")
                                TextField("$", text: $dolares)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                
                                Button(action: {
                                    UIPasteboard.general.string = bolivares
                                    showToastMessage()
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
                                }
                            }
                            
                            HStack {
                                Text("Bolívares")
                                TextField("Bs.", text: $bolivares)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                   
                                
                                Button(action: {
                                    UIPasteboard.general.string = bolivares
                                    showToastMessage()
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                    .padding(10)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
                
                VStack {
                    Text("Act. Paralelo: \(fechaActualizacionParalelo)")
                    Text("Act. BCV: \(fechaActualizacionBCV)")
                }
                .foregroundColor(.black)
                
                Button(action: {
                    Task {
                        isLoading = true
                        await fetchDollarRates()
                        isLoading = false
                    }
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding()
            .onAppear {
                Task {
                    isLoading = true
                    await fetchDollarRates()
                    isLoading = false
                }
            }
            
            // Mensaje tipo Toast que aparece temporalmente
            if showToast {
                VStack {
                    Spacer()
                    Text("Valor copiado al portapapeles")
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                }
                .transition(.opacity)
               // .animation(.easeInOut)
            }
        }
    }
    
    func showToastMessage() {
        withAnimation {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
    
    func convertirDolaresABolivares() {
        if let dolares = Double(dolares), let tasa = Double(tasaBCV) {
            let bolivares = dolares * tasa
            self.bolivares = String(format: "%.2f", bolivares)
        }
    }

    func convertirBolivaresADolares() {
        if let bolivares = Double(bolivares), let tasa = Double(tasaBCV) {
            let dolares = bolivares / tasa
            self.dolares = String(format: "%.2f", dolares)
        }
    }
    
    func fetchDollarRates() async {
        do {
            let apiService = ApiNetwork()
            let dollarData = try await apiService.getDollarRates()
            tasaBCV = String(format: "%.2f", dollarData.monitors.bcv.price)
            tasaParalelo = String(format: "%.2f", dollarData.monitors.enparalelovzla.price)
            fechaActualizacionBCV = dollarData.monitors.bcv.lastUpdate
            fechaActualizacionParalelo = dollarData.monitors.enparalelovzla.lastUpdate
        } catch {
            print("Error al obtener las tasas de dólar: \(error)")
        }
    }
    
    func tasaPromedio() -> String {
        if let bcv = Double(tasaBCV), let paralelo = Double(tasaParalelo) {
            let promedio = (bcv + paralelo) / 2
            return String(format: "%.2f", promedio)
        }
        return "0.00"
    }
}

struct DolarAlDiaView_Previews: PreviewProvider {
    static var previews: some View {
        DolarAlDiaView()
    }
}

