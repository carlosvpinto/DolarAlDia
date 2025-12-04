//
//  PaywallView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/3/25.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var storeManager: StoreKitManager
    @Environment(\.dismiss) var dismiss
    
    // Colores personalizados para un look financiero
    let accentColor = Color.green
    let secondaryColor = Color.primary.opacity(0.8)
    
    var body: some View {
        ZStack {
            // Fondo con un degradado sutil para dar profundidad
            LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemBackground), Color(UIColor.systemGray6)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    
                    // --- 1. Cabecera y Botón Cerrar ---
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                    }
                    .padding(.horizontal)
                    
                    // --- 2. Identidad de Marca ---
                    VStack(spacing: 10) {
                        Image("logoredondo") // Tu logo
                            .resizable()
                            .scaledToFit()
                            .frame(height: 90)
                            .shadow(radius: 10)
                        
                        Text("Dolar al Dia")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 5) {
                            Text("PRO")
                                .font(.caption)
                                .fontWeight(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            
                            Text("Acceso Total")
                                .font(.headline)
                                .foregroundColor(secondaryColor)
                        }
                    }
                    
                    // --- 3. Beneficios (Por qué comprar) ---
                    VStack(alignment: .leading, spacing: 15) {
                        BenefitRow(icon: "rectangle.slash", title: "Cero Publicidad", subtitle: "Navegación fluida sin interrupciones.")
                    
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 10)
                    
                    Text("Selecciona tu plan ideal")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    // --- 4. Tarjetas de Productos ---
                    if storeManager.products.isEmpty {
                        VStack {
                            ProgressView()
                            Text("Cargando precios...")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(height: 150)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(storeManager.products) { product in
                                PurchaseButton(product: product) {
                                    Task { await storeManager.purchase(product) }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // --- 5. Footer (Legal y Restaurar) ---
                    VStack(spacing: 15) {
                        Button {
                            Task { await storeManager.restorePurchases() }
                        } label: {
                            Text("Restaurar Compras")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(accentColor)
                        }
                        
                        HStack(spacing: 20) {
                            Link("Términos", destination: URL(string: "https://dolaraldiavzla.com/terminos")!)
                            Link("Privacidad", destination: URL(string: "https://dolaaraldiavzla.com/privacidad")!)
                        }
                        .font(.caption2)
                        .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            Task { await storeManager.loadProducts() }
        }
        // Corrección del onChange para iOS 17+
        .onChange(of: storeManager.isPremiumUser) { _, isPremium in
            if isPremium {
                dismiss()
            }
        }
    }
}

// --- COMPONENTES VISUALES ---

// 1. Fila de Beneficios
struct BenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// 2. Botón/Tarjeta de Compra
struct PurchaseButton: View {
    let product: Product
    let action: () -> Void
    
    // Detectamos si es anual para destacarlo
    var isAnnual: Bool {
           return product.subscription?.subscriptionPeriod.unit == .year
    }
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                // Tarjeta Principal
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // Nombre del Plan (Detectado automáticamente)
                        Text(isAnnual ? "PLAN ANUAL" : "PLAN MENSUAL")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(isAnnual ? .green : .gray)
                            .tracking(1) // Espaciado entre letras
                        
                        // Precio Grande
                        Text(product.displayPrice)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        // Texto descriptivo pequeño
                        Text(isAnnual ? "Facturado cada año" : "Facturado cada mes")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Flecha o Check
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                // Borde: Verde si es anual, gris suave si es mensual
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isAnnual ? Color.green : Color.gray.opacity(0.2), lineWidth: isAnnual ? 2 : 1)
                )
                .shadow(color: isAnnual ? Color.green.opacity(0.15) : Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                
                // Etiqueta de "Mejor Oferta" (Solo para el anual)
                if isAnnual {
                    Text("MEJOR OFERTA")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .offset(x: -10, y: -10) // Lo sacamos un poco hacia arriba
                        .shadow(radius: 2)
                }
            }
        }
        .buttonStyle(.plain) // Efecto de botón nativo
    }
}
