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

extension String {
    
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
            for searchTermToken in searchTermTokens {
                if searchTargetToken.contains(searchTermToken) {
                    numberOfTokensMatched += 1
                }
            }
        }
        return numberOfTokensMatched >= searchTermTokens.count
    }

}
