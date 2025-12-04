//
//  StoreKitManager.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/3/25.
//
import Foundation
import StoreKit

// Alias para identificar tus suscripciones fácilmente
enum ProductID: String, CaseIterable {
    case mensual = "com.dolaraldia.pro.mensual" // TIENE QUE SER IGUAL A APP STORE CONNECT
    case anual = "com.dolaraldia.pro.anual"     // TIENE QUE SER IGUAL A APP STORE CONNECT
}

@MainActor
class StoreKitManager: ObservableObject {
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isPremiumUser: Bool = false
    
    // NUEVO: Guardaremos la fecha de vencimiento aquí
     @Published var subscriptionExpirationDate: Date? = nil
    
    private var updates: Task<Void, Never>? = nil

    init() {
        // Iniciar el "oído" para escuchar compras que ocurren fuera de la app (renovaciones)
        updates = observeTransactionUpdates()
    }

    deinit {
        updates?.cancel()
    }

    // 1. Cargar productos desde Apple
    func loadProducts() async {
        do {
            // Convertimos el enum a un set de Strings
            let productIds = ProductID.allCases.map { $0.rawValue }
            self.products = try await Product.products(for: productIds)
            
            // Los ordenamos por precio (el más barato primero o como prefieras)
            self.products.sort { $0.price < $1.price }
            
            // Verificamos si ya compró antes
            await updateCustomerProductStatus()
        } catch {
            print("Error cargando productos: \(error)")
        }
    }

    // 2. Acción de Comprar
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // La compra fue exitosa. Verificamos la firma criptográfica.
                switch verification {
                case .verified(let transaction):
                    await transaction.finish() // Avisar a Apple que entregamos el servicio
                    await updateCustomerProductStatus() // Actualizar estado del usuario
                case .unverified:
                    print("La transacción no se pudo verificar.")
                }
            case .userCancelled:
                print("El usuario canceló.")
            case .pending:
                print("Compra pendiente de aprobación.")
            @unknown default:
                break
            }
        } catch {
            print("Falló la compra: \(error)")
        }
    }

    // MODIFICADO: Capturar la fecha de expiración
       func updateCustomerProductStatus() async {
           var purchasedIds: Set<String> = []
           var expirationDate: Date? = nil // Variable temporal
           
           for await result in Transaction.currentEntitlements {
               if case .verified(let transaction) = result {
                   // Si es del tipo suscripción, guardamos su fecha
                   if transaction.productType == .autoRenewable {
                       purchasedIds.insert(transaction.productID)
                       expirationDate = transaction.expirationDate
                   }
               }
           }
           
           self.purchasedProductIDs = purchasedIds
           self.isPremiumUser = !purchasedIds.isEmpty
           self.subscriptionExpirationDate = expirationDate // Guardamos la fecha
       }
    
    // 4. Restaurar Compras (Obligatorio tener el botón)
    func restorePurchases() async {
        try? await AppStore.sync()
        await updateCustomerProductStatus()
    }

    // 5. Escuchar actualizaciones en segundo plano (renovaciones automáticas)
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updateCustomerProductStatus()
                }
            }
        }
    }
}
