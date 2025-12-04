//
//  MoreMenuView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 11/9/25.
//
// MoreMenuView.swift
import SwiftUI

struct MoreMenuView: View {
    // 1. Accedemos al Manager que inyectamos en DolarAlDiaApp
    @EnvironmentObject var storeManager: StoreKitManager
    
    // 2. Estado para controlar si mostramos la pantalla de venta
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            List {
                // SECCIÓN VIP (Solo aparece si NO es premium)
                if !storeManager.isPremiumUser {
                    Section {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                VStack(alignment: .leading) {
                                    Text("Hazte Premium")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Sin anuncios")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                // SECCIÓN GENERAL
                Section(header: Text("General")) {
                    // Opción 1: Bancos
                    NavigationLink(destination: MonitorBcvListView()) {
                        Label("Bancos", systemImage: "dollarsign.circle")
                    }
                    
                    // Opción 2: Estado de la Suscripción
                    // (Si es Premium dice "Activo", si no dice "Gratis")
                    NavigationLink(destination: SubscriptionStatusView()) {
                        HStack {
                            Label("Estado de la Suscripción", systemImage: "crown")
                            Spacer()
                            Text(storeManager.isPremiumUser ? "PRO" : "Gratis")
                                .font(.caption)
                                .foregroundColor(storeManager.isPremiumUser ? .green : .gray)
                                .padding(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(storeManager.isPremiumUser ? Color.green : Color.gray, lineWidth: 1)
                                )
                        }
                    }
                }
                
                // --- AÑADE AQUÍ FUTURAS OPCIONES ---
                // NavigationLink(destination: SettingsView()) {
                //     Label("Configuración", systemImage: "gear")
                // }
            }
            .navigationTitle("Más Opciones")
            // 3. Aquí adjuntamos el Paywall (se abre como una carta encima)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

// Para que el Preview no crashee en Xcode
struct MoreMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MoreMenuView()
            .environmentObject(StoreKitManager()) // Inyectamos uno de prueba
    }
}
