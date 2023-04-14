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
    @StateObject var regionManager = MapRegionManager()
    @StateObject var locationManager = LocationManager()
    @StateObject var shouldReloadBusStopList = BoolState()
    @StateObject var settings = SettingsManager()
    @StateObject var toaster = Toaster()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(updatedDate: "", updatedTime: "")
                .onAppear {
                    settings.initializeDefaultConfiguration()
                    loadAPIKeys()
                    initializeProperTextFramework()
                }
                .environmentObject(networkMonitor)
                .environmentObject(busStopList)
                .environmentObject(favorites)
                .environmentObject(regionManager)
                .environmentObject(locationManager)
                .environmentObject(shouldReloadBusStopList)
                .environmentObject(settings)
                .environmentObject(toaster)
        }
    }
}
