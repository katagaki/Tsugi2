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
        case .Full:
            return 24.0
        case .Small:
            return 20.0
        case .Minimal:
            return 16.0
        }
    }
    
    func cornerRadius() -> Double {
        switch self {
        case .Full:
            return 10.0
        case .Small:
            return 8.0
        case .Minimal:
            return 6.0
        }
    }
    
    func width() -> Double {
        switch self {
        case .Full:
            return 80.0
        case .Small:
            return 72.0
        case .Minimal:
            return 56.0
        }
    }
    
    case Full = "Full"
    case Small = "Small"
    case Minimal = "Minimal"
}
