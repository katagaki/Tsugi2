//
//  BundleUtilities.swift
//  Buses
//
//  Created by 堅書 on 9/4/23.
//

import Foundation

func plist(named filename: String) -> [String: String]? {
    let filename = filename.replacingOccurrences(of: ".plist", with: "")
    if let path = Bundle.main.path(forResource: filename, ofType: "plist") {
        return NSDictionary(contentsOfFile: path)! as? [String : String]
    } else {
        return nil
    }
}
