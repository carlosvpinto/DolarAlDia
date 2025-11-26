//
//  AdStateViewModel.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 10/14/25.
//
// AdStateViewModel.swift

import Foundation
import Combine

class AdStateViewModel: ObservableObject {
    // @Published notificará a la UI cada vez que estos valores cambien.
    @Published var isAdFreeActive: Bool = false
    @Published var remainingTimeString: String = ""

    private var adFreeExpirationDate: Date?
    private let userDefaultsKey = "adFreeExpirationDate"
    private var timer: Timer?

    init() {
        checkAdFreeStatus()
    }

    // 1. Revisa el estado al iniciar la app
    func checkAdFreeStatus() {
        guard let expirationDate = UserDefaults.standard.object(forKey: userDefaultsKey) as? Date else {
            isAdFreeActive = false
            return
        }

        if Date() < expirationDate {
            // El período sin anuncios sigue activo
            self.adFreeExpirationDate = expirationDate
            self.isAdFreeActive = true
            startTimer()
        } else {
            // El período ya expiró
            self.isAdFreeActive = false
            UserDefaults.standard.removeObject(forKey: userDefaultsKey) // Limpiamos el valor viejo
        }
    }

    // 2. Otorga el período sin anuncios cuando el usuario ve un video
    func grantAdFreePeriod(hours: Int) {
        let expiration = Calendar.current.date(byAdding: .hour, value: hours, to: Date())!
        self.adFreeExpirationDate = expiration
        UserDefaults.standard.set(expiration, forKey: userDefaultsKey)
        
        // Actualiza la UI inmediatamente
        DispatchQueue.main.async {
            self.isAdFreeActive = true
            self.startTimer()
        }
    }

    // 3. Inicia el temporizador para la cuenta regresiva
    private func startTimer() {
        // Nos aseguramos de invalidar cualquier timer anterior
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let expiration = self.adFreeExpirationDate else { return }
            
            let remainingTime = expiration.timeIntervalSince(Date())
            
            if remainingTime > 0 {
                self.remainingTimeString = self.format(duration: remainingTime)
            } else {
                // El tiempo se acabó, reseteamos todo
                self.isAdFreeActive = false
                self.remainingTimeString = ""
                self.timer?.invalidate()
                UserDefaults.standard.removeObject(forKey: self.userDefaultsKey)
            }
        }
    }

    // 4. Formatea el tiempo para mostrarlo en la UI
    private func format(duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    // Es buena práctica limpiar el timer cuando el objeto se destruye
    deinit {
        timer?.invalidate()
    }
}
