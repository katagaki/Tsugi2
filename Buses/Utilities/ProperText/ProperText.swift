//
//  ProperText.swift
//  Buses
//
//  Created by 堅書 on 9/4/23.
//

import Foundation

var ptTerms:[String:String] = [:]
var ptCapitalization:[String:String] = [:]

func initializeProperTextFramework() {
    if let storedTerms = plist(named: "PTTerms") {
        ptTerms = storedTerms
    }
    if let storedCapitalization = plist(named: "PTCapitalization") {
        ptCapitalization = storedCapitalization
    }
    log("Loaded ProperText framework with \(ptTerms.count) acronym definitions, and \(ptCapitalization.count) capitalization definitions.")
}

func properName(for originalString: String) -> String {
    var ptString: String = originalString.capitalized
    for term in ptTerms.keys {
        if ptString.localizedCaseInsensitiveContains(term) {
            ptString = ptString.replacingOccurrences(of: "(?i)\\b\(term)\\b", with: ptTerms[term]!,
                                                     options: .regularExpression)
        }
    }
    for term in ptCapitalization.keys {
        if ptString.localizedCaseInsensitiveContains(term) {
            ptString = ptString.replacingOccurrences(of: "(?i)\\b\(term)\\b", with: ptCapitalization[term]!,
                                                     options: .regularExpression)
        }
    }
    return ptString
}
