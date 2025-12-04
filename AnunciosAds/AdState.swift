//
//  AdState.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 11/8/25.
import Foundation
import Combine

class AdState: ObservableObject {
    
    @Published var isAdFree: Bool = false
    @Published var timeRemainingFormatted: String = "00:00:00"

    private var timeRemaining: TimeInterval = 0
    private var timer: Timer?
    
    // Fechas límite
    private var rewardEndDate: Date?       // Fin de las 4 horas gratis
    private var subscriptionEndDate: Date? // Fin de la suscripción paga
    
    private let rewardDuration: TimeInterval = 4 * 60 * 60
    private let userDefaultsKey = "rewardEndDate"
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        checkLocalRewardStatus()
    }

    // MARK: - Conexión con StoreKit
    @MainActor
    func configure(with storeManager: StoreKitManager) {
        // Escuchamos DOS cosas: si es premium y la fecha de vencimiento
        storeManager.$subscriptionExpirationDate
            .combineLatest(storeManager.$isPremiumUser)
            .receive(on: RunLoop.main)
            .sink { [weak self] (date, isPremium) in
                guard let self = self else { return }
                
                if isPremium, let date = date {
                    // CASO 1: Tiene suscripción -> Usamos la fecha de Apple
                    self.subscriptionEndDate = date
                    self.updateAdFreeStatus()
                } else {
                    // CASO 2: No tiene suscripción -> Limpiamos fecha y revisamos recompensas
                    self.subscriptionEndDate = nil
                    self.updateAdFreeStatus()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Lógica Principal
    func grantReward() {
        // Si ya tiene suscripción paga, no hacemos nada
        if subscriptionEndDate != nil { return }
        
        let endDate = Date().addingTimeInterval(rewardDuration)
        UserDefaults.standard.set(endDate, forKey: userDefaultsKey)
        checkLocalRewardStatus()
    }

    func updateAdFreeStatus() {
        let now = Date()
        
        // PRIORIDAD 1: Suscripción Paga
        if let subDate = subscriptionEndDate {
            if subDate > now {
                self.isAdFree = true
                self.timeRemaining = subDate.timeIntervalSince(now)
                startTimer() // Iniciamos el reloj con la fecha de suscripción
                return
            }
        }
        
        // PRIORIDAD 2: Recompensa Local
        checkLocalRewardStatus()
    }
    
    private func checkLocalRewardStatus() {
        // Si hay suscripción activa, salimos para no sobrescribir
        if subscriptionEndDate != nil && subscriptionEndDate! > Date() { return }

        guard let endDate = UserDefaults.standard.object(forKey: userDefaultsKey) as? Date else {
            setAdFree(false)
            return
        }
        
        if Date() < endDate {
            self.timeRemaining = endDate.timeIntervalSince(Date())
            setAdFree(true)
        } else {
            setAdFree(false)
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        }
    }

    private func setAdFree(_ status: Bool) {
        DispatchQueue.main.async {
            self.isAdFree = status
            if status {
                self.startTimer()
            } else {
                self.stopTimer()
                self.timeRemainingFormatted = "00:00:00"
            }
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                self.updateFormattedTime()
            } else {
                // Se acabó el tiempo (ya sea suscripción o recompensa)
                self.updateAdFreeStatus() // Re-verificar estado
            }
        }
        // Actualizar inmediato para no esperar 1 segundo
        updateFormattedTime()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateFormattedTime() {
        // Cálculo inteligente: Si son días, muestra días. Si son horas, muestra horas.
        let totalSeconds = Int(timeRemaining)
        
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if days > 0 {
            // Formato largo: "29d 12h 30m"
            self.timeRemainingFormatted = String(format: "%dd %02ih %02im", days, hours, minutes)
        } else {
            // Formato corto (estilo cronómetro): "03:59:59"
            self.timeRemainingFormatted = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        }
    }

    
    // MARK: - Debug
    #if DEBUG
    func resetRewardForDebug() {
        print("DEBUG: Reseteando recompensa.")
        stopTimer()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        checkLocalRewardStatus()
    }
    #endif
}
