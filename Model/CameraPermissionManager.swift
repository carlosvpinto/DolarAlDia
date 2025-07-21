//
//  CameraPermissionManager.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 7/4/25.
//
import AVFoundation
import SwiftUI

class CameraPermissionManager: ObservableObject {
    @Published var permissionGranted = false
    @Published var permissionDenied = false

    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.permissionGranted = granted
                self.permissionDenied = !granted
            }
        }
    }

    func checkPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        case .denied, .restricted:
            permissionGranted = false
            permissionDenied = true
        @unknown default:
            permissionGranted = false
        }
    }
}

