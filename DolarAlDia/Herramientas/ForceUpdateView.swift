// ForceUpdateView.swift

import SwiftUI

struct ForceUpdateView: View {
    
    // Esta propiedad recibirá la URL de la App Store
    let updateURL: URL
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .symbolRenderingMode(.hierarchical)
            
            Text("Actualización Requerida")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Para continuar usando la app, por favor actualiza a la última versión disponible en la App Store.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Link es la forma correcta y moderna de abrir URLs en SwiftUI.
            // Automáticamente abre el navegador o la App Store.
            Link(destination: updateURL) {
                Text("Actualizar ahora")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemGroupedBackground)) // Fondo para modo claro/oscuro
        .edgesIgnoringSafeArea(.all)
        // Este modificador es crucial: evita que el usuario pueda
        // cerrar la vista deslizando hacia abajo.
        .interactiveDismissDisabled()
    }
}
