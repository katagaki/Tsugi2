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

    func similarTo(_ string: String) -> Bool {
        let searchTermTokens = string.lowercased().components(separatedBy: .whitespaces)
        let searchTargetTokens = self.lowercased().components(separatedBy: .whitespaces)
        var numberOfTokensMatched: Int = 0
        for searchTargetToken in searchTargetTokens {
            for searchTermToken in searchTermTokens where searchTargetToken.contains(searchTermToken) {
                numberOfTokensMatched += 1
            }
        }
        return numberOfTokensMatched >= searchTermTokens.count
    }

}
