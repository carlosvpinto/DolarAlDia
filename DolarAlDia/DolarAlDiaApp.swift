//
//  DolarAlDiaApp.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/1/24.
//

import SwiftUI
import GoogleMobileAds
import Firebase
import FirebaseMessaging




class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

  func application(_ application: UIApplication,

                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      
    
          // --- FIN DEL CÓDIGO DE DIAGNÓSTICO ---

      //Configuracion Firebase
      FirebaseApp.configure()
    //  MobileAds.shared.start(completionHandler: nil)
      RemoteConfigManager.shared.fetchConfig()
      requestAuthorizationForPushNotification(application: application)
      //ReviewManager.shared.trackSession()

    return true

  }
    //FUNCION PARA RECIBIR NOTIFICACIONES PUSH ***********
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler([.banner, .sound])
     }
     
     func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
         completionHandler()
     }
    //*****************************************************
    
    //AUTORIZACION AL USARIO A RECIBIR NOTIFICACIONES**********
    private func requestAuthorizationForPushNotification(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           Messaging.messaging().apnsToken = deviceToken
       }
    //********************************************************
}
import SwiftUI
import GoogleMobileAds
@main

struct DolarAlDiaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    init() {
      //  MobileAds.shared.start(completionHandler: nil)
       }
    @StateObject private var userSession = UserSession()
    
    // 👇 AÑADIDO: Crea una única instancia del gestor de estado.
       @StateObject private var adState = AdState()
    var body: some Scene {
        WindowGroup {
          //  MenuView()
          //  DolarAlDiaView()
            ContentView()
                .environmentObject(userSession)
            // 👇 Inyecta el gestor de estado en el entorno de la app.
                .environmentObject(adState)
        }
    }
}
