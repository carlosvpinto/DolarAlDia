//
//  RewardStatusView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 11/8/25.
//
import SwiftUI

struct RewardStatusView: View {
    // 1. Accedemos al estado de los anuncios. Esto no cambia.
    @EnvironmentObject var adState: AdState
    
    var body: some View {
        VStack(spacing: 20) {
            
            // --- Icono y Título (Esta parte ya estaba bien) ---
            if adState.isAdFree {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                Text("Modo Premium Activado")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            } else {
                Image(systemName: "xmark.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.gray)
                Text("Modo Premium Inactivo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            // --- Descripción y tiempo restante ---
            VStack {
                Text(adState.isAdFree ? "¡Disfruta de la aplicación sin anuncios!" : "Puedes eliminar los anuncios por 4 horas viendo un video recompensado.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                if adState.isAdFree {
                    // 2. CAMBIO PRINCIPAL: Leemos el tiempo directamente de AdState.
                    //    No necesitamos un @State local ni una función para calcularlo.
                    Text(adState.timeRemainingFormatted)
                        .font(.system(size: 50, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                        .padding(.top)
                }
            }
            
            Spacer()
            
            // --- Botón de depuración (Esta parte ya estaba bien) ---
            #if DEBUG
            Button(action: {
                // Esta función ahora existirá en AdState
                adState.resetRewardForDebug()
            }) {
                Text("Resetear Recompensa (Debug)")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            #endif
        }
        .padding()
        // 3. ELIMINADO: Ya no necesitamos .onAppear, .onReceive, el timer local,
        //    ni la función updateRemainingTime(). AdState se encarga de todo
        //    y la vista se actualiza sola automáticamente.
    }
}

// MARK: - Preview
#Preview {
    RewardStatusView()
        .environmentObject(AdState()) // Provee un AdState para que el preview funcione
}
