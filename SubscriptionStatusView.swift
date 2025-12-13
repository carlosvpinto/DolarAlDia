//
//  SubscriptionStatusView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 11/9/25.
//
// SubscriptionStatusView.swift
import SwiftUI
import StoreKit

struct SubscriptionStatusView: View {
    // MARK: - Properties
    
    // 1. Estado de la Recompensa (Video)
    @EnvironmentObject var adState: AdState
    
    // 2. Estado de la Tienda (Para mostrar los botones de compra)
    @EnvironmentObject var storeManager: StoreKitManager
    
    // MARK: - Body
    var body: some View {
        VStack {
            if adState.isAdFree {
                // --- MODO PREMIUM ACTIVO ---
                premiumActiveView
            } else {
                // --- MODO INACTIVO (OFERTA) ---
                premiumInactiveView
            }
        }
        .navigationTitle("Suscripción")
        .navigationBarTitleDisplayMode(.inline)
        // Cargar productos al entrar si no están listos
        .task {
            if storeManager.products.isEmpty {
                await storeManager.loadProducts()
            }
        }
    }
    
    // MARK: - View Components
    
    /// Vista cuando el usuario YA TIENE el beneficio activo
    private var premiumActiveView: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 90))
                .foregroundColor(.green)
                .shadow(radius: 5)
            
            VStack(spacing: 10) {
                Text("Modo Premium Activo")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Tiempo restante:")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Tiempo formateado
            Text(adState.timeRemainingFormatted)
                .font(.system(size: 45, weight: .heavy, design: .monospaced))
                .foregroundColor(.primary)
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 5)

            Text("La aplicación está libre de publicidad.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    /// Vista con las OPCIONES (Diseño Mejorado)
    private var premiumInactiveView: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // CABECERA
                VStack(spacing: 10) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange, .yellow)
                    
                    Text("Elimina la Publicidad")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Elige la opción que prefieras para disfrutar Dólar al Día sin interrupciones.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // OPCIÓN 1: SUSCRIPCIÓN (StoreKit)
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text("Opción Pro (Suscripción)")
                            .font(.headline)
                        Spacer()
                    }
                    
                    if storeManager.products.isEmpty {
                        ProgressView("Cargando precios...")
                    } else {
                        ForEach(storeManager.products) { product in
                            Button(action: {
                                Task { await storeManager.purchase(product) }
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(product.displayName)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        Text("Renovación automática")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(product.displayPrice)
                                        .fontWeight(.bold)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                            }
                        }
                        
                        Button("Restaurar Compras") {
                            Task { await storeManager.restorePurchases() }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 5)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // SEPARADOR
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    Text("O").font(.caption).fontWeight(.bold).foregroundColor(.secondary)
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                }
                .padding(.horizontal, 40)
                
                // OPCIÓN 2: VIDEO (Informativo)
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "gift.fill")
                            .foregroundColor(.blue)
                        Text("Opción Gratuita")
                            .font(.headline)
                    }
                    
                    Text("Puedes obtener **4 horas** sin publicidad totalmente gratis viendo un video corto.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Para activar esta opción, regresa a la pantalla principal y toca el ícono del regalo (🎁) o el botón flotante.")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(10)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .background(Color(UIColor.systemGroupedBackground)) // Fondo gris general
    }
}

#Preview {
    NavigationView {
        SubscriptionStatusView()
            .environmentObject(AdState())
            .environmentObject(StoreKitManager())
    }
}                                                                                                                                                                                             
