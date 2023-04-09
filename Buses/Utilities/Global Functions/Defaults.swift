//
//  Defaults.swift
//  Buses
//
//  Created by 堅書 on 9/4/23.
//

import Foundation

let defaults = UserDefaults.standard

func initializeDefaultConfiguration() {
    if defaults.value(forKey: "CurrentVersion") == nil {
        defaults.setValue("\(versionNumber).\(buildNumber)", forKey: "CurrentVersion")
    } else {
        if let previouslyDetectedVersion = defaults.string(forKey: "CurrentVersion") {
            if previouslyDetectedVersion != "\(versionNumber).\(buildNumber)" {
                log("App was either updated or downgraded! Previously detected version was \(previouslyDetectedVersion), current version is \(versionNumber).\(buildNumber).")
                // Perform future schema/data updates here
            }
        }
    }
    if defaults.value(forKey: "StartupTab") == nil {
        defaults.set(0, forKey: "StartupTab")
    }
    if defaults.value(forKey: "UseProperText") == nil {
        defaults.setValue(true, forKey: "UseProperText")
    }
}
