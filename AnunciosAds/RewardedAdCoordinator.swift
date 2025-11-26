//
//  RewardedAdCoordinator.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 10/14/25.
//
// RewardedAdCoordinator.swift
// En RewardedAdCoordinator.swift

import Foundation
import GoogleMobileAds
import Combine

class RewardedAdCoordinator: NSObject, FullScreenContentDelegate, ObservableObject {
    
    static let shared = RewardedAdCoordinator()
    
    private var rewardedAd: RewardedAd?
    var onRewardEarned: (() -> Void)?
    
    @Published var isReady: Bool = false
    @Published var showAlertAfterReward = false
    
    override private init() { }
    
    func loadAd() {
        guard rewardedAd == nil else { return }
        
        let request = Request()
        
        RewardedAd.load(with: Constants.adUnitIDRewardedVideo, request: request) { ad, error in
            if let error = error {
                print("❌ Anuncio recompensado no se pudo cargar: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isReady = false
                }
                return
            }
            
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            
            DispatchQueue.main.async {
                print("✅ Anuncio recompensado CARGADO y LISTO.")
                self.isReady = true
            }
        }
    }
    
    func showAd() {
        guard let ad = rewardedAd else {
            print("⚠️ Se intentó mostrar un anuncio recompensado que no estaba listo.")
            self.isReady = false
            self.loadAd()
            return
        }

        guard let root = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first?.windows.first?.rootViewController else {
            return
        }
        
        ad.present(from: root) {
            let reward = ad.adReward
            print("🎁 Recompensa obtenida: \(reward.amount) \(reward.type)")
            self.onRewardEarned?()
            
            //Dispara la señal de recompensa Optenida
            DispatchQueue.main.async {
                self.showAlertAfterReward = true
            }
        }
    }
    
    // MARK: - GADFullScreenContentDelegate Methods
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("👀 Anuncio recompensado se va a mostrar.")
        DispatchQueue.main.async {
            self.isReady = false
        }
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Anuncio recompensado falló al mostrarse: \(error.localizedDescription)")
        self.rewardedAd = nil
        self.loadAd()
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("👋 Anuncio recompensado fue cerrado.")
        self.rewardedAd = nil
        self.loadAd()
    }
}
