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
    @StateObject var dataManager = DataManager()
    @StateObject var favorites = FavoritesManager()
    @StateObject var regionManager = MapRegionManager()
    @StateObject var locationManager = LocationManager()
    @StateObject var settings = SettingsManager()
    @StateObject var toaster = Toaster()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    loadAPIKeys()
                    initializeProperTextFramework()
                }
                .environmentObject(networkMonitor)
                .environmentObject(dataManager)
                .environmentObject(favorites)
                .environmentObject(regionManager)
                .environmentObject(locationManager)
                .environmentObject(settings)
                .environmentObject(toaster)
        }
    }
}
