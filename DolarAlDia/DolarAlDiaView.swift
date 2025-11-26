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
    @Environment(\.colorScheme) var colorScheme

   
    @State private var tasaUSDT: String = ""
    @State private var porcentajeUSDT: String = ""
    @State private var simboloUSDT: String = ""
    @State private var fechaActualizacionUSDT: String = "Cargando..."

   
    @State private var porcentajeEuro: String = ""
    @State private var porcentajeBcv: String = ""
    @State private var simboloBcv: String = ""
    @State private var simboloEuro: String = ""
    @State private var fechaActualizacionParalelo: String = "Cargando..."
    @State private var fechaActualizacionBCV: String = "Cargando..."
    @State private var tasaBCVFutura: String = ""
    @State private var tasaEuroFutura: String = ""
    @State private var porcentajeBcvFuturo: String = ""
    @State private var porcentajeEuroFuturo: String = ""
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
    // 👇 Estado para mostrar/ocultar la vista de estado de la recompensa.
    @State private var showingRewardStatus = false
    

    @EnvironmentObject var adState: AdState // Necesitamos acceso directo aquí
    
   
    
    // MARK: - Propiedades Computadas (Sin cambios)
    var placeholderMoneda: String {
        switch selectedButton {
        case Constants.DOLARBCV: return "Dólares"
        case Constants.DOLAREUROBCV: return "Euro"
        case Constants.DOLARUSDT: return "USDT"
        default: return "Dólares"
        }
    }
    
    var startIconMoneda: String {
        switch selectedButton {
        case Constants.DOLARBCV: return "icon-dollar"
        case Constants.DOLAREUROBCV: return "euro"
        case Constants.DOLARUSDT: return "usdt"
        default: return "icon-dollar"
        }
    }

    // MARK: - Body Principal
    var body: some View {
        // 1. EL CUERPO PRINCIPAL DEBE SER UN ZSTACK PARA PERMITIR LA SUPERPOSICIÓN
        ZStack {
            
            VStack(spacing: 5) { // <-- CAMBIO: Espaciado general reducido de 10 a 5
                mainContentView
                
            }
       
            .padding(.horizontal)
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
            
           // bottomControlsView
            
            if showToast { toastView }
            if isLoading { loadingView }
            if let message = statusMessage { statusMessageView(message) }
            
           
       }
       .onTapGesture {
           campoEnfocado = nil
       }
        // 👇Este modificador presentará la nueva vista cuando showingRewardStatus sea true.
       .sheet(isPresented: $showingRewardStatus) {
           RewardStatusView()
               .presentationDetents([.medium])
       }
        
   
           }

   
    

    // MARK: - Vistas Extraídas (Con Cambios)
    private var mainContentView: some View {
        // 1. Contenedor VStack principal que aloja tanto a GeometryReader como a bottomControlsView.
        VStack {
            GeometryReader { geometry in
                VStack(spacing: 4) {
                    logoView
                    priceButtons(geometry: geometry)
                    inputFieldsView
                    // Se elimina bottomControlsView de aquí
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
            }

            // 2. bottomControlsView se coloca aquí, fuera de GeometryReader pero dentro del VStack principal.
            bottomControlsView
        }
        .ignoresSafeArea(.keyboard)
    }
    private var logoView: some View {
            Image("logoredondo")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                // AÑADIDO: El logo ahora abre el estado de la recompensa si está activa
                .onTapGesture {
                    if adState.isAdFree {
                        self.showingRewardStatus = true
                    }
                }
        }

    private func priceButtons(geometry: GeometryProxy) -> some View {
        VStack(alignment: .center, spacing: 5) {
            let hStackSpacing: CGFloat = 10 // <-- CAMBIO: Espaciado horizontal también reducido
            // El padding horizontal del contenedor padre es 8*2=16
            let buttonWidth = (geometry.size.width - hStackSpacing - 16) / 2
            
            BotonInfoPrecio(
                mostrar: true,
                valorDolar: tasaUSDT,
                nombreDolar: Constants.DOLARUSDT,
                simboloFlecha: simboloUSDT,
                variacionPorcentaje: porcentajeUSDT,
                isSelected: selectedButton == Constants.DOLARUSDT,
                mostrarTasasFuturas: mostrarTasasFuturas
            ) {
                selectedButton = Constants.DOLARUSDT
                actualizarCalculos()
            }
            .frame(width: buttonWidth)
            .frame(minHeight: 50) // Puedes ajustar este valor si lo necesitas
            
            HStack(spacing: hStackSpacing) {
                BotonInfoPrecio(
                    mostrar: true,
                    valorDolar: tasaBCV,
                    nombreDolar: Constants.DOLARBCV,
                    simboloFlecha: simboloBcv,
                    variacionPorcentaje: porcentajeBcv,
                    isSelected: selectedButton == Constants.DOLARBCV,
                    mostrarTasasFuturas: mostrarTasasFuturas
                ) {
                    selectedButton = Constants.DOLARBCV
                    actualizarCalculos()
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 80) // Puedes ajustar este valor si lo necesitas

                BotonInfoPrecio(
                    mostrar: true,
                    valorDolar: tasaEuro,
                    nombreDolar: Constants.DOLAREUROBCV,
                    simboloFlecha: simboloEuro,
                    variacionPorcentaje: porcentajeEuro,
                    isSelected: selectedButton == Constants.DOLAREUROBCV,
                    mostrarTasasFuturas: mostrarTasasFuturas
                ) {
                    selectedButton = Constants.DOLAREUROBCV
                    actualizarCalculos()
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 80) // Puedes ajustar este valor si lo necesitas
            }
        }
    }

    private var inputFieldsView: some View {
        HStack {
            VStack(alignment: .leading, spacing: -10) { // El spacing negativo ya es muy compacto, se mantiene
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
        .padding(.vertical, 2)
    }
    
    // MARK: - Vistas Inferiores y Overlays (Sin cambios relevantes para la compactación superior)
    
    // En DolarAlDiaView.swift

    private var bottomControlsView: some View {
        VStack {
            // ***** CAMBIO CLAVE: Volvemos a añadir el Spacer *****
            // Esto es lo que empuja toda la sección hacia abajo.
            //Spacer()
            
            if hayDatosFuturos {
                HStack {
                    Spacer()
                    Toggle(isOn: $mostrarTasasFuturas) {
                        Text("Próxima Actualización")
                            .fontWeight(.bold)
                    }
                    .tint(.blue)
                    .fixedSize()
                    .padding(.vertical, 8) // Mantenemos el padding compacto
                    Spacer()
                }
                .padding(.horizontal)
                .onChange(of: mostrarTasasFuturas) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        actualizarVistasConTasas()
                    }
                }
            }

            HStack(alignment: .center, spacing: 5) {
                if isOffline {
                    Image(systemName: "wifi.exclamationmark").font(.title2).foregroundColor(.orange).transition(.scale.animation(.spring()))
                }
            }
            
            // Usamos un VStack con espaciado reducido para el diseño compacto
            VStack(spacing: 4) {
                dateTextView(
                    text: mostrarTasasFuturas
                    ? "Tasa Futura: \(fechaFuturaBCV.components(separatedBy: ",").first ?? fechaFuturaBCV)"
                    : "Act. BCV: \(fechaActualizacionBCV.components(separatedBy: ",").first ?? fechaActualizacionBCV)",
                    color: mostrarTasasFuturas ? .orange : (animateDateUpdate ? .green : .gray)
                )
                
                dateTextView(
                    text: "Act. USDT: \(fechaActualizacionUSDT)",
                    color: animateDateUpdate ? .green : .gray
                )
                
                Button(action: {
                    Task { isLoading = true; await llamarApiDolar(); isLoading = false }
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill").resizable().frame(width: 50, height: 50).foregroundColor(.blue)
                }
                .padding(.top, 15) // El padding ahora está solo en el botón
            }
            .padding(.bottom, 50) // Mantenemos el padding inferior para separar del borde
            
        }
        .ignoresSafeArea(.keyboard)
    }
    
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
    


    
    // - Lógica y Funciones
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
            self.tasaUSDT = String(format: "%.2f", cachedData.tasaUSDT)
            self.porcentajeBcv = cachedData.porcentajeBcv
            self.porcentajeUSDT = cachedData.porcentajeUSDT
            self.simboloBcv = cachedData.simboloBcv
            self.simboloUSDT = cachedData.simboloUSDT
            self.fechaActualizacionBCV = cachedData.fechaActualizacionBCV
            self.fechaActualizacionUSDT = cachedData.fechaActualizacionUSDT
            // Aquí podrías cargar también los datos cacheados de USDT si los guardas
        } else {
            print("No se encontraron datos en el caché.")
        }
    }
    
    // ************************* FUNCIÓN MODIFICADA *************************
    func convertirDolaresABolivares() {
        let outputFormatter = NumberFormatter()
        outputFormatter.numberStyle = .decimal
        outputFormatter.groupingSeparator = "."
        outputFormatter.decimalSeparator = ","
        outputFormatter.minimumFractionDigits = 2
        outputFormatter.maximumFractionDigits = 2
        
        let inputFormatter = NumberFormatter()
        inputFormatter.numberStyle = .decimal
        inputFormatter.locale = Locale.current

        if isDolaresFocused {
            guard !dolares.isEmpty else {
                self.bolivares = ""
                return
            }

            if let dolaresNumber = inputFormatter.number(from: dolares) {
                let dolaresValue = dolaresNumber.doubleValue
                
                var tasa: Double = 0
                switch selectedButton {
                case Constants.DOLARBCV:
                    tasa = Double(tasaBCV.replacingOccurrences(of: ",", with: ".")) ?? 0
                case Constants.DOLAREUROBCV:
                    tasa = Double(tasaEuro.replacingOccurrences(of: ",", with: ".")) ?? 0
                // --- AÑADIMOS EL CASO PARA USDT ---
                case Constants.DOLARUSDT:
                    tasa = Double(tasaUSDT.replacingOccurrences(of: ",", with: ".")) ?? 0
                default:
                    break
                }
                
                let bolivaresValue = dolaresValue * tasa
                self.bolivares = outputFormatter.string(from: NSNumber(value: bolivaresValue)) ?? ""
                
            } else {
                self.bolivares = ""
            }
        }
    }
    // ********************* FIN DE LA FUNCIÓN MODIFICADA *********************
  
    func convertirBolivaresADolares() {
        let outputFormatter = NumberFormatter()
        outputFormatter.numberStyle = .decimal
        outputFormatter.groupingSeparator = "."
        outputFormatter.decimalSeparator = ","
        outputFormatter.minimumFractionDigits = 2
        outputFormatter.maximumFractionDigits = 2
        
        let inputFormatter = NumberFormatter()
        inputFormatter.numberStyle = .decimal
        inputFormatter.locale = Locale.current

        if !isDolaresFocused {
            guard !bolivares.isEmpty else {
                self.dolares = ""
                return
            }

            if let bolivaresNumber = inputFormatter.number(from: bolivares) {
                let bolivaresValue = bolivaresNumber.doubleValue
                
                var tasa: Double = 0
                switch selectedButton {
                case Constants.DOLARBCV:
                    tasa = Double(tasaBCV.replacingOccurrences(of: ",", with: ".")) ?? 0
                case Constants.DOLAREUROBCV:
                    tasa = Double(tasaEuro.replacingOccurrences(of: ",", with: ".")) ?? 0
                // --- AÑADIMOS EL CASO PARA USDT ---
                case Constants.DOLARUSDT:
                    tasa = Double(tasaUSDT.replacingOccurrences(of: ",", with: ".")) ?? 0
                default:
                    break
                }
                
                if tasa > 0 {
                    let dolaresValue = bolivaresValue / tasa
                    self.dolares = outputFormatter.string(from: NSNumber(value: dolaresValue)) ?? ""
                } else {
                    self.dolares = ""
                }
                
            } else {
                self.dolares = ""
            }
        }
    }
    // ********************* FIN DE LA FUNCIÓN MODIFICADA *********************

    func normalizaNumero(_ valor: String) -> String {
       var limpio = valor.replacingOccurrences(of: ".", with: "")
       limpio = limpio.replacingOccurrences(of: ",", with: ".")
       limpio = limpio.replacingOccurrences(of: " ", with: "")
       return limpio
    }
    
    func limpiarCampos() { dolares = ""; bolivares = "" }
    

    // Centraliza la lógica de conversión para no repetir código.
    func actualizarCalculos() {
        if campoEnfocado == .dolares || campoEnfocado == nil {
            convertirDolaresABolivares()
        } else {
            convertirBolivaresADolares()
        }
    }
   
    
    func actualizarVistasConTasas() {
        if mostrarTasasFuturas {
            tasaBCV = tasaBCVFutura
            tasaEuro = tasaEuroFutura
            porcentajeBcv = porcentajeBcvFuturo
            porcentajeEuro = porcentajeEuroFuturo
            // Aquí podrías añadir la lógica para las tasas futuras de USDT
        } else {
            cargarDatosActualesGuardados()
        }
        actualizarCalculos()
    }
    
    func cargarDatosActualesGuardados() {
        if let cachedData = CacheManager.shared.load() {
            tasaBCV = String(format: "%.2f", cachedData.tasaBCV)
            tasaEuro = String(format: "%.2f", cachedData.tasaEuro)
            porcentajeBcv = cachedData.porcentajeBcv
            porcentajeEuro = cachedData.porcentajeUSDT
            // Aquí podrías cargar también los datos cacheados de USDT
        }
    }
        

    // ************************* FUNCIÓN DE API  *************************
    func llamarApiDolar() async {
        do {
            print("🚀 Iniciando llamada a la API de Dólar...")
            let apiService = ApiNetworkDolarAlDia()
            let dollarData = try await apiService.getDollarRates()
        
            
            let now = Date()
        
            // --- CAMBIO: Renombradas las propiedades para Euro ---
            var datosActuales = (
                tasaBCV: 0.0, tasaEuro: 0.0, tasaUSDT: 0.0,
                porcentajeBcv: "", porcentajeEuro: "", porcentajeUSDT: "",
                simboloBcv: "", simboloEuro: "", simboloUSDT: "",
                fechaBCV: "", fechaEuro: "", fechaUSDT: ""
            )
            
            // --- CAMBIO: Renombradas las propiedades para Euro ---
            var datosFuturos = (
                tasaBCV: "", tasaEuro: "",
                porcentajeBcv: "", porcentajeEuro: "",
                fechaBCV: "", fechaEuro: ""
            )
            
            var hayDataFuturaTemporal = false

            // --- Procesamos el Dólar (USD) ---
            if let usdMonitor = dollarData.monitors["usd"] {
                let lastUpdateDate = parseDate(from: usdMonitor.lastUpdate) ?? now
                if lastUpdateDate > now {
                    hayDataFuturaTemporal = true
                    datosFuturos.tasaBCV = String(format: "%.2f", usdMonitor.price)
                    datosFuturos.porcentajeBcv = String(format: "%.2f", usdMonitor.percent)
                    datosFuturos.fechaBCV = usdMonitor.lastUpdate
                    
                    datosActuales.tasaBCV = usdMonitor.priceOld
                    datosActuales.porcentajeBcv = String(format: "%.2f", usdMonitor.percentOld)
                    datosActuales.fechaBCV = usdMonitor.lastUpdateOld
                    
                    
                } else {
                    datosActuales.tasaBCV = usdMonitor.price
                    datosActuales.porcentajeBcv = String(format: "%.2f", usdMonitor.percent)
                    datosActuales.fechaBCV = usdMonitor.lastUpdate
                }
                datosActuales.simboloBcv = usdMonitor.symbol
            }

            // --- Procesamos el Euro (EUR) ---
            if let eurMonitor = dollarData.monitors["eur"] {
                 let lastUpdateDate = parseDate(from: eurMonitor.lastUpdate) ?? now
                if lastUpdateDate > now {
                    hayDataFuturaTemporal = true
                    // --- CAMBIO: Usando .porcentajeEuro ---
                    datosFuturos.tasaEuro = String(format: "%.2f", eurMonitor.price)
                    datosFuturos.porcentajeEuro = String(format: "%.2f", eurMonitor.percent)
                    datosFuturos.fechaEuro = eurMonitor.lastUpdate
                    
                    // --- CAMBIO: Usando .porcentajeEuro ---
                    datosActuales.tasaEuro = eurMonitor.priceOld
                    datosActuales.porcentajeEuro = String(format: "%.2f", eurMonitor.percentOld)
                    datosActuales.fechaEuro = eurMonitor.lastUpdateOld
                    
                    // --- CAMBIO: Usando .porcentajeEuro en el log ---
                    print("🔍 Procesando datos FUTUROS para EUR: Tasa=\(datosFuturos.tasaEuro), Porcentaje=\(datosFuturos.porcentajeEuro), Fecha=\(datosFuturos.fechaEuro)")
                    
                }  else {
                    // --- CAMBIO: Usando .porcentajeEuro ---
                    datosActuales.tasaEuro = eurMonitor.price
                    datosActuales.porcentajeEuro = String(format: "%.2f", eurMonitor.percent)
                    datosActuales.fechaEuro = eurMonitor.lastUpdate
                }
                // --- CAMBIO: Usando .simboloEuro ---
                datosActuales.simboloEuro = eurMonitor.symbol
            }
            
            // --- Procesamos USDT ---
            if let usdtMonitor = dollarData.monitors["usdt"] {
                datosActuales.tasaUSDT = usdtMonitor.price
                datosActuales.porcentajeUSDT = String(format: "%.2f", usdtMonitor.percent)
                datosActuales.fechaUSDT = usdtMonitor.lastUpdate
                datosActuales.simboloUSDT = usdtMonitor.symbol
            }
         

            // --- ACTUALIZACIÓN SEGURA Y CENTRALIZADA EN EL HILO PRINCIPAL ---
            await MainActor.run {
                // Actualiza los valores actuales de USD
                self.tasaBCV = String(format: "%.2f", datosActuales.tasaBCV)
                self.porcentajeBcv = datosActuales.porcentajeBcv
                self.simboloBcv = datosActuales.simboloBcv
                self.fechaActualizacionBCV = datosActuales.fechaBCV
                
                // ---Actualizando las variables de estado de Euro ---
                self.tasaEuro = String(format: "%.2f", datosActuales.tasaEuro)
                self.porcentajeEuro = datosActuales.porcentajeEuro
                self.simboloEuro = datosActuales.simboloEuro // Se actualiza la variable de estado 'simboloParalelo'
                
                // Actualiza los valores actuales de USDT
                self.tasaUSDT = String(format: "%.2f", datosActuales.tasaUSDT)
                self.porcentajeUSDT = datosActuales.porcentajeUSDT
                self.simboloUSDT = datosActuales.simboloUSDT
                self.fechaActualizacionUSDT = datosActuales.fechaUSDT
                
                // Actualiza los valores futuros si existen
                self.hayDatosFuturos = hayDataFuturaTemporal
                if hayDataFuturaTemporal {
                    self.tasaBCVFutura = datosFuturos.tasaBCV
                    self.porcentajeBcvFuturo = datosFuturos.porcentajeBcv
                    self.fechaFuturaBCV = datosFuturos.fechaBCV
                    self.tasaEuroFutura = datosFuturos.tasaEuro
                    self.porcentajeEuroFuturo = datosFuturos.porcentajeEuro // Se actualiza la variable de estado 'porcentajeParaleloFuturo'
                    self.fechaFuturaEuro = datosFuturos.fechaEuro
                }
                
                
                // --- INICIO DE LA LÓGICA DE GUARDADO ---
                          print("💾 Preparando datos para guardar en caché...")
                          let dataToCache = DollarDataCache(
                              tasaBCV: datosActuales.tasaBCV,
                              porcentajeBcv: datosActuales.porcentajeBcv,
                              simboloBcv: datosActuales.simboloBcv,
                              fechaActualizacionBCV: datosActuales.fechaBCV,
                              tasaEuro: datosActuales.tasaEuro,
                              porcentajeEuro: datosActuales.porcentajeEuro,
                              simboloEuro: datosActuales.simboloEuro,
                              fechaActualizacionEuro: datosActuales.fechaEuro,
                              tasaUSDT: datosActuales.tasaUSDT,
                              porcentajeUSDT: datosActuales.porcentajeUSDT,
                              simboloUSDT: datosActuales.simboloUSDT,
                              fechaActualizacionUSDT: datosActuales.fechaUSDT,
                              timestamp: Date()
                          )
                          CacheManager.shared.save(data: dataToCache)
                          // --- FIN DE LA LÓGICA DE GUARDADO ---
                // El resto de la lógica (caché, cálculos, animación)
                
                if self.isOffline {
                    // Usamos TU HapticManager para una vibración de éxito.
                    HapticManager.shared.play(.success)
                    showStatusMessage("Conexión exitosa") // Mensaje temporal
                }
                
                // Actualiza el estado a "online".
                self.isOffline = false
                actualizarCalculos()
                isOffline = false
                statusMessage = nil
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { animateDateUpdate = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut) { animateDateUpdate = false }
                }
            }
            
        } catch {
            print("❌ Error al llamar o procesar la API: \(error)")
            await MainActor.run {
                
                // Solo activamos la vibración y el mensaje si no estábamos ya en modo offline.
                if !self.isOffline {
                    // Usamos TU HapticManager para una vibración de error.
                    HapticManager.shared.play(.error)
                    showStatusMessage("Falla de conexión") // Mensaje temporal
                }
                isOffline = true
             
                
               
            }
        
            
        }
    }
    
    func showStatusMessage(_ message: String) {
        Task { @MainActor in
            self.statusMessage = message
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            self.statusMessage = nil
        }
    }

    func calcularDiferencia() {
        mensaje = "Diferencia Cambiaria"
        let tasaEuroDouble = Double(tasaEuro.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        let tasaBCVDouble = Double(tasaBCV.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        let dolaresDouble = Double(normalizaNumero(dolares)) ?? 1.0
        
        if tasaBCVDouble > 0 {
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
    private func dateTextView(text: String, color: Color) -> some View {
        Text(text)
            .font(.body) // Mismo tamaño de fuente
            .fontWeight(.bold) // Mismo grosor
            .foregroundColor(color) // El color se pasa como parámetro
            // Los efectos de animación se aplican a ambos
            .scaleEffect(animateDateUpdate && !mostrarTasasFuturas ? 1.1 : 1.0)
            .shadow(
                color: animateDateUpdate && !mostrarTasasFuturas ? .green.opacity(0.5) : .clear,
                radius: 5, x: 0, y: 0
            )
            .padding(.bottom, 2) // Mismo espaciado
    }

}
