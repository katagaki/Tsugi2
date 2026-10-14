//
//  Settings.swift
//  Buses
//
//  Created by 堅書 on 9/4/23.
//

import Foundation

/// UserDefaults keys for settings, read in views with `@AppStorage`.
enum SettingsKey {
    static let carouselDisplayMode = "CarouselDisplayMode"
}

enum Settings {

    /// Registered so that code reading UserDefaults directly sees the same defaults as `@AppStorage`.
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            SettingsKey.carouselDisplayMode: CarouselDisplayMode.full.rawValue
        ])
    }

    /// Clears data that may not match the installed version of the app.
    static func performLaunchMaintenance() {
        let defaults = UserDefaults.standard
        let currentVersion = "\(versionNumber).\(buildNumber)"
        if let previousVersion = defaults.string(forKey: "CurrentVersion"), previousVersion != currentVersion {
            log("App was either updated or downgraded! " +
                "Previously detected version was \(previousVersion), current version is \(currentVersion).")
            TransitCache.clear()
        }
        defaults.set(currentVersion, forKey: "CurrentVersion")

        // Bus stops used to be stored in UserDefaults before moving to TransitCache
        defaults.removeObject(forKey: "StoredBusStopList")
        defaults.removeObject(forKey: "StoredBusStopListUpdatedDate")
        // Full bus stop names and routes used to be optional
        defaults.removeObject(forKey: "UseProperText")
        defaults.removeObject(forKey: "ShowRoute")
    }

}
