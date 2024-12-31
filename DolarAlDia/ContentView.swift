//
//  ContentView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/1/24.
//
import SwiftUI

struct ContentView: View {
    @State private var dolares: String = ""
    @State private var bolivares: String = ""
    @State private var tasaBCV: String = "45.5"
    @State private var tasaParalelo: String = "57.0"
    @State private var tasaPromedio: String = "55.0"
    @State var selectedButton: String = Constants.DOLARBCV
    @State private var selectedSection: String = Constants.DOLARALDIA
    @State private var showingUserForm = false // Controla la presentación del formulario
    @State private var navigateToUserList = false // Controla la navegación a la lista después de guardar un usuario
    @State private var userToEdit: UserData? // Usuario seleccionado para editar

    @State private var defaultUser: UserData?
      private let userDataManager = UserDataManager()

    var body: some View {
        ZStack(alignment: .topLeading) {
            
            VStack {
                Spacer() // Mueve el contenido principal hacia abajo

                // Aquí mostramos la vista según la sección seleccionada en el menú
                if selectedSection == Constants.DOLARALDIA {
                    DolarAlDiaView(dolares: $dolares, bolivares: $bolivares,tasaBCV: $tasaBCV, tasaParalelo: $tasaParalelo, tasaPromedio: $tasaPromedio, selectedButton: $selectedButton )
                }
                if selectedSection == Constants.PRECIOPAGINAS {
                    HStack {
                        MonitorListView()
                    }
                    .padding(.vertical, 8)
                }
                if selectedSection == Constants.PRECIOBCV {
                    HStack {
                        MonitorBcvListView()
                    }
                    .padding(.vertical, 8)
                }
                // Nueva sección: Formulario de Usuarios
                if selectedSection == Constants.PAGOSMOVILES {
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
                if selectedSection == Constants.LISTAPMOVILES{
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
            let textoParaCompartir = (generarTextoParaCompartir())

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
    
    func generarTextoParaCompartir() -> String {
        // Iniciar el texto con el tipo de dólar y monto en dólares
        if dolares != "" {
            
        if selectedButton == Constants.DOLARBCV {
            if dolares != "" {
                let textoCompartir = "-Tasa BCV:\(tasaBCV) -Monto en Dolares:\(dolares) -Monto en Bolivares: \(bolivares)"
                return textoCompartir
            }
        }
        if selectedButton == Constants.DOLARPARALELO {
            let textoCompartir = "-Tasa PARALELO:\(tasaParalelo) -Monto en Dolares:\(dolares) -Monto en Bolivares: \(bolivares)"
            return textoCompartir
        }
        if selectedButton == Constants.DOLARPROMEDIO {
            let textoCompartir = "-Tasa Promedio:\(tasaPromedio) -Monto en Dolares:\(dolares) -Monto en Bolivares: \(bolivares)"
            return textoCompartir
        }
        }else{
            let textoCompartir = "-Dolar BCV: \(tasaBCV) -Dolar PARALELO: \(tasaParalelo) -Dolar Promedio: \(tasaPromedio) \(loadDefaultUser()) "
            print(textoCompartir)
            return textoCompartir
        }
        let textoCompartir = "Tasa Otro que nose"
        return textoCompartir
    }
    
    // Función para cargar el usuario predeterminado
    private func loadDefaultUser()-> String {
           defaultUser = userDataManager.loadDefaultUser()
        let datosPagomovil = "-Banco: \(String(defaultUser!.bank)) -Telefono: \(String(defaultUser!.phone)) -Cedula: \(String (defaultUser!.idNumber)) "
        
        return datosPagomovil
       }
}

#Preview {
    ContentView()
}
