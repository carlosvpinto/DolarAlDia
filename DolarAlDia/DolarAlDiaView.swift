//
//  DolarAlDiaView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/1/24.
//

import SwiftUI

import FirebaseCore
import FirebaseFirestore
struct DolarAlDiaView: View {
    @Binding var dolares: String
    @Binding var bolivares: String
    @Binding var tasaBCV: String
    @Binding var tasaParalelo: String
    @Binding var tasaPromedio: String
    
    @Binding var selectedButton: String
    @State private var porcentajeParalelo: String = ""
    @State private var porcentajeBcv: String = ""
    @State private var simboloBcv: String = ""
    @State private var simboloParalelo: String = ""
    @State private var fechaActualizacionParalelo: String = "29/11/2024, 01:39 PM"
    @State private var fechaActualizacionBCV: String = "02/12/2024"
    
    @State private var isLoading: Bool = false
    
    @State private var showToast: Bool = false
    
    
    // Estados para controlar el foco de los TextFields
    @FocusState private var isDolaresFocused: Bool // Usamos FocusState para manejar el enfoque
    // @State private var isBolivaresFocused: Bool = false
    
    @State private var cantidadDolares: String = ""
    @State private var cantidadBolivares: String = ""
    
    @State private var showSheet = false
    @State private var mensaje = ""
    @State private var diferenciaBs = 0.0
    @State private var diferenciaDolares = 0.0
    @State private var diferenciaPorcentual = 0.0
    @State private var isMenuPresented = false
    @Environment(\.colorScheme) var colorScheme
    
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
                    
                    BotonInfoPrecio(mostrar:false, valorDolar: funTasaPromedio(), nombreDolar: Constants.DOLARPROMEDIO, simboloFlecha: "", variacionPorcentaje: "", isSelected: selectedButton == Constants.DOLARPROMEDIO) {
                        selectedButton = Constants.DOLARPROMEDIO
                        convertirDolaresABolivares()
                        convertirBolivaresADolares()
                    }
                    .padding(.top, 5)
                    .frame(maxWidth: buttonWidth)
                    
                    HStack(spacing: 20) {
                        BotonInfoPrecio(mostrar:true,valorDolar: tasaBCV, nombreDolar: Constants.DOLARBCV, simboloFlecha: simboloBcv, variacionPorcentaje: porcentajeBcv, isSelected: selectedButton == Constants.DOLARBCV) {
                            selectedButton = Constants.DOLARBCV
                            convertirDolaresABolivares()
                            convertirBolivaresADolares()
                        }
                        .frame(maxWidth: buttonWidth)
                        
                        BotonInfoPrecio(mostrar:true,valorDolar: tasaParalelo, nombreDolar: Constants.DOLARPARALELO, simboloFlecha: simboloParalelo, variacionPorcentaje: porcentajeParalelo, isSelected: selectedButton == Constants.DOLARPARALELO) {
                            selectedButton = Constants.DOLARPARALELO
                            convertirDolaresABolivares()
                            convertirBolivaresADolares()
                        }
                        .frame(maxWidth: buttonWidth)
                    }
                    
                    HStack {
                        
                        VStack(alignment: .leading, spacing: -10) {
                            HStack {
                                TextFieldPersonal(placeholder: "Dolares", startIcon: "icon-dollar", text: $dolares, onClearAll: limpiarCampos)
                                    .focused($isDolaresFocused)
                                    .onChange(of: dolares) {
                                        convertirDolaresABolivares() // Llamada a la función de conversión
                                    }
                                
                                Button(action: {
                                    UIPasteboard.general.string = dolares
                                    print("Bs  \(dolares)")
                                    showToastMessage()
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            HStack {
                                // Aquí llamamos a convertirBolivaresADolares cuando el texto cambie
                                TextFieldPersonal(placeholder: "Bolívares", startIcon: "icon-bs", text: $bolivares, onClearAll: limpiarCampos)
                                    .onChange(of: bolivares) {
                                        convertirBolivaresADolares() // Llamada a la función de conversión
                                    }
                                
                                Button(action: {
                                    UIPasteboard.general.string = bolivares
                                    
                                    showToastMessage()
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        Button(action:{
                            //Colocar Funcion para comparar el dolar
                            calcularDiferencia()
                            showSheet = true
                            
                        }){
                            Image(systemName: "mail.and.text.magnifyingglass")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                               
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
                
                Button(action: {
                    Task {
                        print("paso por el REFRESH BOTON")
                        isLoading = true
                        await llamarApiDolar()
                    
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
                tasaPromedio = funTasaPromedio()
                Task {
                
                    isLoading = true
                    await llamarApiDolar()
                    isLoading = false
                }
                
            }.sheet(isPresented: $showSheet) {
                ResultSheet(
                    mensaje: mensaje,
                    diferenciaBs: diferenciaBs,
                    diferenciaDolares: diferenciaDolares,
                    diferenciaPorcentual: diferenciaPorcentual
                )
                .presentationDetents([.medium, .large]) // Permite elegir entre medium y large
            }
            
            if showToast {
                ZStack {
                    Color.clear // Ayuda a usar ZStack como contenedor sin cambiar el fondo.

                    VStack {
                        Text("Valor copiado al portapapeles")
                            .font(.headline)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Asegura que ocupe toda la pantalla.
                .background(Color.clear) // Fondo transparente para no bloquear la vista.
                .transition(.opacity)
            }

            
            if isLoading {
                ZStack {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        ProgressView("Actualizando...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .background(colorScheme == .dark ? Color.black : Color.white)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                }
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
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        numberFormatter.decimalSeparator = ","
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2

        if isDolaresFocused {
            let dolaresNormalizados = dolares.replacingOccurrences(of: ",", with: ".")
            
            if let dolares = Double(dolaresNormalizados) {
                var tasa: Double = 0
                
                switch selectedButton {
                case Constants.DOLARBCV:
                    tasa = Double(tasaBCV) ?? 0
                case Constants.DOLARPARALELO:
                    tasa = Double(tasaParalelo) ?? 0
                case Constants.DOLARPROMEDIO:
                    tasa = Double(funTasaPromedio()) ?? 0
                default:
                    break
                }
                
                let bolivares = dolares * tasa
                
                if let formattedBolivares = numberFormatter.string(from: NSNumber(value: bolivares)) {
                    self.bolivares = formattedBolivares
                } else {
                    self.bolivares = String(format: "%.2f", bolivares)
                }
            }
        }
    }

    
    
    func convertirBolivaresADolares() {
        print("Convertir Bolivares a Dolares")
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        numberFormatter.decimalSeparator = ","
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        if !isDolaresFocused {
            let bolivaresNormalizados = bolivares.replacingOccurrences(of: ",", with: ".")
            
            if let bolivares = Double(bolivaresNormalizados) {
                var tasa: Double = 0
                
                switch selectedButton {
                case Constants.DOLARBCV:
                    tasa = Double(tasaBCV) ?? 0
                case Constants.DOLARPARALELO:
                    tasa = Double(tasaParalelo) ?? 0
                case Constants.DOLARPROMEDIO:
                    tasa = Double(funTasaPromedio()) ?? 0
                default:
                    break
                }
                
                if tasa > 0 {
                    let dolares = bolivares / tasa
                    
                    if let formattedDolares = numberFormatter.string(from: NSNumber(value: dolares)) {
                        self.dolares = formattedDolares
                    } else {
                        self.dolares = String(format: "%.2f", dolares)
                    }
                }
            }
        }
    }

    // Esta función se encarga de limpiar todos los campos
    func limpiarCampos() {
        dolares = ""
        bolivares = ""
        
    }
    
    func llamarApiDolar() async {
        print("llamo al api para actualizar los datos")
        do {
            let apiService = ApiNetwork()
            let dollarData = try await apiService.getDollarRatesBasedOnTime()
            tasaBCV = String(format: "%.2f", dollarData.monitors.bcv.price)
            tasaParalelo = String(format: "%.2f", dollarData.monitors.enparalelovzla.price)
            porcentajeBcv = dollarData.monitors.bcv.percent.description
            porcentajeParalelo = dollarData.monitors.enparalelovzla.percent.description
            simboloBcv = dollarData.monitors.bcv.symbol
            simboloParalelo = dollarData.monitors.enparalelovzla.symbol
            fechaActualizacionBCV = dollarData.monitors.bcv.lastUpdate
            fechaActualizacionParalelo = dollarData.monitors.enparalelovzla.lastUpdate
            tasaPromedio = funTasaPromedio()
            calcularDiferencia()
        } catch {
            print("Error al obtener las tasas de dólar: \(error)")
        }
    }
    
    func calcularDiferencia() {
        // Actualizamos los valores de diferencia
        
        mensaje = "Diferencia Cambiaria"
        diferenciaBs = (Double(tasaParalelo) ?? 1.0) * (Double(dolares) ?? 1.0) - (Double(tasaBCV) ?? 1.0) * (Double(dolares) ?? 1.0)
        
        diferenciaDolares = ((Double(tasaParalelo) ?? 1.0) * (Double(dolares) ?? 1.0) - (Double(tasaBCV) ?? 1.0) * (Double(dolares) ?? 1.0)) / (Double(tasaBCV) ?? 1.0)
        let diferenciadolares = (Double(tasaParalelo) ?? 1.0) - (Double(tasaBCV) ?? 1.0)
        diferenciaPorcentual =  (diferenciadolares / (Double(tasaBCV) ?? 1.0)) * 100
        // Asegurarse de que todos los valores estén actualizados
        // Mostrar el sheet solo después de actualizar los valores
        // showSheet = true
    }
    
    
    
    func funTasaPromedio() -> String {
        if let bcv = Double(tasaBCV), let paralelo = Double(tasaParalelo) {
            let promedios = (bcv + paralelo) / 2
            
            return String(format: "%.2f", promedios)
        }
        return "0.00"
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//struct DolarAlDiaView_Previews: PreviewProvider {
//    static var previews: some View {
//        DolarAlDiaView()
//    }
//}
