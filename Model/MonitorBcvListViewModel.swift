//
//  MonitorBcvListViewModel.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/10/24.
//

import Foundation


class MonitorBcvListViewModel: ObservableObject {
    @Published var monitors: [ApiNetworkBcv.MonitorDetail] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let api = ApiNetworkBcv()

    func fetchMonitors() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await api.getDollarRatesBcv()
                DispatchQueue.main.async {
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

