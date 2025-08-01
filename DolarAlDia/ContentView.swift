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
    // ----- ESTADO PRINCIPAL DE LA APLICACIÓN -----
    @State private var dolares: String = ""
    @State private var bolivares: String = ""
    @State private var tasaBCV: String = "45.5"
    @State private var tasaEuroBcv: String = "57.0"
    @State private var selectedButton: String = Constants.DOLARBCV
    @State private var selectedSection: String = Constants.DOLARALDIA
    

    
    // Estado para los diálogos de compartir
    @State private var showingConfirmationDialog = false
    @State private var mostrarDialogoImagen = false
    @State private var compartirTexto: String = ""
    
    // MARK: - Usamos el UserSession compartido
    @EnvironmentObject var userSession: UserSession
    
    private let userDataManager = UserDataManager()
  

    var body: some View {
        NavigationView {
            // MainTabView ahora ocupa todo el cuerpo de la vista
            MainTabView(
                selectedSection: $selectedSection,
                dolares: $dolares,
                bolivares: $bolivares,
                tasaBCV: $tasaBCV,
                tasaEuro: $tasaEuroBcv,
                selectedButton: $selectedButton
            )
            .navigationTitle(titleForSection(selectedSection))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                                  Button(action: {
                                      // La lógica ahora es súper simple:
                                      // Solo leemos la propiedad del UserSession, que SIEMPRE está actualizada.
                                      if userSession.hayUsuarioGuardado {
                                          showingConfirmationDialog = true
                                      } else {
                                          // Si no hay usuario, compartimos directamente sin preguntar.
                                          compartirTexto = generarTextoParaCompartir(incluirDatosUsuario: false)
                                          compartirCapturaConTextoYImagen(compartirImagenDePago: false)
                                      }
                                  }) {
                                      Image(systemName: "square.and.arrow.up")
                                          .imageScale(.large)
                                  }
                    // El diálogo solo se mostrará cuando hay un usuario,
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
                                    
                    
                              }
                          }
                      }
                        .navigationViewStyle(.stack)
                      
                     
                  }
    // ----- FUNCIONES AUXILIARES -----
    
   
    private func titleForSection(_ section: String) -> String {
        switch section {
        case Constants.DOLARALDIA: return "Calculadora"
        case Constants.PRECIOBCV: return "Precios Oficiales"
        case Constants.HISTORIA_BCV: return "Historial BCV"
        case Constants.LISTAPMOVILES: return "Pago Móvil"
        default: return "Dolar Al Dia"
        }
    }
    
    func compartirCapturaConTextoYImagen(compartirImagenDePago: Bool) {

        // --- Parte 1: Decidir qué contenido compartir (Tu lógica actual, sin cambios) ---
        
        var imagenParaCompartir: UIImage?

        // 1. Prioridad 1: Imagen personalizada si el usuario la quiere.
        if compartirImagenDePago {
            imagenParaCompartir = obtenerImagenUsuarioPredeterminado()
        }

        // 2. Prioridad 2: Captura de pantalla condicional.
        // Solo si no se usó la imagen personalizada y si estamos en la vista correcta.
        if imagenParaCompartir == nil {
            if selectedSection == Constants.DOLARALDIA {
                imagenParaCompartir = tomarCapturaDePantalla()
            }
        }
        
        // 3. Preparamos el array de ítems. Siempre incluimos el texto.
        var itemsParaCompartir: [Any] = [self.compartirTexto]
        
        // Si después de la lógica anterior conseguimos una imagen, la añadimos.
        if let imagenFinal = imagenParaCompartir {
            itemsParaCompartir.insert(imagenFinal, at: 0)
        }

        // --- Parte 2: Presentar la hoja de compartir (Con la corrección para iPad) ---
        
        // 4. Creamos el controlador de la actividad.
        let activityViewController = UIActivityViewController(activityItems: itemsParaCompartir, applicationActivities: nil)
        
        // 5. Obtenemos el controlador de la vista raíz.
        guard let rootViewController = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first(where: { $0.isKeyWindow })?.rootViewController else {
            print("No se pudo obtener el rootViewController.")
            return
        }
        
        // MARK: - AQUÍ ESTÁ LA SOLUCIÓN PARA EL CRASH EN IPAD
        // Antes de presentar, configuramos el popover si estamos en un iPad.
        if let popoverController = activityViewController.popoverPresentationController {
            // Le damos al popover un "ancla" visual. Le decimos que se origine
            // desde la vista principal de la pantalla.
            popoverController.sourceView = rootViewController.view
            
            // Especificamos que el popover debe aparecer en el centro de la pantalla.
            // Esto es robusto y evita buscar un botón específico.
            popoverController.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                                  y: rootViewController.view.bounds.midY,
                                                  width: 0,
                                                  height: 0)
            
            // Ocultamos la flecha del popover, ya que no apunta a nada.
            popoverController.permittedArrowDirections = []
        }
        
        // 6. Presentamos la hoja de compartir. Ahora funcionará en iPhone y iPad.
        rootViewController.present(activityViewController, animated: true, completion: nil)
    }
    
    func tomarCapturaDePantalla(escala: CGFloat = 0.8) -> UIImage? {
        // 1. Obtenemos la ventana principal de la aplicación (sin cambios).
        guard let ventana = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first(where: { $0.isKeyWindow }) else {
            return nil
        }

        // 2. Calculamos el nuevo tamaño basado en el factor de escala.
        let tamanoOriginal = ventana.bounds.size
        let nuevoTamano = CGSize(
            width: tamanoOriginal.width * escala,
            height: tamanoOriginal.height * escala
        )

        // En lugar de usar `ventana.bounds.size`, usamos `nuevoTamano`.
        let renderer = UIGraphicsImageRenderer(size: nuevoTamano)

        // 4. Dibujamos la jerarquía de la vista en el nuevo lienzo más pequeño.
        // Esto efectivamente redimensiona la imagen durante la creación.
        let imagen = renderer.image { ctx in
            // El rectángulo de dibujo ahora coincide con el nuevo tamaño del lienzo.
            ventana.drawHierarchy(in: CGRect(origin: .zero, size: nuevoTamano), afterScreenUpdates: true)
        }
        
        return imagen
    }

    func generarTextoParaCompartir(incluirDatosUsuario: Bool) -> String {
        var textoCompartir = ""
        if !dolares.isEmpty, let dblDolares = Double(dolares), dblDolares > 0 {
            if selectedButton == Constants.DOLARBCV {
                textoCompartir = "- Tasa BCV: \(tasaBCV)\n- Monto en Dólares: \(dolares)\n- Monto en Bolívares: \(bolivares)"
            } else if selectedButton == Constants.DOLAREUROBCV {
                textoCompartir = "- Tasa EURO BCV: \(tasaEuroBcv)\n- Monto en Euro: \(dolares)\n- Monto en Bolívares: \(bolivares)"
            }
        } else {
            textoCompartir = "- Dólar BCV: \(tasaBCV)\n- Euro BCV: \(tasaEuroBcv)"
        }
        
        if incluirDatosUsuario {
            textoCompartir += "\n\n\(loadDefaultUser())"
        }
        return textoCompartir
    }

    private func loadDefaultUser() -> String {
            // Obtenemos el usuario directamente del manager.
            if let user = userDataManager.loadDefaultUser() {
                return """
                *Datos del Pago Móvil:*
                Banco: \(user.bank)
                Teléfono: \(user.phone)
                C.I./RIF: \(user.idType)-\(user.idNumber)
                """
            } else {
                return "*Datos del Pago Móvil:*\nNo hay datos de pago movil almacenado."
            }
        }
        
        func obtenerImagenUsuarioPredeterminado() -> UIImage? {
              if let user = userDataManager.loadDefaultUser(), let data = user.imageData, let imagen = UIImage(data: data) {
                  return imagen
              }
              return nil
          }
}
