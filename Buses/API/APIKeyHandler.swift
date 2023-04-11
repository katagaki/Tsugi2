//
//  APIKeyHandler.swift
//  Buses
//
//  Created by 堅書 on 2022/04/14.
//

import Foundation

var apiKeys:[String:String] = [:]

func loadAPIKeys() {
    if let storedAPIKeys = Bundle.main.plist(named: "APIKeys") {
        apiKeys = storedAPIKeys
        log("Loaded \(apiKeys.count) API key(s).")
    } else {
        log("Could not load API keys.", level: .error)
    }
}
