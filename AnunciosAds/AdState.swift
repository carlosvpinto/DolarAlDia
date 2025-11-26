//
//  AdState.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 11/8/25.
//
import Foundation
import Combine

class AdState: ObservableObject {
    // MARK: - Published Properties for SwiftUI
    
    /// `true` si el usuario está en el período sin anuncios. La UI reacciona a esto.
    @Published var isAdFree: Bool = false
    
    /// El tiempo restante ya formateado como un String "HH:MM:SS" para que las vistas lo muestren fácilmente.
    @Published var timeRemainingFormatted: String = "00:00:00"

    // MARK: - Private Properties
    
    /// El tiempo exacto que queda en segundos.
    private var timeRemaining: TimeInterval = 0
    
    /// La fecha y hora exactas en que termina la recompensa.
    private var rewardEndDate: Date?
    
    /// El temporizador que se ejecuta cada segundo para actualizar el tiempo restante.
    private var timer: Timer?
    
    /// La duración de la recompensa (4 horas en segundos).
    private let rewardDuration: TimeInterval = 4 * 60 * 60
    
    /// La clave para guardar la fecha de finalización en la memoria del dispositivo.
    private let userDefaultsKey = "rewardEndDate"

    init() {
        // Al iniciar la app, siempre comprueba si había una recompensa activa.
        updateAdFreeStatus()
    }

    // MARK: - Public Methods
    
    /// Otorga la recompensa al usuario.
    func grantReward() {
        // Calcula la fecha de finalización y la guarda de forma segura.
        let endDate = Date().addingTimeInterval(rewardDuration)
        UserDefaults.standard.set(endDate, forKey: userDefaultsKey)
        
        // Llama a la función principal para actualizar el estado de toda la app.
        updateAdFreeStatus()
    }

    /// La función principal que verifica y actualiza el estado de la recompensa.
    func updateAdFreeStatus() {
        // Intenta recuperar la fecha de finalización guardada.
        guard let endDate = UserDefaults.standard.object(forKey: userDefaultsKey) as? Date else {
            setAdFree(false) // Si no hay fecha, no hay recompensa.
            return
        }
        
        // Comprueba si la fecha de finalización aún no ha pasado.
        if Date() < endDate {
            self.timeRemaining = endDate.timeIntervalSince(Date())
            setAdFree(true) // Si es así, activa el modo sin anuncios.
        } else {
            setAdFree(false) // Si ya pasó, desactiva el modo sin anuncios.
            UserDefaults.standard.removeObject(forKey: userDefaultsKey) // Limpia la fecha guardada.
        }
    }

    // MARK: - Private Timer Logic
    
    /// Cambia el estado de `isAdFree` y se asegura de que la UI se actualice en el hilo principal.
    private func setAdFree(_ status: Bool) {
        DispatchQueue.main.async {
            self.isAdFree = status
            if status {
                self.startTimer() // Si se activa, enciende el temporizador.
            } else {
                self.stopTimer() // Si se desactiva, apaga el temporizador.
                self.timeRemainingFormatted = "00:00:00"
            }
        }
    }

    private func startTimer() {
        stopTimer() // Detén cualquier temporizador antiguo para evitar duplicados.
        
        // Crea un nuevo temporizador que se ejecuta cada segundo.
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                self.updateFormattedTime() // Actualiza el texto formateado.
            } else {
                self.setAdFree(false) // Si el tiempo llega a cero, desactiva el modo premium.
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// Convierte los segundos restantes en un formato de texto legible.
    private func updateFormattedTime() {
        let hours = Int(timeRemaining) / 3600
        let minutes = Int(timeRemaining) / 60 % 60
        let seconds = Int(timeRemaining) % 60
        
        // Actualiza la propiedad @Published, lo que causa que la UI se refresque.
        self.timeRemainingFormatted = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    // MARK: - Debug Methods
    #if DEBUG
    /// Resetea la recompensa para propósitos de depuración.
    /// Esta función solo se compilará en modo Debug y no existirá en la versión de la App Store.
    func resetRewardForDebug() {
        print("DEBUG: Reseteando la recompensa.")
        stopTimer()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        updateAdFreeStatus() // Esto pondrá todo en estado 'inactivo' de inmediato.
    }
    #endif
}
