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

    /// Set once the navigation stack is on screen. Paths pushed before then are not shown.
    @ObservationIgnored var isStackReady = false
    @ObservationIgnored private var pendingPath: ViewPath?

    func popToRoot() {
        mainPath.removeAll()
    }

    func push(_ viewPath: ViewPath) {
        mainPath.append(viewPath)
    }

    /// Shows a view from outside the app, such as a widget, waiting for the stack to appear if needed.
    func open(_ viewPath: ViewPath) {
        if isStackReady {
            popToRoot()
            push(viewPath)
        } else {
            pendingPath = viewPath
        }
    }

    func stackDidAppear() {
        isStackReady = true
        if let pendingPath {
            self.pendingPath = nil
            open(pendingPath)
        }
    }

}
