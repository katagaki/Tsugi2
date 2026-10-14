//
//  App.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import AppIntents
import BackgroundTasks
import SwiftUI
import UserNotifications

@main
struct TsugiApp: App {

    @State var tabManager = TabManager()
    @State var navigationManager: NavigationManager
    @State var networkMonitor = NetworkMonitor()
    @State var dataManager = DataManager()
    @State var favorites = FavoritesManager()
    @State var regionManager = RegionManager()
    @State var coordinateManager = CoordinateManager()
    @State var locationManager = LocationManager()
    @State var toaster = Toaster()

    @State var notificationHandler: NotificationHandler

    @Environment(\.scenePhase) var scenePhase

    init() {
        Settings.registerDefaults()
        Settings.performLaunchMaintenance()
        let navigationManager = NavigationManager()
        _navigationManager = State(initialValue: navigationManager)
        // Lets intents that open the app navigate to what they show
        AppDependencyManager.shared.add { navigationManager }
        // Must be set before launch finishes to receive the notification that launched the app
        let notificationHandler = NotificationHandler(navigationManager: navigationManager)
        _notificationHandler = State(initialValue: notificationHandler)
        UNUserNotificationCenter.current().delegate = notificationHandler
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
