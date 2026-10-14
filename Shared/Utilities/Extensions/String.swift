//
//  String.swift
//  Buses
//
//  Created by 堅書 on 2022/04/11.
//

import Foundation

func localized(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

func localized(_ key: String, replacing replacements: String...) -> String {
    var string = NSLocalizedString(key, comment: "")
    for index in 0..<replacements.count {
        string = string.replacingOccurrences(of: "%\(index + 1)", with: replacements[index])
    }
    return string
}

extension String {

    func toDateFromISO8601() -> Date? {
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: self)
    }

    func toInt() -> Int? {
        let digitComponents = self.components(separatedBy: .letters)
        let digits = digitComponents.joined()
        return Int(digits)
    }

    /// Whether every word in the search term is part of a word in this string.
    func similarTo(_ string: String) -> Bool {
        let searchTermTokens = string.lowercased().components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        let searchTargetTokens = self.lowercased().components(separatedBy: .whitespaces)
        return searchTermTokens.allSatisfy { searchTermToken in
            searchTargetTokens.contains { $0.contains(searchTermToken) }
        }
    }

}
