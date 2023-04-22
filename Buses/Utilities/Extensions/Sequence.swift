//
//  Sequence.swift
//  Buses
//
//  Created by 堅書 on 16/4/23.
//

import Foundation

extension Sequence where Element: Hashable {
    func isDistinct() -> Bool {
        var set = Set<Element>()
        for element in self where !set.insert(element).inserted {
            return false
        }
        return true
    }
}
