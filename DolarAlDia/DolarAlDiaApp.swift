import SwiftUI
import GoogleMobileAds
import Firebase
import FirebaseMessaging

// 👇 1. AÑADE 'MessagingDelegate' A LA LISTA DE PROTOCOLOS
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      
      // Configuración en el orden correcto
      FirebaseApp.configure()
      MobileAds.shared.start(completionHandler: nil)
      
      // 👇 2. ASIGNA EL DELEGADO DE FIREBASE MESSAGING
      //    Esto le dice a Firebase que esta clase gestionará los eventos del token.
      Messaging.messaging().delegate = self
      
      // La llamada a fetchConfig() se hace en la UI, por lo que aquí está correctamente comentada.
      // RemoteConfigManager.shared.fetchConfig()
      
      requestAuthorizationForPushNotification(application: application)

      return true
  }

  // 👇 3. AÑADE ESTA FUNCIÓN OBLIGATORIA DEL DELEGADO
  /// Esta función se llama automáticamente cada vez que el token de FCM se crea por primera vez
  /// o cuando se actualiza. Es el lugar perfecto para obtener el token.
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      guard let token = fcmToken else {
          print("⚠️ El token de FCM es nulo.")
          return
      }
      
      print("🔔 ¡Token de FCM obtenido/actualizado!: \(token)")
      
      // TODO: Aquí es donde deberías enviar este 'token' a tu backend/servidor
      // para asociarlo con el usuario actual y poder enviarle notificaciones.
      // Ejemplo: sendTokenToServer(token)
  }

    // MARK: - Métodos de Notificaciones (Tu código original, está perfecto)
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler([.banner, .sound])
     }
     
     func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
         completionHandler()
     }
    
    private func requestAuthorizationForPushNotification(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           Messaging.messaging().apnsToken = deviceToken
       }
}

import SwiftUI
import GoogleMobileAds

@main
struct DolarAlDiaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Tu lógica de actualización forzada (está perfecta)
    @StateObject private var versionManager = VersionCheckManager()

    // Tus otras propiedades de estado (están perfectas)
    @StateObject private var userSession = UserSession()
    @StateObject private var adState = AdState()
    
    init() { }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSession)
                .environmentObject(adState)
                
            // Tu lógica de comprobación de versión (está perfecta)
            .onAppear {
                RemoteConfigManager.shared.fetchConfig {
                    versionManager.checkAppVersion()
                }
            }
            .fullScreenCover(isPresented: $versionManager.needsUpdate) {
                ForceUpdateView(updateURL: versionManager.appStoreURL)
            }
        }
    }
}
