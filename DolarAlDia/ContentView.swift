//
//  ContentView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/1/24.
//
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView: View {
    @State private var dolares: String = ""
    @State private var bolivares: String = ""
    @State private var tasaBCV: String = "45.5"
    @State private var tasaParalelo: String = "57.0"
    @State private var tasaPromedio: String = "55.0"
    @State var selectedButton: String = Constants.DOLARBCV
    @State private var selectedSection: String = Constants.DOLARALDIA
    @State private var showingUserForm = false
    @State private var navigateToUserList = false
    @State private var userToEdit: UserData?
    @State private var defaultUser: UserData?
    @State private var isMenuOpen: Bool = false // Controla el estado del menú
    @State private var showingConfirmationDialog = false // Nuevo estado para el diálogo de confirmación

    private let userDataManager = UserDataManager()

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                VStack {
                    Spacer()

                    // Mostrar contenido según la sección seleccionada
                    if selectedSection == Constants.DOLARALDIA {
                        DolarAlDiaView(dolares: $dolares, bolivares: $bolivares, tasaBCV: $tasaBCV, tasaParalelo: $tasaParalelo, tasaPromedio: $tasaPromedio, selectedButton: $selectedButton)
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
                    if selectedSection == Constants.PAGOSMOVILES {
                        if navigateToUserList {
                            UserListView()
                        } else {
                            UserFormView(onSave: {
                                navigateToUserList = true
                            })
                        }
                    }
                    if selectedSection == Constants.LISTAPMOVILES {
                        UserListView()
                    }
                }
                .padding(.top, 20)
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
                // NUEVO: Capa semitransparente para detectar toques fuera del menú
                if isMenuOpen {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                isMenuOpen = false
                            }
                        }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Botón de menú en el toolbar
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    // Botón de compartir en el toolbar
                    Button(action: {
                        showingConfirmationDialog = true // Mostrar el diálogo de confirmación
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .imageScale(.large)
                    }
                }
            }
            .confirmationDialog(
                "¿Compartir datos de pago móvil?",
                isPresented: $showingConfirmationDialog,
                titleVisibility: .visible
            ) {
                Button("Compartir con datos", action: {
                    compartirCapturaConTexto(incluirDatosUsuario: true) // Compartir con datos de usuario
                })
                Button("Compartir sin datos", action: {
                    compartirCapturaConTexto(incluirDatosUsuario: false) // Compartir sin datos de usuario
                })
                Button("Cancelar", role: .cancel) {
                    // No hacer nada
                }
            }
            .overlay(
                MenuView(selectedSection: $selectedSection, isMenuOpen: $isMenuOpen)
                    .frame(maxWidth: isMenuOpen ? 350 : 0) // Ajustar el ancho del menú
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isMenuOpen)
                    .offset(x: isMenuOpen ? 0 : -250) // Mover el menú hacia la izquierda cuando está cerrado
            )
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        if isMenuOpen {
                            withAnimation {
                                isMenuOpen = false
                            }
                        }
                    }
            )
        }
    }
        
    

    
    func compartirCapturaConTexto(incluirDatosUsuario: Bool) {
            // Capturar la pantalla
            guard let capturaPantalla = tomarCapturaDePantalla() else { return }

            // Texto personalizado para compartir
            let textoParaCompartir = generarTextoParaCompartir(incluirDatosUsuario: incluirDatosUsuario)

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

        func generarTextoParaCompartir(incluirDatosUsuario: Bool) -> String {
            var textoCompartir = ""

            if dolares != "" {
                if selectedButton == Constants.DOLARBCV {
                    textoCompartir = "-Tasa BCV:\(tasaBCV) -Monto en Dolares:\(dolares) -Monto en Bolivares: \(bolivares)"
                } else if selectedButton == Constants.DOLARPARALELO {
                    textoCompartir = "-Tasa PARALELO:\(tasaParalelo) -Monto en Dolares:\(dolares) -Monto en Bolivares: \(bolivares)"
                } else if selectedButton == Constants.DOLARPROMEDIO {
                    textoCompartir = "-Tasa Promedio:\(tasaPromedio) -Monto en Dolares:\(dolares) -Monto en Bolivares: \(bolivares)"
                }
            } else {
                textoCompartir = "-Dolar BCV: \(tasaBCV) -Dolar PARALELO: \(tasaParalelo) -Dolar Promedio: \(tasaPromedio)"
            }

            if incluirDatosUsuario {
                textoCompartir += " \n \(loadDefaultUser())"
            }

            return textoCompartir
        }

    // Función para cargar el usuario predeterminado
    private func loadDefaultUser() -> String {
        defaultUser = userDataManager.loadDefaultUser()
        
        if let defaultUser = defaultUser {
            var datosPagomovil = "*Datos del Pago Móvil:*\n" // Título en negrita
            datosPagomovil += " Banco: \(defaultUser.bank)\n" // Añadir internado antes de "Banco"
            datosPagomovil += " Teléfono: \(defaultUser.phone)\n" // Añadir internado antes de "Teléfono"
            datosPagomovil += " Cédula: \(defaultUser.idNumber)\n" // Añadir internado antes de "Cédula"
            return datosPagomovil
        } else {
            return "*Datos del Pago Móvil:*\n No hay usuario predeterminado" // Título en negrita
        }
    }


    }

    #Preview {
        ContentView()
    }
