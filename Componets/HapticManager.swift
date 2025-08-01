//
//  HapticManager.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 7/29/25.
//
import UIKit

// Un gestor simple para reproducir vibraciones hápticas.
// Usamos un singleton para que sea fácil de acceder desde cualquier lugar.
class HapticManager {
    
    static let shared = HapticManager()
    
    private init() { } // Hacemos el inicializador privado para asegurar que solo haya una instancia.

    /// Reproduce un feedback háptico de notificación (éxito, advertencia o error).
    /// - Parameter type: El tipo de notificación a reproducir.
    func play(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        // Nos aseguramos de que se ejecute en el hilo principal, ya que es una acción de UI.
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare() // Prepara el motor háptico para reducir la latencia.
            generator.notificationOccurred(type)
        }
    }
    
    /// Reproduce un feedback háptico de impacto (ligero, medio, fuerte).
    /// - Parameter style: La intensidad del impacto.
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
}
