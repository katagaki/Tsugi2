//
//  App.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import BackgroundTasks
import SwiftUI

@main
struct TsugiApp: App {
    
    @StateObject var networkMonitor = NetworkMonitor()
    @StateObject var busStopList = BusStopList()
    @StateObject var favorites = FavoriteList()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(updatedDate: "", updatedTime: "")
                .onAppear {
                    loadAPIKeys()
                }
                .environmentObject(networkMonitor)
                .environmentObject(busStopList)
                .environmentObject(favorites)
        }
    }
}
