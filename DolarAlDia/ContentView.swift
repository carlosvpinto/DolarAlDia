//
//  ContentView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/1/24.
//
import SwiftUI

struct ContentView: View {
    @State private var selectedSection: String = "Dolar Al Día"
    @State private var showingUserForm = false // Controla la presentación del formulario
    @State private var navigateToUserList = false // Controla la navegación a la lista después de guardar un usuario
    @State private var userToEdit: UserData? // Usuario seleccionado para editar

    var body: some View {
        ZStack(alignment: .topLeading) {
            
            VStack {
                Spacer() // Mueve el contenido principal hacia abajo

                // Aquí mostramos la vista según la sección seleccionada en el menú
                if selectedSection == "Dolar Al Día" {
                    DolarAlDiaView()
                }
                if selectedSection == "Precio en Paginas" {
                    HStack {
                        MonitorListView()
                    }
                    .padding(.vertical, 8)
                }
                if selectedSection == "Precio del BCV" {
                    HStack {
                        MonitorBcvListView()
                    }
                    .padding(.vertical, 8)
                }
                // Nueva sección: Formulario de Usuarios
                if selectedSection == "Formulario de Usuarios" {
                    // Cuando se guarda un usuario, cambia a la lista de usuarios
                    if navigateToUserList {
                        UserListView() // Navegar a la lista de usuarios
                    } else {
                        UserFormView(onSave: {
                            // Cambia la bandera cuando el usuario se guarda
                            navigateToUserList = true
                        })
                    }
                }
                // Nueva sección: Lista de Usuarios
                if selectedSection == "Lista de Usuarios" {
                    UserListView() // Aquí añadimos la vista de la lista de usuarios
                }
            }
            .padding(.top, 50) // Añade espacio entre el menú y el contenido principal

            MenuView(selectedSection: $selectedSection) // Coloca el menú arriba del contenido principal
            
            // Botón de compartir en la parte superior derecha
            VStack {
                HStack {
                    Spacer() // Empuja el botón a la derecha
                    Button(action: {
                        compartirCapturaConTexto()
                    }) {
                        Image(systemName: "square.and.arrow.up") // Ícono típico de compartir
                            .font(.title) // Tamaño del ícono
                           // .foregroundColor(.blue) // Color del ícono
                            .padding()
                    }
                }
                Spacer() // Para mantener el botón en la parte superior
            }
            .padding(.top, 4) // Añade un pequeño padding en la parte superior
            .padding(.trailing, 10) // Añade un pequeño padding a la derecha
        }
    }
    
    func compartirCapturaConTexto() {
        // Capturar la pantalla
        if let capturaPantalla = tomarCapturaDePantalla() {
            // Texto personalizado para compartir
            let textoParaCompartir = textoDescriptivo()

            // Crear el UIActivityViewController con la imagen y el texto
            let itemsParaCompartir: [Any] = [capturaPantalla, textoParaCompartir]
            let activityViewController = UIActivityViewController(activityItems: itemsParaCompartir, applicationActivities: nil)

            // Excluir algunos tipos de actividad (opcional)
            // activityViewController.excludedActivityTypes = [.airDrop, .mail]

            // Obtener la escena activa y presentar el ActivityViewController
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let rootViewController = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
        }
    }

    func tomarCapturaDePantalla() -> UIImage? {
        // Obtén la escena de ventana activa
        guard let ventana = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first(where: { $0.isKeyWindow }) else {
            return nil
        }

        let renderer = UIGraphicsImageRenderer(size: ventana.bounds.size)
        let imagen = renderer.image { ctx in
            ventana.drawHierarchy(in: ventana.bounds, afterScreenUpdates: true)
        }
        return imagen
    }
    
    func textoDescriptivo() -> String {
        return "Captura de pantalla"
    }

}

#Preview {
    ContentView()
}
