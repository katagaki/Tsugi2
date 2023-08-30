//
//  TabManager.swift
//  Buses
//
//  Created by シンジャスティン on 2023/08/30.
//

import Foundation

class TabManager: ObservableObject {
    @Published var selectedTab: TabType = .nearby
    @Published var previouslySelectedTab: TabType = .nearby
}
