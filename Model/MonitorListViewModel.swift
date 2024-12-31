//
//  MonitorListViewModel.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/9/24.
//
import Foundation

@MainActor // Asegura que todo se ejecute en el hilo principal
class MonitorListViewModel: ObservableObject {
    @Published var monitors: [ApiNetworkCripto.MonitorDetail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Instancia de ApiNetworkCripto
    private let apiNetworkCripto = ApiNetworkCripto()

    // Función para obtener datos de la API
    func fetchData() {
        isLoading = true
        errorMessage = nil

        Task { [weak self] in // Capturar self débilmente para evitar ciclos de retención
            guard let self = self else { return }
            
            do {
                // Llama al método getDollarRatesCripto
                let response = try await apiNetworkCripto.getDollarRatesCripto()
                
                // Actualiza la lista de monitores directamente en el hilo principal (gracias a @MainActor)
                self.monitors = [
                    response.monitors.amazonGiftCard,
                    response.monitors.bcv,
                    response.monitors.binance,
                    response.monitors.criptoDolar,
                    response.monitors.dolarToday,
                    response.monitors.enparalelovzla,
                    response.monitors.paypal,
                    response.monitors.skrill,
                    response.monitors.uphold
                ]
                self.isLoading = false
            } catch {
                // Manejo de errores también en el hilo principal
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
