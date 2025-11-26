//
//  AppInfo.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 11/26/25.
//
// AppInfo.swift (puedes crear un nuevo archivo para esto)

import Foundation

struct AppInfo {
    static var version: String {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return "N/A"
        }
        return version
    }
}
