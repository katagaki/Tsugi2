//
//  CarouselDisplayMode.swift
//  Buses
//
//  Created by 堅書 on 14/4/23.
//

import Foundation

enum CarouselDisplayMode: String {

    func fontSize() -> Double {
        switch self {
        case .full:
            return 24.0
        case .small:
            return 20.0
        case .minimal:
            return 16.0
        }
    }

    func cornerRadius() -> Double {
        switch self {
        case .full:
            return 10.0
        case .small:
            return 8.0
        case .minimal:
            return 6.0
        }
    }

    func width() -> Double {
        switch self {
        case .full:
            return 80.0
        case .small:
            return 72.0
        case .minimal:
            return 56.0
        }
    }

    case full = "Full"
    case small = "Small"
    case minimal = "Minimal"
}
