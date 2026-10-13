//
//  AppGroup.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import Foundation

enum AppGroup {

    static let identifier = "group.com.tsubuzaki.Tsugi2"

    static var containerURL: URL {
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) {
            return url
        }
        log("App Group container is unavailable, falling back to Application Support.", level: .error)
        return URL.applicationSupportDirectory
    }

    static var cachesURL: URL {
        let url = containerURL.appending(path: "Library/Caches", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

}

extension UserDefaults {
    static let shared: UserDefaults = UserDefaults(suiteName: AppGroup.identifier) ?? .standard
}
