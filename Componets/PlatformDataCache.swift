//
//  PlatformDataCache.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 8/13/25.
//
import Foundation

// Usamos el mismo modelo MonitorDetail que ya tienes en ApiNetwork.
// Esto es eficiente porque no necesitamos duplicar código.
typealias PlatformDetail = ApiNetwork.MonitorDetail

struct PlatformDataCache: Codable {
    let binanceRate: PlatformDetail?
    let bybitRate: PlatformDetail?
    let yadioRate: PlatformDetail?
    let timestamp: Date
}
