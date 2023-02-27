//
//  App.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import ActivityKit
import BackgroundTasks
import SwiftUI

@main
struct TsugiApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView(updatedDate: "", updatedTime: "")
                .onAppear {
                    loadAPIKeys()
                }
                .environmentObject(BusStopList())
                .environmentObject(CoordinateList())
                .environmentObject(FavoriteList())
        }
    }
}
