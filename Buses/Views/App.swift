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

    @State var tabManager = TabManager()
    @State var navigationManager = NavigationManager()
    @State var networkMonitor = NetworkMonitor()
    @State var dataManager = DataManager()
    @State var favorites = FavoritesManager()
    @State var regionManager = RegionManager()
    @State var coordinateManager = CoordinateManager()
    @State var locationManager = LocationManager()
    @State var settings = SettingsManager()
    @State var toaster = Toaster()

    init() {
        // Launch arguments only reach the app, so pass the mock data flag on to the extension
        UserDefaults.shared.set(UserDefaults.standard.bool(forKey: "UseMockData"), forKey: "UseMockData")
    }

    var body: some Scene {
        WindowGroup {
            KatsuView()
                .onAppear {
                    initializeProperTextFramework()
                }
                .environment(tabManager)
                .environment(navigationManager)
                .environment(networkMonitor)
                .environment(dataManager)
                .environment(favorites)
                .environment(regionManager)
                .environment(coordinateManager)
                .environment(locationManager)
                .environment(settings)
                .environment(toaster)
        }
    }
}
