//
//  App.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import AppIntents
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

    @Environment(\.scenePhase) var scenePhase

    init() {
        // Lets intents that open the app navigate to what they show
        let navigationManager = navigationManager
        AppDependencyManager.shared.add { navigationManager }
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
                .task(id: scenePhase) {
                    if scenePhase == .active {
                        await ArrivalActivityController.refreshWhileActive()
                    } else if scenePhase == .background {
                        ArrivalActivityController.scheduleBackgroundRefresh()
                    }
                }
        }
        .backgroundTask(.appRefresh(ArrivalActivityController.refreshTaskIdentifier)) {
            await ArrivalActivityController.handleBackgroundRefresh()
        }
    }
}
