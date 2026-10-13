//
//  TabManager.swift
//  Buses
//
//  Created by シンジャスティン on 2023/08/30.
//

import Foundation
import Observation

@Observable
class TabManager {
    var selectedTab: TabType {
        didSet {
            UserDefaults.standard.set(selectedTab.rawValue, forKey: "SelectedTab")
        }
    }
    var previouslySelectedTab: TabType = .nearby

    init() {
        let saved = UserDefaults.standard.integer(forKey: "SelectedTab")
        let tab = TabType(rawValue: saved) ?? .nearby
        self.selectedTab = tab
        self.previouslySelectedTab = tab
    }
}
