//
//  NavigationManager.swift
//  Buses
//
//  Created by シンジャスティン on 2023/08/30.
//

import Foundation

class NavigationManager: ObservableObject {

    @Published var nearbyTabPath: [ViewPath] = []
    @Published var favoritesTabPath: [ViewPath] = []
    @Published var notificationsTabPath: [ViewPath] = []
    @Published var directoryTabPath: [ViewPath] = []

    func popToRoot(for tab: TabType) {
        switch tab {
        case .nearby:
            nearbyTabPath.removeAll()
        case .favorites:
            favoritesTabPath.removeAll()
        case .notifications:
            notificationsTabPath.removeAll()
        case .directory:
            directoryTabPath.removeAll()
        }
    }

}
