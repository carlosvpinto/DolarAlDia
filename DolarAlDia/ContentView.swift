//
//  ContentView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/1/24.
//
import SwiftUI
import AppTrackingTransparency // <-- 1. IMPORTA EL FRAMEWORK para los permisos de uicacion
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView: View {
    
    // 1. AÑADIMOS EL COORDINADOR COMO UN OBJETO OBSERVADO
       //    Esto conecta la vista con el coordinador. Ahora la vista se actualizará
       //    automáticamente cuando la propiedad @Published 'isReady' cambie.
       @ObservedObject private var rewardedAdCoordinator = RewardedAdCoordinator.shared
   
    
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
    
    // 👇 AÑADIDO: Nuevo estado para controlar la alerta del anuncio recompensado.
    @State private var mostrarAlertaRecompensa = false
    
    // MARK: - Usamos el UserSession compartido
    @EnvironmentObject var userSession: UserSession
    
    // 👇 AÑADIDO: Accede al gestor de estado de anuncios desde el entorno.
    @EnvironmentObject var adState: AdState
    
    
    // =================================================================
    // PASO 1: AÑADIMOS LA INSTANCIA DEL COORDINADOR DE ANUNCIOS
    // =================================================================
    private let adCoordinator = InterstitialAdCoordinator.shared
 
    
   
    
    private let userDataManager = UserDataManager()
    
    // Esta variable nos dirá en qué estado se encuentra la app.
    @Environment(\.scenePhase) private var scenePhase
  

    var body: some View {
        
        ZStack(alignment: .bottomTrailing) {
        VStack(spacing: 0) {
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
            // Se añade espacio en la parte inferior para que el banner no tape el contenido
           // .padding(.bottom, 50)
            
            // 👇 Solo muestra el banner si NO estamos en período sin anuncios.
        //    if !adState.isAdFree {
        //        BannerAdView()
        //            .frame(height: 50)
         //   }
          
            if !adState.isAdFree && RemoteConfigManager.shared.showBannerAd {
                 BannerAdView()
                     .frame(height: 50)
             }
            
        }
      
            // 3. AÑADIMOS EL BOTÓN EXTENDIDO (ExtendedFAB) AQUÍ
         //   if !adState.isAdFree {
         //       ExtendedFAB {
         //           self.mostrarAlertaRecompensa = true
         //       }
                // AÑADIMOS LA CONDICIÓN DE REMOTE CONFIG
            if !adState.isAdFree &&
                          RemoteConfigManager.shared.showRewardedAd &&
                          rewardedAdCoordinator.isReady { // <-- LA NUEVA CONDICIÓN
                       ExtendedFAB {
                           self.mostrarAlertaRecompensa = true
                   }
                .padding(.horizontal,30)
                .padding(.bottom, 140)
                .transition(.scale.animation(.spring()))
               
            }
        }
  
        
        .ignoresSafeArea(.keyboard) // Fin del ZStack
        
        .alert(isPresented: $mostrarAlertaRecompensa) {
            Alert(
                title: Text("Versión Premium Gratis"),
                message: Text("Si ves un anuncio corto, obtendrás 4 horas de la aplicación sin publicidad."),
                primaryButton: .default(Text("Aceptar"), action: {
                    rewardedAdCoordinator.showAd()
                }),
                secondaryButton: .cancel(Text("Ahora no"))
            )
        }
        
        //    Está "escuchando" el cambio en la propiedad del coordinador.
        .alert("¡Felicidades!", isPresented: $rewardedAdCoordinator.showAlertAfterReward) {
            Button("¡Genial!", role: .cancel) { }
        } message: {
            Text("Has ganado 4 horas sin publicidad en la app.")
        }
        .onAppear {
            rewardedAdCoordinator.onRewardEarned = {
                adState.grantReward()
            }
            rewardedAdCoordinator.loadAd()
          
        }
        // =================================================================
        // PASO 2: AÑADIMOS EL MODIFICADOR .onAppear PARA EJECUTAR LA LÓGICA
        // =================================================================
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Esta condición se cumplirá cuando la app pase a primer plano.
            // Es el momento perfecto y seguro para ejecutar nuestra lógica.
            if newPhase == .active {
                
                // 👇 AÑADIDO: Cada vez que la app se activa, comprueba el estado de la recompensa.
                adState.updateAdFreeStatus()
                
                // 👇 MODIFICADO: Solo muestra el intersticial si NO estamos en período sin anuncios.
              //  if !adState.isAdFree {
                   // showLaunchAd() //activar el anuncio intersticial************
             //   }
                
                if !adState.isAdFree && RemoteConfigManager.shared.showInterstitialAd {
                         // Comentado temporalmente como pediste, pero aquí es donde va
                          showLaunchAd()
                     }
                
                //Funcion para pedir los permisos
                requestTrackingPermission()
                // Lógica de la reseña
                ReviewManager.shared.trackSession()
            }
        }
        
        
    }
    
    
    // ----- FUNCIONES AUXILIARES -----
    
    private func requestTrackingPermission() {
           // Envolvemos en un DispatchQueue para darle tiempo a la app de estabilizarse
           DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
               ATTrackingManager.requestTrackingAuthorization { status in
                   switch status {
                   case .authorized:
                       // El usuario aceptó. AdMob usará el IDFA.
                       print("ATT: Permiso de seguimiento autorizado.")
                   case .denied:
                       // El usuario denegó. AdMob no usará el IDFA.
                       print("ATT: Permiso de seguimiento denegado.")
                   case .notDetermined:
                       // El sistema aún no ha presentado el diálogo.
                       print("ATT: Permiso de seguimiento no determinado.")
                   case .restricted:
                       // El usuario no puede cambiar esta configuración (ej: control parental).
                       print("ATT: Permiso de seguimiento restringido.")
                   @unknown default:
                       print("ATT: Estado de seguimiento desconocido.")
                   }
               }
           }
       }
    
    // =================================================================
       // PASO 3: AÑADIMOS LA FUNCIÓN QUE CONTROLA EL ANUNCIO
       // =================================================================
    // ESTA ES LA FUNCIÓN CORREGIDA
       private func showLaunchAd() {
           print("La app se ha iniciado. Intentando mostrar un anuncio.")
           
           // ¡SIN CONDICIONES! Simplemente cargamos y mostramos el anuncio.
           // Esto se ejecutará cada vez que la app se inicie.
           adCoordinator.loadAd {
               print("Anuncio cargado, mostrando ahora.")
               adCoordinator.showAd()
           }
       }
    

   
    private func titleForSection(_ section: String) -> String {
        switch section {
        case Constants.DOLARALDIA: return "Calculadora"
        case Constants.PLATAFORMAS: return "Plataformas"
        case Constants.PRECIOBCV: return "Precios Oficiales"
        case Constants.HISTORIA_BCV: return "Historial BCV"
        case Constants.LISTAPMOVILES: return "Pago Móvil"
        default: return "Dolar Al Dia"
        }
    }
    
    func compartirCapturaConTextoYImagen(compartirImagenDePago: Bool) {

        
        var imagenParaCompartir: UIImage?

        if compartirImagenDePago {
            imagenParaCompartir = obtenerImagenUsuarioPredeterminado()
        }

        if imagenParaCompartir == nil {
            if selectedSection == Constants.DOLARALDIA {
                imagenParaCompartir = tomarCapturaDePantalla()
            }
        }
        
        var itemsParaCompartir: [Any] = [self.compartirTexto]
        
        if let imagenFinal = imagenParaCompartir {
            itemsParaCompartir.insert(imagenFinal, at: 0)
        }


        let activityViewController = UIActivityViewController(activityItems: itemsParaCompartir, applicationActivities: nil)
        
        guard let rootViewController = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first(where: { $0.isKeyWindow })?.rootViewController else {
        
            return
        }
        
      
        if let popoverController = activityViewController.popoverPresentationController {
            // Le damos al popover un "ancla" visual. Le decimos que se origine
            // desde la vista principal de la pantalla.
            popoverController.sourceView = rootViewController.view
       
            popoverController.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                                  y: rootViewController.view.bounds.midY,
                                                  width: 0,
                                                  height: 0)
           
            popoverController.permittedArrowDirections = []
        }
        
        rootViewController.present(activityViewController, animated: true, completion: nil)
    }
    
    func tomarCapturaDePantalla(escala: CGFloat = 0.8) -> UIImage? {
      
        guard let ventana = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first(where: { $0.isKeyWindow }) else {
            return nil
        }

        let tamanoOriginal = ventana.bounds.size
        let nuevoTamano = CGSize(
            width: tamanoOriginal.width * escala,
            height: tamanoOriginal.height * escala
        )


        let renderer = UIGraphicsImageRenderer(size: nuevoTamano)


        let imagen = renderer.image { ctx in
      
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
