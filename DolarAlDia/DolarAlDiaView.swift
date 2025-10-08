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
    @State private var tasaBCVFutura: String = ""
    @State private var tasaEuroFutura: String = ""
    @State private var porcentajeBcvFuturo: String = ""
    @State private var porcentajeParaleloFuturo: String = ""
    @State private var fechaFuturaBCV: String = ""
    @State private var fechaFuturaEuro: String = ""
    @State private var hayDatosFuturos: Bool = false
    @State private var mostrarTasasFuturas: Bool = false
    @State private var isLoading: Bool = false
    @State private var showToast: Bool = false
    @FocusState private var campoEnfocado: CampoDeEnfoque?
    @State private var isOffline: Bool = false
    @State private var statusMessage: String? = nil
    @State private var animateDateUpdate: Bool = false
    @State private var showSheet = false
    @State private var mensaje = ""
    @State private var diferenciaBs = 0.0
    @State private var diferenciaDolares = 0.0
    @State private var diferenciaPorcentual = 0.0
    
    @Environment(\.colorScheme) var colorScheme
    

    
    var placeholderMoneda: String {
        selectedButton == Constants.DOLARBCV ? "Dólares" : "Euro"
    }
    var startIconMoneda: String {
        selectedButton == Constants.DOLARBCV ? "icon-dollar" : "euro"
    }

    // --- BODY PRINCIPAL (SIMPLIFICADO) ---
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Llamamos a la vista extraída
                mainContentView
            }
            .padding()
            .onAppear {
                
                
                Task {
                    await cargarDatosCacheados()
                    isLoading = true
                    await llamarApiDolar()
                    isLoading = false
                }
            }
            .sheet(isPresented: $showSheet) {
                ResultSheet(
                    mensaje: mensaje,
                    diferenciaBs: diferenciaBs,
                    diferenciaDolares: diferenciaDolares,
                    diferenciaPorcentual: diferenciaPorcentual
                )
                .presentationDetents([.medium, .large])
            }
            
            // Llamamos a los controles inferiores
            bottomControlsView
            
            // Overlays (sin cambios)
            if showToast { toastView }
            if isLoading { loadingView }
            if let message = statusMessage { statusMessageView(message) }
       }
       .onTapGesture {
           campoEnfocado = nil
       }
    }

    
    // 1. Vista para el contenido principal
    private var mainContentView: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                Image("logoredondo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                
                HStack(spacing: 20) {
                    BotonInfoPrecio(mostrar:true, valorDolar: tasaBCV, nombreDolar: Constants.DOLARBCV, simboloFlecha: simboloBcv, variacionPorcentaje: porcentajeBcv, isSelected: selectedButton == Constants.DOLARBCV, mostrarTasasFuturas: mostrarTasasFuturas) {
                        selectedButton = Constants.DOLARBCV
                        convertirDolaresABolivares()
                        convertirBolivaresADolares()
                    }
                    .frame(maxWidth: .infinity)

                    BotonInfoPrecio(mostrar:true, valorDolar: tasaEuro, nombreDolar: Constants.DOLAREUROBCV, simboloFlecha: simboloParalelo, variacionPorcentaje: porcentajeParalelo, isSelected: selectedButton == Constants.DOLAREUROBCV, mostrarTasasFuturas: mostrarTasasFuturas) {
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
                                .onChange(of: dolares) { convertirDolaresABolivares() }
                            Button(action: { UIPasteboard.general.string = dolares; showToastMessage() }) {
                                Image(systemName: "doc.on.doc").resizable().frame(width: 24, height: 24).foregroundColor(.blue)
                            }
                        }
                        HStack {
                            TextFieldPersonal(placeholder: "Bolivares", startIcon: "icon-bs", text: $bolivares, onClearAll: limpiarCampos)
                                .focused($campoEnfocado, equals: .bolivares)
                                .onChange(of: bolivares) { convertirBolivaresADolares() }
                            Button(action: { UIPasteboard.general.string = bolivares; showToastMessage() }) {
                                Image(systemName: "doc.on.doc").resizable().frame(width: 24, height: 24).foregroundColor(.blue)
                            }
                        }
                    }
                    Button(action: {
                        calcularDiferencia()
                        showSheet = true
                    }){
                        Image(systemName: "mail.and.text.magnifyingglass").resizable().frame(width: 24, height: 24).foregroundColor(.blue)
                    }
                }
                .padding(10)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
        }
    }
    
    // 2. Vista para los controles inferiores
    private var bottomControlsView: some View {
        VStack {
            Spacer()
            
            // Switch
            if hayDatosFuturos {
                HStack {
                    Spacer()
                    Toggle(isOn: $mostrarTasasFuturas) {
                        Text("Próxima Actualización")
                            .fontWeight(.bold)
                    }
                    .tint(.blue)
                    .fixedSize()
                    .padding(.vertical)
                    Spacer()
                }
                .padding(.horizontal)
                .onChange(of: mostrarTasasFuturas) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        actualizarVistasConTasas()
                    }
                }
            }

            // Indicador offline
            HStack(alignment: .center, spacing: 15) {
                if isOffline {
                    Image(systemName: "wifi.exclamationmark").font(.title2).foregroundColor(.orange).transition(.scale.animation(.spring()))
                }
            }
                
        
            // Fecha y botón de refrescar
            VStack {
                Text(mostrarTasasFuturas ? "Tasa Futura para: \(fechaFuturaBCV.components(separatedBy: ",").first ?? fechaFuturaBCV)" : "Act. BCV: \(fechaActualizacionBCV.components(separatedBy: ",").first ?? fechaActualizacionBCV)")
                    .font(.body)
                    .fontWeight(.bold)
                    // Si se muestran las tasas futuras, el color es naranja.
                    // Si no, mantiene el efecto de 'glow' verde cuando se actualiza.
                    .foregroundColor(mostrarTasasFuturas ? .orange : (animateDateUpdate ? .green : .gray))
                    
                    // Efecto de 'glow' solo para la actualización normal
                    .scaleEffect(animateDateUpdate && !mostrarTasasFuturas ? 1.1 : 1.0)
                    .shadow(
                        color: animateDateUpdate && !mostrarTasasFuturas ? .green.opacity(0.5) : .clear,
                        radius: 5, x: 0, y: 0
                    )
                    .padding(.bottom, 2)
                
                Button(action: {
                    Task { isLoading = true; await llamarApiDolar(); isLoading = false }
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill").resizable().frame(width: 50, height: 50).foregroundColor(.blue)
                }
            }
            .padding(.bottom, 30)
        }
        .ignoresSafeArea(.keyboard)
    }
    
    // --- VISTAS DE OVERLAY
    var toastView: some View {
           ZStack {
               Color.clear
               VStack {
                   Text("Valor copiado al portapapeles").font(.headline).padding().background(Color.black.opacity(0.6)).foregroundColor(.white).cornerRadius(10)
               }
           }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.clear).transition(.opacity)
       }
       
       var loadingView: some View {
           ZStack {
               Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
               ProgressView("Actualizando...").progressViewStyle(CircularProgressViewStyle()).padding().background(colorScheme == .dark ? Color.black : Color.white).foregroundColor(colorScheme == .dark ? Color.white : Color.black).cornerRadius(10).shadow(radius: 10)
           }
       }
    func statusMessageView(_ message: String) -> some View {
           VStack {
               Spacer()
               Text(message).font(.headline).foregroundColor(.white).padding().background(.black.opacity(0.6)).clipShape(Capsule()).transition(.move(edge: .bottom).combined(with: .opacity))
           }.padding(.bottom, 140)
       }
    
    
    // --- LÓGICA Y FUNCIONES
    private func parseDate(from dateString: String) -> Date? {
          let formatter = DateFormatter()
          formatter.dateFormat = "dd/MM/yyyy, hh:mm a"
          formatter.locale = Locale(identifier: "en_US_POSIX")
          return formatter.date(from: dateString)
      }
    private var isDolaresFocused: Bool { campoEnfocado == .dolares }
    func showToastMessage() {
            withAnimation { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { showToast = false }
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
                  
               } else {
                   print("No se encontraron datos en el caché.")
               }
           }
    func convertirDolaresABolivares() {
        // Formateador para MOSTRAR el resultado en bolívares
        let outputFormatter = NumberFormatter()
        outputFormatter.numberStyle = .decimal
        outputFormatter.groupingSeparator = "."
        outputFormatter.decimalSeparator = ","
        outputFormatter.minimumFractionDigits = 2
        outputFormatter.maximumFractionDigits = 2
        
        // Formateador para INTERPRETAR la entrada del usuario
        let inputFormatter = NumberFormatter()
        inputFormatter.numberStyle = .decimal
        // Le decimos que intente adivinar el separador local del usuario
        inputFormatter.locale = Locale.current

        if isDolaresFocused {
            // Ya no usamos normalizaNumero.
            guard !dolares.isEmpty else {
                self.bolivares = ""
                return
            }

            // Dejamos que el NumberFormatter interprete el texto del usuario
            if let dolaresNumber = inputFormatter.number(from: dolares) {
                let dolaresValue = dolaresNumber.doubleValue
                
                var tasa: Double = 0
                switch selectedButton {
                case Constants.DOLARBCV:
                    tasa = Double(tasaBCV.replacingOccurrences(of: ",", with: ".")) ?? 0
                case Constants.DOLAREUROBCV:
                    tasa = Double(tasaEuro.replacingOccurrences(of: ",", with: ".")) ?? 0
                default:
                    break
                }
                
                let bolivaresValue = dolaresValue * tasa
                
                // Usamos el formateador de salida para mostrar el resultado
                self.bolivares = outputFormatter.string(from: NSNumber(value: bolivaresValue)) ?? ""
                
            } else {
                // Si el formateador no puede interpretar el número, limpiamos el campo de bolívares.
                // Esto puede pasar si el usuario escribe "abc"
                self.bolivares = ""
            }
        }
    }

  

    func convertirBolivaresADolares() {
        // Formateador para MOSTRAR el resultado en el formato deseado (ej: 1.234,56)
        let outputFormatter = NumberFormatter()
        outputFormatter.numberStyle = .decimal
        outputFormatter.groupingSeparator = "."
        outputFormatter.decimalSeparator = ","
        outputFormatter.minimumFractionDigits = 2
        outputFormatter.maximumFractionDigits = 2
        
        // Formateador para INTERPRETAR la entrada de texto del usuario
        let inputFormatter = NumberFormatter()
        inputFormatter.numberStyle = .decimal
        // Permite que el formateador entienda la configuración regional del usuario (punto o coma decimal)
        inputFormatter.locale = Locale.current

        if !isDolaresFocused {
            // Ya no usamos normalizaNumero.
            guard !bolivares.isEmpty else {
                self.dolares = ""
                return
            }

            // Dejamos que el NumberFormatter interprete el texto del usuario
            if let bolivaresNumber = inputFormatter.number(from: bolivares) {
                let bolivaresValue = bolivaresNumber.doubleValue
                
                var tasa: Double = 0
                switch selectedButton {
                case Constants.DOLARBCV:
                    tasa = Double(tasaBCV.replacingOccurrences(of: ",", with: ".")) ?? 0
                case Constants.DOLAREUROBCV:
                    tasa = Double(tasaEuro.replacingOccurrences(of: ",", with: ".")) ?? 0
                default:
                    break
                }
                
                // Verificamos que la tasa no sea cero para evitar divisiones por infinito
                if tasa > 0 {
                    let dolaresValue = bolivaresValue / tasa
                    
                    // Usamos el formateador de salida para mostrar el resultado
                    self.dolares = outputFormatter.string(from: NSNumber(value: dolaresValue)) ?? ""
                } else {
                    self.dolares = ""
                }
                
            } else {
                // Si el formateador no puede interpretar el número (ej: "abc"), limpiamos el campo de dólares.
                self.dolares = ""
            }
        }
    }

           func normalizaNumero(_ valor: String) -> String {
               var limpio = valor.replacingOccurrences(of: ".", with: "")
               limpio = limpio.replacingOccurrences(of: ",", with: ".")
               limpio = limpio.replacingOccurrences(of: " ", with: "")
               return limpio
           }
    func limpiarCampos() { dolares = ""; bolivares = "" }
    
    func actualizarVistasConTasas() {
        if mostrarTasasFuturas {
            // Usar datos futuros
            tasaBCV = tasaBCVFutura
            tasaEuro = tasaEuroFutura
            porcentajeBcv = porcentajeBcvFuturo
            porcentajeParalelo = porcentajeParaleloFuturo
        } else {

            cargarDatosActualesGuardados()
        }
        
        if campoEnfocado == .dolares || campoEnfocado == nil {
            // Si el usuario estaba escribiendo en dólares (o no estaba escribiendo en ninguno),
            // actualizamos los bolívares.
            convertirDolaresABolivares()
        } else {
            // Si el usuario estaba escribiendo en bolívares,
            // actualizamos los dólares.
            convertirBolivaresADolares()
        }
    }
    

    // Esta función carga los últimos datos 'actuales' que guardamos en el caché.
    func cargarDatosActualesGuardados() {
        
        // Es lo que se usa cuando el Switch se desactiva.
        if let cachedData = CacheManager.shared.load() {
            tasaBCV = String(format: "%.2f", cachedData.tasaBCV)
            tasaEuro = String(format: "%.2f", cachedData.tasaEuro)
            porcentajeBcv = cachedData.porcentajeBcv
            porcentajeParalelo = cachedData.porcentajeParalelo
            
        }
    }
        
        //llamada al api
    func llamarApiDolar() async {
        do {
            print("🚀 Iniciando llamada a la API de Dólar...")
            let apiService = ApiNetworkDolarAlDia()
            let dollarData = try await apiService.getDollarRates()
            let now = Date()
            
            var datosActuales = (
                tasaBCV: 0.0, tasaEuro: 0.0, porcentajeBcv: "", porcentajeParalelo: "",
                simboloBcv: "", simboloParalelo: "", fechaBCV: "", fechaEuro: ""
            )
            
            var datosFuturos = (
                tasaBCV: "", tasaEuro: "", porcentajeBcv: "", porcentajeParalelo: "",
                fechaBCV: "", fechaEuro: ""
            )
            
            var hayDataFuturaTemporal = false

            // Procesamos el Dólar (USD)
            if let usdMonitor = dollarData.monitors["usd"] {
                let lastUpdateDate = parseDate(from: usdMonitor.lastUpdate) ?? now
                if lastUpdateDate > now {
                    hayDataFuturaTemporal = true
                    datosFuturos.tasaBCV = String(format: "%.2f", usdMonitor.price)
                    datosFuturos.porcentajeBcv = String(format: "%.2f", usdMonitor.percent)
                    datosFuturos.fechaBCV = usdMonitor.lastUpdate
                    
                    datosActuales.tasaBCV = usdMonitor.priceOld
                    datosActuales.porcentajeBcv = String(format: "%.2f", usdMonitor.percentOld ?? 0.0)
                    datosActuales.fechaBCV = usdMonitor.lastUpdateOld ?? "N/A"
                } else {
                    datosActuales.tasaBCV = usdMonitor.price
                    datosActuales.porcentajeBcv = String(format: "%.2f", usdMonitor.percent)
                    datosActuales.fechaBCV = usdMonitor.lastUpdate
                }
                datosActuales.simboloBcv = usdMonitor.symbol
            }

            // Procesamos el Euro (EUR)
            if let eurMonitor = dollarData.monitors["eur"] {
                let lastUpdateDate = parseDate(from: eurMonitor.lastUpdate) ?? now
                if lastUpdateDate > now {
                    hayDataFuturaTemporal = true
                    datosFuturos.tasaEuro = String(format: "%.2f", eurMonitor.price)
                    datosFuturos.porcentajeParalelo = String(format: "%.2f", eurMonitor.percent)
                    datosFuturos.fechaEuro = eurMonitor.lastUpdate

                    datosActuales.tasaEuro = eurMonitor.priceOld
                    datosActuales.porcentajeParalelo = String(format: "%.2f", eurMonitor.percentOld ?? 0.0)
                    datosActuales.fechaEuro = eurMonitor.lastUpdateOld ?? "N/A"
                } else {
                    datosActuales.tasaEuro = eurMonitor.price
                    datosActuales.porcentajeParalelo = String(format: "%.2f", eurMonitor.percent)
                    datosActuales.fechaEuro = eurMonitor.lastUpdate
                }
                datosActuales.simboloParalelo = eurMonitor.symbol
            }
            
        
            
            // Guardamos el caché con los datos ACTUALES (sin importar la prueba)
            let dataToCache = DollarDataCache(
                tasaBCV: datosActuales.tasaBCV,
                tasaEuro: datosActuales.tasaEuro,
                porcentajeBcv: datosActuales.porcentajeBcv,
                porcentajeParalelo: datosActuales.porcentajeParalelo,
                simboloBcv: datosActuales.simboloBcv,
                simboloParalelo: datosActuales.simboloParalelo,
                fechaActualizacionBCV: datosActuales.fechaBCV,
                fechaActualizacionParalelo: datosActuales.fechaEuro,
                timestamp: Date()
            )
            CacheManager.shared.save(data: dataToCache)
          

            // Actualizamos las variables de estado para la UI
            self.hayDatosFuturos = hayDataFuturaTemporal
            
            self.tasaBCVFutura = datosFuturos.tasaBCV
            self.tasaEuroFutura = datosFuturos.tasaEuro
            self.porcentajeBcvFuturo = datosFuturos.porcentajeBcv
            self.porcentajeParaleloFuturo = datosFuturos.porcentajeParalelo
            self.fechaFuturaBCV = datosFuturos.fechaBCV
            
            self.tasaBCV = String(format: "%.2f", datosActuales.tasaBCV)
            self.tasaEuro = String(format: "%.2f", datosActuales.tasaEuro)
            self.porcentajeBcv = datosActuales.porcentajeBcv
            self.porcentajeParalelo = datosActuales.porcentajeParalelo
            self.simboloBcv = datosActuales.simboloBcv
            self.simboloParalelo = datosActuales.simboloParalelo
            self.fechaActualizacionBCV = datosActuales.fechaBCV
            self.fechaActualizacionParalelo = datosActuales.fechaEuro
            
            actualizarVistasConTasas()
            calcularDiferencia()
            
            if isOffline { isOffline = false; showStatusMessage("¡Conexión restablecida!") }
            
            await MainActor.run {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { animateDateUpdate = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut) { animateDateUpdate = false }
                }
            }
            
        } catch {
            isOffline = true
            showStatusMessage("No se pudo actualizar. Verifique su conexión.")
            HapticManager.shared.play(.error)
        }
    }
    
    
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
        // 1. Preparamos el mensaje para el sheet de resultados.
        mensaje = "Diferencia Cambiaria"
        
        // 2. Convertimos las tasas de texto a números Double.
        let tasaEuroDouble = Double(tasaEuro.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        let tasaBCVDouble = Double(tasaBCV.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        // 3. Obtenemos el monto del TextField. Si está vacío, usamos '1.0' como valor por defecto.
        let dolaresDouble = Double(normalizaNumero(dolares)) ?? 1.0
        
        // 4. Verificamos que la tasa del BCV sea válida para evitar división por cero.
        if tasaBCVDouble > 0 {
            // Ahora los cálculos siempre se harán (para 1 dólar si el campo está vacío).
            diferenciaBs = (tasaEuroDouble * dolaresDouble) - (tasaBCVDouble * dolaresDouble)
            diferenciaDolares = diferenciaBs / tasaBCVDouble
            let diferenciaDeTasas = tasaEuroDouble - tasaBCVDouble
            diferenciaPorcentual = (diferenciaDeTasas / tasaBCVDouble) * 100
        } else {
            // Si la tasa del BCV es 0, no se puede calcular nada.
            diferenciaBs = 0
            diferenciaDolares = 0
            diferenciaPorcentual = 0
        }
    }
}

