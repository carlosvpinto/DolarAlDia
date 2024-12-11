//
//  MonitorListViewModel.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/9/24.
//

import Foundation

class MonitorListViewModel: ObservableObject {
    @Published var monitors: [ApiNetworkCripto.MonitorDetail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Crea una instancia de ApiNetworkCripto
    private let apiNetworkCripto = ApiNetworkCripto()

    // Función para obtener datos de la API
    func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Llama al método getDollarRatesCripto a través de la instancia
                let response = try await apiNetworkCripto.getDollarRatesCripto()
                DispatchQueue.main.async {
                    // Extraer todos los monitores en una lista
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
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
