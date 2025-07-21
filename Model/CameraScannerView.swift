//
//  CameraScannerView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 7/4/25.
//

// En CameraScannerView.swift
import SwiftUI
import VisionKit

struct CameraScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void
    @Environment(\.dismiss) var dismiss // Para descartar la vista

    // Agrega un inicializador que devuelva nil si no es compatible
    // NOTA: UIViewControllerRepresentable no puede devolver nil directamente en makeUIViewController.
    // La mejor forma es manejarlo en la vista padre (TextFieldPersonal)
    // o devolver una UIViewController que muestre un mensaje de error.

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan, dismissAction: dismiss)
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        // **IMPORTANTE:** Realiza la comprobación de compatibilidad aquí
        guard DataScannerViewController.isSupported && DataScannerViewController.isAvailable else {
            // Si no es compatible, devuelve una vista de controlador de vista simple que muestre un mensaje
            let vc = UIViewController()
            let label = UILabel()
            label.text = "Escáner no disponible o dispositivo no compatible (requiere iOS 16+ y A12 Bionic+)."
            label.numberOfLines = 0
            label.textAlignment = .center
            vc.view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20)
            ])
            return vc as! DataScannerViewController // Devuelve este VC de error
        }

        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // Solo intenta iniciar el escaneo si realmente es un DataScannerViewController
        if let scanner = uiViewController as? DataScannerViewController {
            Task {
                do {
                    try await scanner.startScanning() // Usa await si es posible
                } catch {
                    print("Error al iniciar el escaneo: \(error.localizedDescription)")
                    // Podrías pasar este error a la vista principal si quieres.
                }
            }
        }
    }

    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        if let scanner = uiViewController as? DataScannerViewController {
            scanner.stopScanning()
        }
    }

    // ... (Tu clase Coordinator permanece igual)
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var onScan: (String) -> Void
        var dismissAction: DismissAction

        init(onScan: @escaping (String) -> Void, dismissAction: DismissAction) {
            self.onScan = onScan
            self.dismissAction = dismissAction
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd items: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in items {
                if case let .text(text) = item {
                    if let match = text.transcript.range(of: "\\d+", options: .regularExpression) {
                        let number = String(text.transcript[match])
                        onScan(number)
                        dataScanner.stopScanning()
                        dismissAction() // Usa dismissAction para cerrar la sheet
                        return // Salir después de encontrar el primer número
                    }
                }
            }
        }
        // ... (otros métodos delegados opcionales)
    }
}
