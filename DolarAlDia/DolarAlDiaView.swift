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
    @State private var fechaActualizacionParalelo: String = "29/11/2024, 01:39 PM"
    @State private var fechaActualizacionBCV: String = "02/12/2024"
    @State private var isLoading: Bool = false
    @State private var showToast: Bool = false
    
    // @FocusState por uno que usa nuestro enum.
        @FocusState private var campoEnfocado: CampoDeEnfoque?
    
    // Nuevos estados para la conexión y mensajes
       @State private var isOffline: Bool = false
       @State private var statusMessage: String? = nil
    
    //para controlar la animación de la fecha
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
                      //  let screenWidth = UIScreen.main.bounds.width
                      //  let padding: CGFloat = 40
                     //   let buttonWidth = (screenWidth - padding) / 2

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
                                    // Paso 4: Vinculamos el TextField de Dólares al nuevo @FocusState.
                                    TextFieldPersonal(placeholder: placeholderMoneda, startIcon: startIconMoneda, text: $dolares, onClearAll: limpiarCampos)
                                        .focused($campoEnfocado, equals: .dolares) // <-- CAMBIO
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
                                        .focused($campoEnfocado, equals: .bolivares) // <-- CAMBIO
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
                
                // 1. Al aparecer la vista, primero cargamos los datos cacheados.
               
                
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
                    // MARK: - Paso 3: Icono de sin conexión
                    // Este icono solo aparecerá si isOffline es true.
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
                               // El color del texto cambia a verde cuando se activa la animación.
                               .foregroundColor(animateDateUpdate ? .green : .gray)
                               // El tamaño del texto aumenta ligeramente para un efecto "pulso".
                               .scaleEffect(animateDateUpdate ? 1.1 : 1.0)
                               // Añadimos una sombra brillante para el efecto "glow".
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
                .ignoresSafeArea(.keyboard) // <

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
            // Muestra un banner en la parte inferior si hay un mensaje.
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
                           .padding(.bottom, 140) // Ajusta la posición vertical del mensaje
                       }
                   }
                   .onTapGesture {
                       campoEnfocado = nil
                   }
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
               // Actualizamos la UI con los datos del caché
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
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        numberFormatter.decimalSeparator = ","
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2

        if isDolaresFocused {
            let dolaresNormalizados = normalizaNumero(dolares)
            print("[DEBUG] dolares a bolivares normalizados:", dolaresNormalizados)  // <--- AQUÍ
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

    // Convierte: "1.234,56", "1234,56", "1,234.56" (y similares) a "1234.56"
    func normalizaNumero(_ valor: String) -> String {
        // 1. Elimina los puntos de miles
        var limpio = valor.replacingOccurrences(of: ".", with: "")
        // 2. Cambia la coma decimal a punto
        limpio = limpio.replacingOccurrences(of: ",", with: ".")
        // Quita espacios
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

                // --- CAMBIO IMPORTANTE ---
                // Cuando la API responde con éxito:
                
                // 1. Actualizamos la UI (lo que ya hacías)
                tasaBCV = String(format: "%.2f", dollarData.monitors.bcv.price)
                tasaEuro = String(format: "%.2f", dollarData.monitors.bcvEur.price)
                porcentajeBcv = dollarData.monitors.bcv.percent.description
                porcentajeParalelo = dollarData.monitors.bcvEur.percent.description
                simboloBcv = dollarData.monitors.bcv.symbol
                simboloParalelo = dollarData.monitors.bcvEur.symbol
                fechaActualizacionBCV = dollarData.monitors.bcv.lastUpdate
                fechaActualizacionParalelo = dollarData.monitors.bcvEur.lastUpdate
                calcularDiferencia()
                
                print("✅ ¡Éxito! Datos decodificados correctamente. Tasa BCV: \(dollarData.monitors.bcv.price)")
                // 2. Creamos un objeto para el caché
                let dataToCache = DollarDataCache(
                    tasaBCV: dollarData.monitors.bcv.price,
                    tasaEuro: dollarData.monitors.bcvEur.price,
                    porcentajeBcv: dollarData.monitors.bcv.percent.description,
                    porcentajeParalelo: dollarData.monitors.bcvEur.percent.description,
                    simboloBcv: dollarData.monitors.bcv.symbol,
                    simboloParalelo: dollarData.monitors.bcvEur.symbol,
                    fechaActualizacionBCV: dollarData.monitors.bcv.lastUpdate,
                    fechaActualizacionParalelo: dollarData.monitors.bcvEur.lastUpdate,
                    timestamp: Date() // Guardamos la fecha actual
                )
                if isOffline {
                    isOffline = false
                    showStatusMessage("¡Conexión restablecida!")
                    // 3. Guardamos los nuevos datos en el caché
                    CacheManager.shared.save(data: dataToCache)
                    
                }
                await MainActor.run {
                    // 1. Activamos la animación con un efecto de resorte.
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                        animateDateUpdate = true
                    }
                    
                    // 2. Después de un segundo, desactivamos la animación para que vuelva a su estado normal.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut) {
                            animateDateUpdate = false
                        }
                    }
                }

             
                
                print("Nuevos datos de la API guardados en caché.")

            } catch {
                // Si la API falla, no hacemos nada. La vista ya estará mostrando
                // los últimos datos válidos que cargamos desde el caché.
                // 1. Activamos el estado de "sin conexión"
                print("❌ ERROR en llamarApiDolar: \(error)")
                      print("❌ Descripción localizada del error: \(error.localizedDescription)")

                isOffline = true
                
                // 2. Mostramos un mensaje de error al usuario
                showStatusMessage("No se pudo actualizar. Verifique su conexión.")
                
                // 3. ¡AÑADIMOS LA VIBRACIÓN DE ERROR!
                HapticManager.shared.play(.error)
                
        
                print("Error al obtener las tasas de dólar desde la API: \(error). Se mantendrán los datos cacheados.")
            }
        }
    // Nueva función para mostrar mensajes temporales
       func showStatusMessage(_ message: String) {
           // Usamos MainActor para asegurar que la actualización de la UI ocurra en el hilo principal
           Task { @MainActor in
               self.statusMessage = message
               // Hacemos que el mensaje desaparezca después de 3 segundos
               try? await Task.sleep(nanoseconds: 3_000_000_000)
               self.statusMessage = nil
           }
       }
        
    

    func calcularDiferencia() {
        mensaje = "Diferencia Cambiaria"
        diferenciaBs = (Double(tasaEuro) ?? 1.0) * (Double(dolares) ?? 1.0) - (Double(tasaBCV) ?? 1.0) * (Double(dolares) ?? 1.0)
        diferenciaDolares = ((Double(tasaEuro) ?? 1.0) * (Double(dolares) ?? 1.0) - (Double(tasaBCV) ?? 1.0) * (Double(dolares) ?? 1.0)) / (Double(tasaBCV) ?? 1.0)
        let diferenciadolares = (Double(tasaEuro) ?? 1.0) - (Double(tasaBCV) ?? 1.0)
        diferenciaPorcentual =  (diferenciadolares / (Double(tasaBCV) ?? 1.0)) * 100
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
