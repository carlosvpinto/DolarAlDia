//
//  DolarAlDiaApp.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/1/24.
//

import SwiftUI

import Firebase
import FirebaseMessaging


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

  func application(_ application: UIApplication,

                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    FirebaseApp.configure()
      requestAuthorizationForPushNotification(application: application)

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


@main
struct DolarAlDiaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
          //  MenuView()
          //  DolarAlDiaView()
            ContentView()
        }
    }
}
