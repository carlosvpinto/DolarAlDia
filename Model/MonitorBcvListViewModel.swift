//
//  MonitorBcvListViewModel.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/10/24.
//
import Foundation

@MainActor // Asegura que todo se ejecute en el hilo principal
class MonitorBcvListViewModel: ObservableObject {
    @Published var monitors: [ApiNetworkBcv.MonitorDetail] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let api = ApiNetworkBcv()

    func fetchMonitors() {
        isLoading = true
        errorMessage = nil

        Task { [weak self] in // Captura débil para evitar ciclos de retención
            guard let self = self else { return }

            do {
                let response = try await api.getDollarRatesBcv()
                
                // Actualiza las propiedades en el hilo principal
                self.monitors = [
                    response.monitors.activo,
                    response.monitors.bancamiga,
                    response.monitors.bancaribe,
                    response.monitors.banesco,
                    response.monitors.bangente,
                    response.monitors.banplus,
                    response.monitors.bdv,
                    response.monitors.bnc,
                    response.monitors.bvc,
                    response.monitors.cny,
                    response.monitors.eur,
                    response.monitors.exterior,
                    response.monitors.mercantilBanco,
                    response.monitors.miBanco,
                    response.monitors.otrasInstituciones,
                    response.monitors.plaza,
                    response.monitors.provincial,
                    response.monitors.rub,
                    response.monitors.sofitasa,
                    response.monitors.tryCurrency,
                    response.monitors.usd
                ]
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
