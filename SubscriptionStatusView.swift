//
//  SubscriptionStatusView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 11/9/25.
//
// SubscriptionStatusView.swift
import SwiftUI

struct SubscriptionStatusView: View {
    // MARK: - Properties
    
    // 1. Accedemos al estado de los anuncios desde el entorno.
    // Esta es la conexión clave que hace que la vista sea dinámica.
    @EnvironmentObject var adState: AdState
    
    // MARK: - Body
    var body: some View {
        VStack {
            // 2. Usamos un 'if' para mostrar una vista u otra
            //    dependiendo del estado de 'isAdFree'.
            if adState.isAdFree {
                // --- VISTA CUANDO EL MODO PREMIUM ESTÁ ACTIVO ---
                premiumActiveView
            } else {
                // --- VISTA CUANDO NO HAY RECOMPENSA ACTIVA ---
                premiumInactiveView
            }
        }
        .navigationTitle("Suscripción")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - View Components
    
    /// Vista que se muestra cuando el usuario tiene la recompensa activa.
    private var premiumActiveView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Modo Premium Activo")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Tiempo restante:")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // 3. Mostramos el tiempo restante formateado directamente desde AdState.
            //    Este texto se actualizará automáticamente gracias al temporizador en AdState.
            Text(adState.timeRemainingFormatted)
                .font(.system(size: 50, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)

            Text("Disfruta de la aplicación sin anuncios.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
    
    /// Vista que se muestra cuando el usuario puede obtener la recompensa.
    private var premiumInactiveView: some View {
        VStack(spacing: 20) {
            Image(systemName: "gift.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Obtén Premium Gratis")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Ve un anuncio de video para obtener **4 horas** de la aplicación sin ningún tipo de publicidad.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Busca el ícono del regalo (🎁) en la pantalla principal para activar la recompensa.")
                .font(.footnote)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Previews
#Preview {
    // Para que los previews funcionen, necesitamos proveer un AdState.
    // Aquí mostramos ambas vistas para facilitar el diseño.
    NavigationView {
        VStack {
            // --- Preview del estado inactivo ---
            SubscriptionStatusView()
                .environmentObject(AdState()) // Un AdState por defecto está inactivo.
            
            Divider()
            
            // --- Preview del estado activo ---
            SubscriptionStatusView()
                .environmentObject(createActiveAdStateForPreview())
        }
    }
}

/// Función auxiliar solo para el preview, para simular un estado activo.
private func createActiveAdStateForPreview() -> AdState {
    let adState = AdState()
    adState.grantReward() // Simula la concesión de la recompensa
    return adState
}
