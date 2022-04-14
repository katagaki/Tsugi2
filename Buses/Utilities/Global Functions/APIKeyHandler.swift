//
//  APIKeyHandler.swift
//  Buses
//
//  Created by 堅書 on 2022/04/14.
//

import Foundation

var apiKeys:[String:String] = [:]

func loadAPIKeys() {
    if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") {
        for (key, value) in NSDictionary(contentsOfFile: path)! {
            apiKeys[key as! String] = (value as! String)
        }
        log("Loaded \(apiKeys.count) API key(s).")
    } else {
        log("Could not load API keys.", level: .error)
    }
}
