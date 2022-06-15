//
//  StringUtilities.swift
//  Buses
//
//  Created by 堅書 on 2022/04/11.
//

import Foundation

func localized(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

func intFrom(_ string: String) -> Int? {
    let digitComponents = string.components(separatedBy: .letters)
    let digits = digitComponents.joined()
    print(digits)
    return Int(digits)
}
