//
//  DolarAlDiaView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/1/24.
//

import SwiftUI


struct DolarAlDiaView: View {
    @State private var dolares: String = ""
    @State private var bolivares: String = ""
    @State private var tasaBCV: String = ""
    @State private var tasaParalelo: String = ""
    @State private var porcentajeParalelo: String = ""
    @State private var porcentajeBcv: String = ""
    @State private var simboloBcv: String = ""
    @State private var simboloParalelo: String = ""
    @State private var fechaActualizacionParalelo: String = "29/11/2024, 01:39 PM"
    @State private var fechaActualizacionBCV: String = "02/12/2024"
    
    @State private var isLoading: Bool = false
    @State private var selectedButton: String = "Dolar Bcv"
    @State private var showToast: Bool = false

    
    // Estados para controlar el foco de los TextFields
    @FocusState private var isDolaresFocused: Bool // Usamos FocusState para manejar el enfoque
        @State private var isBolivaresFocused: Bool = false
    
       @State private var cantidadDolares: String = ""
       @State private var cantidadBolivares: String = ""

        @State private var showSheet = false
       @State private var mensaje = ""
       @State private var diferenciaBs = 0.0
       @State private var diferenciaDolares = 0.0
       @State private var diferenciaPorcentual = 0.0
    @State private var isMenuPresented = false
    
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
                    
                    BotonInfoPrecio(mostrar:false, valorDolar: tasaPromedio(), nombreDolar: "Dolar Promedio", simboloFlecha: "", variacionPorcentaje: "", isSelected: selectedButton == "Dolar Promedio") {
                        selectedButton = "Dolar Promedio"
                        convertirDolaresABolivares()
                        convertirBolivaresADolares()
                    }
                    .padding(.top, 5)
                    .frame(maxWidth: buttonWidth)
                    
                    HStack(spacing: 20) {
                        BotonInfoPrecio(mostrar:true,valorDolar: tasaBCV, nombreDolar: "Dolar Bcv", simboloFlecha: simboloBcv, variacionPorcentaje: porcentajeBcv, isSelected: selectedButton == "Dolar Bcv") {
                            selectedButton = "Dolar Bcv"
                            convertirDolaresABolivares()
                            convertirBolivaresADolares()
                        }
                        .frame(maxWidth: buttonWidth)
                        
                        BotonInfoPrecio(mostrar:true,valorDolar: tasaParalelo, nombreDolar: "Dolar Paralelo", simboloFlecha: simboloParalelo, variacionPorcentaje: porcentajeParalelo, isSelected: selectedButton == "Dolar Paralelo") {
                            selectedButton = "Dolar Paralelo"
                            convertirDolaresABolivares()
                            convertirBolivaresADolares()
                        }
                        .frame(maxWidth: buttonWidth)
                    }
                    
                    HStack {
                     
                        VStack(alignment: .leading, spacing: -10) {
                            HStack {
                                TextFieldPersonal(placeholder: "Dolares", startIcon: "dollarsign.circle.fill", text: $dolares, onClearAll: limpiarCampos) // Pasamos la función para limpiar todos los campos)
                                    .focused($isDolaresFocused)
                                    .onChange(of: dolares) { _ in
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
                                        .foregroundColor(.black)
                                }
                            }
                            
                            HStack {
                                // Aquí llamamos a convertirBolivaresADolares cuando el texto cambie
                                TextFieldPersonal(placeholder: "Bolívares", startIcon: "dollarsign.circle.fill", text: $bolivares,onClearAll: limpiarCampos)
                                   
                                    .onChange(of: bolivares) { _ in
                                        convertirBolivaresADolares() // Llamada a la función de conversión
                                    }
                                
                                Button(action: {
                                    UIPasteboard.general.string = bolivares
                                    print(bolivares)
                                    showToastMessage()
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
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
                                .foregroundColor(.black)
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
            }
            
            if isLoading {
                ZStack {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        ProgressView("Actualizando...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .background(Color.white)
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
        // Formateador de números para agregar separadores de miles y puntos decimales
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        numberFormatter.decimalSeparator = ","
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2

        if isDolaresFocused {
            var tasa: Double?

            if selectedButton == "Dolar Bcv" {
                tasa = Double(tasaBCV)
            } else if selectedButton == "Dolar Paralelo" {
                tasa = Double(tasaParalelo)
            } else if selectedButton == "Dolar Promedio" {
                tasa = Double(tasaPromedio())
            }

            // Asegurarse de que las conversiones de tasa y dólares sean válidas
            if let dolares = Double(dolares), let tasa = tasa {
                let bolivares = dolares * tasa
                
                // Formatear el valor de bolívares con separadores de miles y decimales
                if let formattedBolivares = numberFormatter.string(from: NSNumber(value: bolivares)) {
                    self.bolivares = formattedBolivares
                } else {
                    self.bolivares = String(format: "%.2f", bolivares) // En caso de error, formato estándar
                }
            }
        }
    }


    func convertirBolivaresADolares() {
        // Formateador de números para agregar separadores de miles y puntos decimales
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        numberFormatter.decimalSeparator = ","
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2

        if !isDolaresFocused {
            var tasa: Double?

            if selectedButton == "Dolar Bcv" {
                tasa = Double(tasaBCV)
            } else if selectedButton == "Dolar Paralelo" {
                tasa = Double(tasaParalelo)
            } else if selectedButton == "Dolar Promedio" {
                tasa = Double(tasaPromedio())
            }

            // Asegurarse de que las conversiones de tasa y dólares sean válidas
            if let bolivares = Double(bolivares), let tasa = tasa {
                let dolares = bolivares / tasa
                
                // Formatear el valor de bolívares con separadores de miles y decimales
                if let formattedDolares = numberFormatter.string(from: NSNumber(value: dolares)) {
                    self.dolares = formattedDolares
                } else {
                    self.dolares = String(format: "%.2f", dolares) // En caso de error, formato estándar
                }
            }
        }
       
    }
      // Esta función se encarga de limpiar todos los campos
       func limpiarCampos() {
           dolares = ""
           bolivares = ""
                                                    
       }
    
    func fetchDollarRates() async {
        do {
            let apiService = ApiNetwork()
            let dollarData = try await apiService.getDollarRates()
            tasaBCV = String(format: "%.2f", dollarData.monitors.bcv.price)
            tasaParalelo = String(format: "%.2f", dollarData.monitors.enparalelovzla.price)
            porcentajeBcv = dollarData.monitors.bcv.percent.description
            porcentajeParalelo = dollarData.monitors.enparalelovzla.percent.description
            simboloBcv = dollarData.monitors.bcv.symbol
            simboloParalelo = dollarData.monitors.enparalelovzla.symbol
            fechaActualizacionBCV = dollarData.monitors.bcv.lastUpdate
            fechaActualizacionParalelo = dollarData.monitors.enparalelovzla.lastUpdate
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


    
    func tasaPromedio() -> String {
        if let bcv = Double(tasaBCV), let paralelo = Double(tasaParalelo) {
            let promedio = (bcv + paralelo) / 2
            return String(format: "%.2f", promedio)
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
