//
//  ReviewManager.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 8/16/25.
//

import Foundation
import StoreKit

class ReviewManager {
    
    static let shared = ReviewManager()
    
    private let userDefaults = UserDefaults.standard
    private let minimumSessions = 4
    
    // El número máximo de veces que intentaremos pedir una reseña.
    private let maxReviewRequests = 2
    
    // Llaves para UserDefaults
    private let sessionCountKey = "reviewSessionCount"
    // Usaremos un contador para las solicitudes en lugar de una bandera booleana.
    private let reviewRequestCountKey = "reviewRequestCount"
    
    private init() {}
    
    /// Llama a esta función cada vez que la app entra en primer plano.
    func trackSession() {
        // Obtenemos cuántas veces ya hemos pedido una reseña.
        let requestCount = userDefaults.integer(forKey: reviewRequestCountKey)
        
        // =================================================================
        // PASO 1: Comprobar si ya hemos alcanzado el límite de solicitudes.
        // Si ya hemos pedido la reseña 2 veces, no hacemos NADA MÁS.
        // =================================================================
        guard requestCount < maxReviewRequests else {
            print("REVIEW_MANAGER: Se ha alcanzado el número máximo de solicitudes de reseña (\(maxReviewRequests)). No se volverá a solicitar.")
            return
        }
        
        // Si no hemos alcanzado el límite, continuamos con la lógica del contador de sesiones.
        var sessionCount = userDefaults.integer(forKey: sessionCountKey)
        sessionCount += 1
        userDefaults.set(sessionCount, forKey: sessionCountKey)
        
        print("REVIEW_MANAGER: Sesión número \(sessionCount). Solicitudes realizadas: \(requestCount) de \(maxReviewRequests).")
        
        // Si el contador de sesiones alcanza el umbral...
        if sessionCount >= minimumSessions {
            requestReview()
        }
    }
    
    private func requestReview() {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                
                SKStoreReviewController.requestReview(in: scene)
                print("REVIEW_MANAGER: Solicitud de reseña enviada al sistema.")
                
                // =================================================================
                // PASO 2: Incrementar el contador de SOLICITUDES.
                // =================================================================
                var requestCount = self.userDefaults.integer(forKey: self.reviewRequestCountKey)
                requestCount += 1
                self.userDefaults.set(requestCount, forKey: self.reviewRequestCountKey)
                
                // =================================================================
                // PASO 3: Resetear el contador de SESIONES para el próximo ciclo.
                // =================================================================
                self.userDefaults.set(0, forKey: self.sessionCountKey)
                print("REVIEW_MANAGER: Contador de sesiones reseteado. Próxima solicitud en \(self.minimumSessions) sesiones.")
                
            } else {
                print("REVIEW_MANAGER: No se pudo encontrar una escena activa para solicitar la reseña.")
            }
        }
    }
}
