//
//  Logging.swift
//  Buses
//
//  Created by 堅書 on 2022/04/14.
//

import Foundation
import os

let loggingQueue = DispatchQueue(label: "log", attributes: .concurrent)
let versionNumber: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "Dev"
let buildNumber: String = Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? "Dev"
var appLogs: String = "Buses 2 (version \(versionNumber), build \(buildNumber))"

public func log(_ text: String, level: OSLogType = .info) {
    let dateString = String(Date().timeIntervalSince1970).components(separatedBy: ".")[0]
    loggingQueue.async(flags: .barrier) {
        appLogs.append(contentsOf: "\n[\(dateString)] \(text)")
        os_log("%s", log: .default, type: level, text)
    }
}
