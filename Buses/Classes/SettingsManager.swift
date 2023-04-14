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
    @Published var carouselDisplayMode: CarouselDisplayMode = .Full
    @Published var carouselDisplayModeIsFull: Bool = true
    @Published var carouselDisplayModeIsSmall: Bool = false
    @Published var carouselDisplayModeIsMinimal: Bool = false
    
    func initializeDefaultConfiguration() {
        // Detect if version changed
        if defaults.value(forKey: "CurrentVersion") != nil,
           let previouslyDetectedVersion = defaults.string(forKey: "CurrentVersion"),
           previouslyDetectedVersion != "\(versionNumber).\(buildNumber)" {
            log("App was either updated or downgraded! Previously detected version was \(previouslyDetectedVersion), current version is \(versionNumber).\(buildNumber).")
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
        
        // Load configuration into global variables
        startupTab = defaults.integer(forKey: "StartupTab")
        useProperText = defaults.bool(forKey: "UseProperText")
        carouselDisplayMode = CarouselDisplayMode(rawValue: defaults.string(forKey: "CarouselDisplayMode") ?? "Full") ?? .Full
        carouselDisplayModeIsFull = carouselDisplayMode == .Full
        carouselDisplayModeIsSmall = carouselDisplayMode == .Small
        carouselDisplayModeIsMinimal = carouselDisplayMode == .Minimal
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
        carouselDisplayModeIsFull = newValue == .Full
        carouselDisplayModeIsSmall = newValue == .Small
        carouselDisplayModeIsMinimal = newValue == .Minimal
    }
    
    func setStoredBusStopList(_ newValue: BusStopList) {
        defaults.set(encode(newValue), forKey: "StoredBusStopList")
    }
    
    func setStoredBsuStopListUpdatedDate(_ newValue: Date) {
        defaults.set(newValue, forKey: "StoredBusStopListUpdatedDate")
    }
    
    func storedBusStopList() -> String? {
        return defaults.string(forKey: "StoredBusStopList")
    }
    
    func storedBusStopListUpdatedDate() -> Date? {
        return defaults.object(forKey: "StoredBusStopListUpdatedDate") as? Date
    }
    
}
