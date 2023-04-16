//
//  ProperText.swift
//  Buses
//
//  Created by 堅書 on 9/4/23.
//

import Foundation

var ptTerms: [String: String] = [:]
var ptCapitalization: [String: String] = [:]
var ptReplace: [String: String] = [:]

func initializeProperTextFramework() {
    if let storedTerms = Bundle.main.plist(named: "PTTerms") {
        ptTerms = storedTerms
    }
    if let storedCapitalization = Bundle.main.plist(named: "PTCapitalization") {
        ptCapitalization = storedCapitalization
    }
    if let storedReplacements = Bundle.main.plist(named: "PTReplace") {
        ptReplace = storedReplacements
    }
    log("Loaded ProperText framework with \(ptTerms.count) abbreviation definitions, " +
        "\(ptCapitalization.count) capitalization definitions, and \(ptReplace.count) replacement definitions.")
}

func properName(for originalString: String) -> String {
    var ptString: String = originalString.uppercased()

    // Replace tokens in bus stop names
    var ptStringTokens: [String] = ptString.components(separatedBy: .whitespaces)
    for ptStringTokenIndex in 0..<ptStringTokens.count {
        if let term = ptTerms[ptStringTokens[ptStringTokenIndex]] {
            ptStringTokens[ptStringTokenIndex] = term
            continue
        }
        var ptSpecialTokens: [String] = ptStringTokens[ptStringTokenIndex].components(separatedBy: "/")
        if ptSpecialTokens.count > 1 {
            for ptSpecialTokenIndex in 0..<ptSpecialTokens.count {
                if let term = ptTerms[ptSpecialTokens[ptSpecialTokenIndex]] {
                    ptSpecialTokens[ptSpecialTokenIndex] = term
                    continue
                }
            }
            ptStringTokens[ptStringTokenIndex] = ptSpecialTokens.joined(separator: "/")
        }
    }
    ptString = ptStringTokens.joined(separator: " ")

    // Revert capitalization where inappropriate
    ptString = ptString.localizedCapitalized
    for term in ptCapitalization.keys where ptString.localizedCaseInsensitiveContains(term) {
        ptString = ptString.replacingOccurrences(of: "(?i)\\b\(term)\\b",
                                                 with: ptCapitalization[term]!,
                                                 options: .regularExpression)
    }

    // Replace special terms
    for term in ptReplace.keys where ptString.localizedCaseInsensitiveContains(term) {
        ptString = ptString.replacingOccurrences(of: term,
                                                 with: ptReplace[term]!,
                                                 options: .caseInsensitive)
    }

    return ptString
}
