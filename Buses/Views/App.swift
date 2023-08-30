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

    @StateObject var tabManager = TabManager()
    @StateObject var navigationManager = NavigationManager()
    @StateObject var networkMonitor = NetworkMonitor()
    @StateObject var dataManager = DataManager()
    @StateObject var favorites = FavoritesManager()
    @StateObject var regionManager = RegionManager()
    @StateObject var coordinateManager = CoordinateManager()
    @StateObject var locationManager = LocationManager()
    @StateObject var settings = SettingsManager()
    @StateObject var toaster = Toaster()

    var body: some Scene {
        WindowGroup {
            KatsuView()
                .onAppear {
                    loadAPIKeys()
                    initializeProperTextFramework()
                }
                .environmentObject(tabManager)
                .environmentObject(navigationManager)
                .environmentObject(networkMonitor)
                .environmentObject(dataManager)
                .environmentObject(favorites)
                .environmentObject(regionManager)
                .environmentObject(coordinateManager)
                .environmentObject(locationManager)
                .environmentObject(settings)
                .environmentObject(toaster)
        }
    }
}
