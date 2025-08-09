//
//  DolarAlDiaView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/1/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

enum CampoDeEnfoque: Hashable {
    case dolares
    case bolivares
}

struct DolarAlDiaView: View {
    @Binding var dolares: String
    @Binding var bolivares: String
    @Binding var tasaBCV: String
    @Binding var tasaEuro: String

    @Binding var selectedButton: String
    @State private var porcentajeParalelo: String = ""
    @State private var porcentajeBcv: String = ""
    @State private var simboloBcv: String = ""
    @State private var simboloParalelo: String = ""
    @State private var fechaActualizacionParalelo: String = "Cargando..."
    @State private var fechaActualizacionBCV: String = "Cargando..."
    @State private var isLoading: Bool = false
    @State private var showToast: Bool = false
    
    @FocusState private var campoEnfocado: CampoDeEnfoque?
    
    @State private var isOffline: Bool = false
    @State private var statusMessage: String? = nil
    
    @State private var animateDateUpdate: Bool = false

    @State private var cantidadDolares: String = ""
    @State private var cantidadBolivares: String = ""
    @State private var showSheet = false
    @State private var mensaje = ""
    @State private var diferenciaBs = 0.0
    @State private var diferenciaDolares = 0.0
    @State private var diferenciaPorcentual = 0.0
    @State private var isMenuPresented = false
    @Environment(\.colorScheme) var colorScheme
    
    var placeholderMoneda: String {
        selectedButton == Constants.DOLARBCV ? "Dólares" : "Euro"
    }
    var startIconMoneda: String {
        selectedButton == Constants.DOLARBCV ? "icon-dollar" : "euro"
    }


    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                GeometryReader { geometry in
                    VStack(spacing: 10) {
                        Image("logoredondo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)

                        HStack(spacing: 20) {
                            BotonInfoPrecio(mostrar:true, valorDolar: tasaBCV, nombreDolar: Constants.DOLARBCV, simboloFlecha: simboloBcv, variacionPorcentaje: porcentajeBcv, isSelected: selectedButton == Constants.DOLARBCV) {
                                selectedButton = Constants.DOLARBCV
                                convertirDolaresABolivares()
                                convertirBolivaresADolares()
                            }
                            .frame(maxWidth: .infinity)

                            BotonInfoPrecio(mostrar:true, valorDolar: tasaEuro, nombreDolar: Constants.DOLAREUROBCV, simboloFlecha: simboloParalelo, variacionPorcentaje: porcentajeParalelo, isSelected: selectedButton == Constants.DOLAREUROBCV) {
                                selectedButton = Constants.DOLAREUROBCV
                                convertirDolaresABolivares()
                                convertirBolivaresADolares()
                            }
                            .frame(maxWidth: .infinity)
                        }

                        HStack {
                            VStack(alignment: .leading, spacing: -10) {
                                HStack {
                                    TextFieldPersonal(placeholder: placeholderMoneda, startIcon: startIconMoneda, text: $dolares, onClearAll: limpiarCampos)
                                        .focused($campoEnfocado, equals: .dolares)
                                        .onChange(of: dolares) {
                                            convertirDolaresABolivares()
                                        }
                                    Button(action: {
                                        UIPasteboard.general.string = dolares
                                        showToastMessage()
                                    }) {
                                        Image(systemName: "doc.on.doc")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.blue)
                                    }
                                }
                                HStack {
                                    TextFieldPersonal(placeholder: "Bolivares", startIcon: "icon-bs", text: $bolivares, onClearAll: limpiarCampos)
                                        .focused($campoEnfocado, equals: .bolivares)
                                        .onChange(of: bolivares) {
                                            convertirBolivaresADolares()
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
                }
            }
            .padding()
            .onAppear {
                Task {
                    await cargarDatosCacheados()
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
                .presentationDetents([.medium, .large])
            }
            VStack {
                    Spacer()
                
                HStack(alignment: .center, spacing: 15) {
                    if isOffline {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.title2)
                            .foregroundColor(.orange)
                            .transition(.scale.animation(.spring()))
                    }
                }
                    
                    VStack {
                        Text("Act. BCV: \(fechaActualizacionBCV.components(separatedBy: ",").first ?? fechaActualizacionBCV)")
                               .font(.body)
                               .fontWeight(.bold)
                               .foregroundColor(animateDateUpdate ? .green : .gray)
                               .scaleEffect(animateDateUpdate ? 1.1 : 1.0)
                               .shadow(color: animateDateUpdate ? .green.opacity(0.5) : .clear, radius: 5, x: 0, y: 0)
                               .padding(.bottom, 2)
                        
                        Button(action: {
                            Task {
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
                    }
                    .padding(.bottom, 30)
                }
                .ignoresSafeArea(.keyboard)

            if showToast {
                ZStack {
                    Color.clear
                    VStack {
                        Text("Valor copiado al portapapeles")
                            .font(.headline)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
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

            if let message = statusMessage {
               VStack {
                   Spacer()
                   Text(message)
                       .font(.headline)
                       .foregroundColor(.white)
                       .padding()
                       .background(.black.opacity(0.6))
                       .clipShape(Capsule())
                       .transition(.move(edge: .bottom).combined(with: .opacity))
               }
               .padding(.bottom, 140)
           }
       }
       .onTapGesture {
           campoEnfocado = nil
       }
    }
    
    // --- NUEVA FUNCIÓN HELPER ---
    // Convierte una cadena de texto a un objeto Date
    private func parseDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy, hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Importante para AM/PM
        return formatter.date(from: dateString)
    }

    private var isDolaresFocused: Bool {
        campoEnfocado == .dolares
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
    
    func cargarDatosCacheados() async {
        if let cachedData = CacheManager.shared.load() {
            self.tasaBCV = String(format: "%.2f", cachedData.tasaBCV)
            self.tasaEuro = String(format: "%.2f", cachedData.tasaEuro)
            self.porcentajeBcv = cachedData.porcentajeBcv
            self.porcentajeParalelo = cachedData.porcentajeParalelo
            self.simboloBcv = cachedData.simboloBcv
            self.simboloParalelo = cachedData.simboloParalelo
            self.fechaActualizacionBCV = cachedData.fechaActualizacionBCV
            self.fechaActualizacionParalelo = cachedData.fechaActualizacionParalelo
            print("Datos cargados desde el caché.")
        } else {
            print("No se encontraron datos en el caché.")
        }
    }
    
    func convertirDolaresABolivares() {
        // ... (sin cambios en esta función)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        numberFormatter.decimalSeparator = ","
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2

        if isDolaresFocused {
            let dolaresNormalizados = normalizaNumero(dolares)
            guard !dolaresNormalizados.isEmpty else {
                self.bolivares = ""
                return
            }

            if let dolares = Double(dolaresNormalizados) {
                var tasa: Double = 0
                switch selectedButton {
                case Constants.DOLARBCV:
                    tasa = Double(tasaBCV.replacingOccurrences(of: ",", with: ".")) ?? 0
                case Constants.DOLAREUROBCV:
                    tasa = Double(tasaEuro.replacingOccurrences(of: ",", with: ".")) ?? 0
                default:
                    break
                }
                let bolivares = dolares * tasa
                if let formattedBolivares = numberFormatter.string(from: NSNumber(value: bolivares)) {
                    self.bolivares = formattedBolivares
                } else {
                    self.bolivares = String(format: "%.2f", bolivares)
                }
            } else {
                self.bolivares = ""
            }
        }
    }

    func convertirBolivaresADolares() {
        // ... (sin cambios en esta función)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        numberFormatter.decimalSeparator = ","
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2

        if !isDolaresFocused {
            let bolivaresNormalizados = normalizaNumero(bolivares)
            guard !bolivaresNormalizados.isEmpty else {
                self.dolares = ""
                return
            }

            if let bolivares = Double(bolivaresNormalizados) {
                var tasa: Double = 0
                switch selectedButton {
                case Constants.DOLARBCV:
                    tasa = Double(tasaBCV.replacingOccurrences(of: ",", with: ".")) ?? 0
                case Constants.DOLAREUROBCV:
                    tasa = Double(tasaEuro.replacingOccurrences(of: ",", with: ".")) ?? 0
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
            } else {
                self.dolares = ""
            }
        }
    }

    func normalizaNumero(_ valor: String) -> String {
        // ... (sin cambios en esta función)
        var limpio = valor.replacingOccurrences(of: ".", with: "")
        limpio = limpio.replacingOccurrences(of: ",", with: ".")
        limpio = limpio.replacingOccurrences(of: " ", with: "")
        return limpio
    }

    func limpiarCampos() {
        dolares = ""
        bolivares = ""
    }

    func llamarApiDolar() async {
        do {
            print("🚀 Iniciando llamada a la API de Dólar...")
            let apiService = ApiNetworkDolarAlDia()
            let dollarData = try await apiService.getDollarRates()
            
            let now = Date() // Obtenemos la fecha y hora actual una sola vez.

            var tasaBCVCache: Double = 0
            var tasaEuroCache: Double = 0
            var porcentajeBcvCache: String = ""
            var porcentajeParaleloCache: String = ""
            var simboloBcvCache: String = ""
            var simboloParaleloCache: String = ""
            var fechaBcvCache: String = ""
            var fechaEuroCache: String = ""
            
            // --- Procesamos el Dólar (USD) con la nueva lógica ---
            if let usdMonitor = dollarData.monitors["usd"] {
                // Parseamos la fecha de actualización para poder compararla.
                let lastUpdateDate = parseDate(from: usdMonitor.lastUpdate) ?? now
                
                // Decidimos si usamos los datos antiguos ('old') o los actuales.
                let useOldData = lastUpdateDate > now
                
                let priceToUse = useOldData ? usdMonitor.priceOld : usdMonitor.price
                let percentToUse = useOldData ? (usdMonitor.percentOld ?? 0.0) : usdMonitor.percent
                let lastUpdateToUse = useOldData ? (usdMonitor.lastUpdateOld ?? "N/A") : usdMonitor.lastUpdate
                
                // Asignamos los valores a la UI
                tasaBCV = String(format: "%.2f", priceToUse)
                porcentajeBcv = String(format: "%.2f", percentToUse)
                simboloBcv = usdMonitor.symbol
                fechaActualizacionBCV = lastUpdateToUse
                
                // Guardamos los valores para el caché
                tasaBCVCache = priceToUse
                porcentajeBcvCache = String(format: "%.2f", percentToUse)
                simboloBcvCache = usdMonitor.symbol
                fechaBcvCache = lastUpdateToUse
                
                print(useOldData ? "✅ Datos USD (OLD) procesados." : "✅ Datos USD (Current) procesados.")
            } else {
                print("⚠️ No se encontró el monitor 'usd' en la respuesta.")
            }

            // --- Procesamos el Euro (EUR) con la nueva lógica ---
            if let eurMonitor = dollarData.monitors["eur"] {
                let lastUpdateDate = parseDate(from: eurMonitor.lastUpdate) ?? now
                let useOldData = lastUpdateDate > now

                let priceToUse = useOldData ? eurMonitor.priceOld : eurMonitor.price
                let percentToUse = useOldData ? (eurMonitor.percentOld ?? 0.0) : eurMonitor.percent
                let lastUpdateToUse = useOldData ? (eurMonitor.lastUpdateOld ?? "N/A") : eurMonitor.lastUpdate
                
                // Asignamos los valores a la UI
                tasaEuro = String(format: "%.2f", priceToUse)
                porcentajeParalelo = String(format: "%.2f", percentToUse)
                simboloParalelo = eurMonitor.symbol
                fechaActualizacionParalelo = lastUpdateToUse
                
                // Guardamos los valores para el caché
                tasaEuroCache = priceToUse
                porcentajeParaleloCache = String(format: "%.2f", percentToUse)
                simboloParaleloCache = eurMonitor.symbol
                fechaEuroCache = lastUpdateToUse
                
                print(useOldData ? "✅ Datos EUR (OLD) procesados." : "✅ Datos EUR (Current) procesados.")
            } else {
                print("⚠️ No se encontró el monitor 'eur' en la respuesta.")
            }
            
            calcularDiferencia()
            
            let dataToCache = DollarDataCache(
                tasaBCV: tasaBCVCache,
                tasaEuro: tasaEuroCache,
                porcentajeBcv: porcentajeBcvCache,
                porcentajeParalelo: porcentajeParaleloCache,
                simboloBcv: simboloBcvCache,
                simboloParalelo: simboloParaleloCache,
                fechaActualizacionBCV: fechaBcvCache,
                fechaActualizacionParalelo: fechaEuroCache,
                timestamp: Date()
            )
            CacheManager.shared.save(data: dataToCache)
            print("Nuevos datos de la API guardados en caché.")
            
            if isOffline {
                isOffline = false
                showStatusMessage("¡Conexión restablecida!")
            }
            
            await MainActor.run {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    animateDateUpdate = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut) {
                        animateDateUpdate = false
                    }
                }
            }
            
        } catch {
            print("❌ ERROR en llamarApiDolar: \(error)")
            print("❌ Descripción localizada del error: \(error.localizedDescription)")
            isOffline = true
            showStatusMessage("No se pudo actualizar. Verifique su conexión.")
            HapticManager.shared.play(.error)
            print("Error al obtener las tasas de dólar desde la API: \(error). Se mantendrán los datos cacheados.")
        }
    }
    
    func showStatusMessage(_ message: String) {
       // ... (sin cambios en esta función)
       Task { @MainActor in
           self.statusMessage = message
           try? await Task.sleep(nanoseconds: 3_000_000_000)
           self.statusMessage = nil
       }
   }
    
    func calcularDiferencia() {
        // ... (sin cambios en esta función)
        mensaje = "Diferencia Cambiaria"
        let tasaEuroDouble = Double(tasaEuro.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        let tasaBCVDouble = Double(tasaBCV.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        let dolaresDouble = Double(normalizaNumero(dolares)) ?? 0.0
        
        if tasaBCVDouble > 0 && dolaresDouble > 0 {
            diferenciaBs = (tasaEuroDouble * dolaresDouble) - (tasaBCVDouble * dolaresDouble)
            diferenciaDolares = diferenciaBs / tasaBCVDouble
            let diferenciaDeTasas = tasaEuroDouble - tasaBCVDouble
            diferenciaPorcentual = (diferenciaDeTasas / tasaBCVDouble) * 100
        } else {
            diferenciaBs = 0
            diferenciaDolares = 0
            diferenciaPorcentual = 0
        }
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
