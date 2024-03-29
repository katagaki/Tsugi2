//
//  SettingsManager.swift
//  Buses
//
//  Created by 堅書 on 9/4/23.
//

import Foundation

class SettingsManager: ObservableObject {

    let defaults = UserDefaults.standard

    @Published var startupTab: Int = 0
    @Published var useProperText: Bool = true
    @Published var carouselDisplayMode: CarouselDisplayMode = .full
    @Published var carouselDisplayModeIsFull: Bool = true
    @Published var carouselDisplayModeIsSmall: Bool = false
    @Published var carouselDisplayModeIsMinimal: Bool = false
    @Published var showRoute: Bool = false

    init() {
        // Detect if version changed
        if defaults.value(forKey: "CurrentVersion") != nil,
           let previouslyDetectedVersion = defaults.string(forKey: "CurrentVersion"),
           previouslyDetectedVersion != "\(versionNumber).\(buildNumber)" {
            log("App was either updated or downgraded! " +
                "Previously detected version was \(previouslyDetectedVersion), " +
                "current version is \(versionNumber).\(buildNumber).")
            defaults.set(nil, forKey: "StoredBusStopList")
        }
        defaults.setValue("\(versionNumber).\(buildNumber)", forKey: "CurrentVersion")

        // Set default settings
        if defaults.value(forKey: "StartupTab") == nil {
            defaults.set(0, forKey: "StartupTab")
        }
        if defaults.value(forKey: "UseProperText") == nil {
            defaults.setValue(true, forKey: "UseProperText")
        }
        if defaults.value(forKey: "CarouselDisplayMode") == nil {
            defaults.setValue("Full", forKey: "CarouselDisplayMode")
        }
        if defaults.value(forKey: "ShowRoute") == nil {
            defaults.setValue(false, forKey: "ShowRoute")
        }

        // Load configuration into global variables
        startupTab = defaults.integer(forKey: "StartupTab")
        useProperText = defaults.bool(forKey: "UseProperText")
        carouselDisplayMode = CarouselDisplayMode(
            rawValue: defaults.string(forKey: "CarouselDisplayMode") ?? "Full") ?? .full
        carouselDisplayModeIsFull = carouselDisplayMode == .full
        carouselDisplayModeIsSmall = carouselDisplayMode == .small
        carouselDisplayModeIsMinimal = carouselDisplayMode == .minimal
        showRoute = defaults.bool(forKey: "ShowRoute")
    }

    func set(_ value: Any?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func setStartupTab(_ newValue: Int) {
        defaults.set(newValue, forKey: "StartupTab")
        startupTab = newValue
    }

    func setProperText(_ newValue: Bool) {
        defaults.set(newValue, forKey: "UseProperText")
        useProperText = newValue
    }

    func setCarouselDisplayMode(_ newValue: CarouselDisplayMode) {
        defaults.set(newValue.rawValue, forKey: "CarouselDisplayMode")
        carouselDisplayMode = newValue
        carouselDisplayModeIsFull = newValue == .full
        carouselDisplayModeIsSmall = newValue == .small
        carouselDisplayModeIsMinimal = newValue == .minimal
    }

    func setShowRoute(_ newValue: Bool) {
        defaults.set(newValue, forKey: "ShowRoute")
        showRoute = newValue
    }

}
