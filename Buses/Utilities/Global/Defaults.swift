//
//  Defaults.swift
//  Buses
//
//  Created by 堅書 on 9/4/23.
//

import Foundation

let defaults = UserDefaults.standard

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
}
