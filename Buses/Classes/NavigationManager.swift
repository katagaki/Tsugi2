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
    @Published var moreTabPath: [ViewPath] = []

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
        case .more:
            moreTabPath.removeAll()
        }
    }

    func push(_ viewPath: ViewPath, for tab: TabType) {
        switch tab {
        case .nearby:
            nearbyTabPath.append(viewPath)
        case .favorites:
            favoritesTabPath.append(viewPath)
        case .notifications:
            notificationsTabPath.append(viewPath)
        case .directory:
            directoryTabPath.append(viewPath)
        case .more:
            moreTabPath.append(viewPath)
        }
    }

}
