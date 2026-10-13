//
//  NavigationManager.swift
//  Buses
//
//  Created by シンジャスティン on 2023/08/30.
//

import Foundation
import Observation

@Observable
class NavigationManager {

    var mainPath: [ViewPath] = []

    func popToRoot() {
        mainPath.removeAll()
    }

    func push(_ viewPath: ViewPath) {
        mainPath.append(viewPath)
    }

}
