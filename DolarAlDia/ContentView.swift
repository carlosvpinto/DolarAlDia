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
    @State private var tasaEuroBcv: String = "57.0"
    @State var selectedButton: String = Constants.DOLARBCV
    @State private var selectedSection: String = Constants.DOLARALDIA
    @State private var showingUserForm = false
    @State private var navigateToUserList = false
    @State private var userToEdit: UserData?
    @State private var defaultUser: UserData?
    @State private var isMenuOpen: Bool = false
    @State private var showingConfirmationDialog = false

    @State private var mostrarDialogoImagen = false
    @State private var compartirTexto: String = ""
    @State private var compartirImagenDePago: UIImage? = nil

    private let userDataManager = UserDataManager()

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                VStack {
                    Spacer()
                    
                    if selectedSection == Constants.DOLARALDIA {
                        DolarAlDiaView(
                            dolares: $dolares,
                            bolivares: $bolivares,
                            tasaBCV: $tasaBCV,
                            tasaEuro: $tasaEuroBcv,
                            selectedButton: $selectedButton
                        )
                    }
                    if selectedSection == Constants.PRECIOPAGINAS {
                        HStack {
                            MonitorListView()
                        }
                    }
                    if selectedSection == Constants.PRECIOBCV {
                        HStack {
                            MonitorBcvListView()
                        }
                    }
                    if selectedSection == Constants.HISTORIA_BCV{
                        HStack {
                            BCVHistoryView(
                                imgUrl: "https://res.cloudinary.com/dcpyfqx87/image/upload/v1729921478/monitors/public_id:bcv.webp",
                                navigationTitle: "Historia Dólar BCV",
                                page: "bcv",
                                monitor: "usd"
                            )
                        }
                    }
                    if selectedSection == Constants.HISTORIA_PARALELO{
                        HStack {
                            BCVHistoryView(
                                imgUrl: "https://res.cloudinary.com/dcpyfqx87/image/upload/v1729921479/monitors/public_id:epv.webp",
                                navigationTitle: "Historia Dólar Paralelo",
                                page: "criptodolar",
                                monitor: "enparalelovzla"
                            )
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
                    Button(action: {
                        UIApplication.shared.endEditing()
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingConfirmationDialog = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .imageScale(.large)
                    }
                }
            }

            // Primer diálogo: ¿Compartir datos de pago móvil?
            .confirmationDialog(
                "¿Compartir datos de pago móvil?",
                isPresented: $showingConfirmationDialog,
                titleVisibility: .visible
            ) {
                Button("SI") {
                    compartirTexto = generarTextoParaCompartir(incluirDatosUsuario: true)
                    mostrarDialogoImagen = true
                }
                Button("NO") {
                    compartirTexto = generarTextoParaCompartir(incluirDatosUsuario: false)
                    compartirCapturaConTextoYImagen(compartirImagenDePago: false)
                }
                Button("Cancelar", role: .cancel) { }
            }

            // Segundo diálogo: ¿Incluir imagen personalizada?
            .confirmationDialog(
                "¿Deseas incluir tu imagen personalizada de pago móvil?",
                isPresented: $mostrarDialogoImagen,
                titleVisibility: .visible
            ) {
                Button("Sí, incluir imagen") {
                    compartirCapturaConTextoYImagen(compartirImagenDePago: true)
                }
                Button("No incluir imagen") {
                    compartirCapturaConTextoYImagen(compartirImagenDePago: false)
                }
                Button("Cancelar", role: .cancel) { }
            }
            .overlay(
                MenuView(selectedSection: $selectedSection, isMenuOpen: $isMenuOpen)
                    .frame(maxWidth: isMenuOpen ? 350 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isMenuOpen)
                    .offset(x: isMenuOpen ? 0 : -250)
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
    
    // NUEVA FUNCIÓN: Compartir con/sin imagen personalizada
    func compartirCapturaConTextoYImagen(compartirImagenDePago: Bool) {
        guard let capturaPantalla = tomarCapturaDePantalla() else { return }
        var itemsParaCompartir: [Any] = [capturaPantalla, compartirTexto]
        if compartirImagenDePago, let imagenPersonalizada = obtenerImagenUsuarioPredeterminado() {
            itemsParaCompartir.insert(imagenPersonalizada, at: 0) // opcional: al inicio
        }
        let activityViewController = UIActivityViewController(activityItems: itemsParaCompartir, applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootViewController = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }

    func tomarCapturaDePantalla() -> UIImage? {
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
                textoCompartir = "-Tasa BCV: \(tasaBCV) \n-Monto en Dólares: \(dolares)\n-Monto en Bolívares: \(bolivares)"
            } else if selectedButton == Constants.DOLAREUROBCV {
                textoCompartir = "-Tasa EURO BCV: \(tasaEuroBcv)\n-Monto en Euro: \(dolares)\n-Monto en Bolívares: \(bolivares)"
            }
        } else {
            textoCompartir = "-Dólar BCV: \(tasaBCV) \n-Euro BCV: \(tasaEuroBcv)\n"
        }
        if incluirDatosUsuario {
            textoCompartir += " \n \(loadDefaultUser())"
        }
        return textoCompartir
    }

    private func loadDefaultUser() -> String {
        defaultUser = userDataManager.loadDefaultUser()
        if let defaultUser = defaultUser {
            var datosPagomovil = "*Datos del Pago Móvil:*\n"
            datosPagomovil += " Banco: \(defaultUser.bank)\n"
            datosPagomovil += " Teléfono: \(defaultUser.phone)\n"
            datosPagomovil += " \(defaultUser.idType)-\(defaultUser.idNumber)\n"
            return datosPagomovil
        } else {
            return "*Datos del Pago Móvil:*\n No hay usuario predeterminado"
        }
    }
    
    // DEVUELVE LA IMAGEN DEL USUARIO PREDETERMINADO
    func obtenerImagenUsuarioPredeterminado() -> UIImage? {
        let user = userDataManager.loadDefaultUser()
        if let data = user?.imageData, let imagen = UIImage(data: data) {
            return imagen
        }
        return nil
    }
}
