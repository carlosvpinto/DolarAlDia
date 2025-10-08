//
//  PlatformRatesView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 8/13/25.
//
import SwiftUI

struct PlatformRatesView: View {
    
    // Estados para los datos de la API
    @State private var binanceRate: ApiNetwork.MonitorDetail?
    @State private var bybitRate: ApiNetwork.MonitorDetail?
    @State private var yadioRate: ApiNetwork.MonitorDetail?
    @State private var isOffline: Bool = false // <-- NUEVO: Estado para offline
   
    
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var animateDateUpdate: Bool = false
    
    private let apiService = ApiNetwork()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Tasas de Plataformas")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                VStack(spacing: 15) {
                    if let binance = binanceRate {
                        PlatformRateRow(platform: binance, imageName: "binance_svg", isAnimatingGlow: self.animateDateUpdate)
                    }
                    
                    if let bybit = bybitRate {
                        PlatformRateRow(platform: bybit, imageName: "bybit-logo", isAnimatingGlow: self.animateDateUpdate)
                    }
                    
                    if let yadio = yadioRate {
                        PlatformRateRow(platform: yadio, imageName: "yadio_svg", isAnimatingGlow: self.animateDateUpdate)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                .padding(.horizontal)
                
                Spacer()
                VStack {
                    // Indicador de offline
                    if isOffline {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.title2).foregroundColor(.orange)
                            .transition(.scale.animation(.spring()))
                    }
                    
                    Button(action: { Task { await fetchRates() } }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .resizable().frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            .onAppear {
                Task {
                    // Primero cargamos desde el caché
                    await loadCachedPlatformData()
                    // Luego intentamos actualizar desde la API
                    await fetchRates()
                }
            }
            
            if isLoading { LoadingView() }
            if let message = errorMessage {
                          VStack {
                              Spacer()
                              Text(message)
                                  .font(.headline)
                                  .foregroundColor(.white)
                                  .padding()
                                  .background(.red.opacity(0.8))
                                  .clipShape(Capsule())
                                  .transition(.move(edge: .bottom).combined(with: .opacity))
                          }
                          .padding(.bottom, 60)
                      }
        }
    }
    
    // --- NUEVA FUNCIÓN PARA CARGAR DESDE EL CACHÉ ---
    private func loadCachedPlatformData() async {
        if let cachedData = CacheManager.shared.loadPlatforms() {
            self.binanceRate = cachedData.binanceRate
            self.bybitRate = cachedData.bybitRate
            self.yadioRate = cachedData.yadioRate
          
        } else {
            print("ℹ️ No se encontraron datos de plataformas en el caché.")
        }
    }
    
    private func fetchRates() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getPlatformRates()
            
            self.binanceRate = response.platforms["binance"]
            self.bybitRate = response.platforms["bybit"]
            self.yadioRate = response.platforms["yadio"]
            
            // Si la llamada fue exitosa, nos aseguramos de que el modo offline esté apagado
            if isOffline { isOffline = false; showErrorMessage("¡Conexión restablecida!") }
            
            // Guardamos los nuevos datos en el caché
            let dataToCache = PlatformDataCache(
                binanceRate: self.binanceRate,
                bybitRate: self.bybitRate,
                yadioRate: self.yadioRate,
                timestamp: Date()
            )
            CacheManager.shared.savePlatforms(data: dataToCache)
            
            isLoading = false
            
            // Lógica de animación
            await MainActor.run {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { animateDateUpdate = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut) { animateDateUpdate = false }
                }
            }
        } catch {
            isLoading = false
            // --- NUEVA LÓGICA DE ERROR ---
            isOffline = true // Activamos el modo offline
            showErrorMessage("No se pudo actualizar. Verifique su conexión.")
            HapticManager.shared.play(.error) // Activamos la vibración
            print("❌ Error al obtener tasas de plataformas. Se mantendrán los datos cacheados.")
        }
    }
    private func showErrorMessage(_ message: String) {
        self.errorMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.errorMessage = nil
            }
        }
    }
}

// Vista auxiliar para cada fila de plataforma

struct PlatformRateRow: View {
    let platform: ApiNetwork.MonitorDetail
    let imageName: String
    
    //Propiedad para recibir el estado de la animación ---
    let isAnimatingGlow: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(imageName)
            
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .clipShape(Circle())

            Text(platform.title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "Bs %.2f", platform.price))
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Image(systemName: platform.symbol == "▲" ? "arrow.up" : "arrow.down")
                    Text(String(format: "%.2f%%", platform.percent))
                }
                .font(.caption)
                .foregroundColor(platform.color == "green" ? .green : .red)
                
                Text(platform.lastUpdate)
                    .font(.caption2)
                    // --- APLICAMOS NUESTRO MODIFICADOR REUTILIZABLE ---
                    .glowOnUpdate(isAnimating: isAnimatingGlow)
            }
        }
        .padding(.vertical, 8)
    }
}
// Vista previa para el lienzo de Xcode
struct PlatformRatesView_Previews: PreviewProvider {
    static var previews: some View {
        PlatformRatesView()
    }
}
