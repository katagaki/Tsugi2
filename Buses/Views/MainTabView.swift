//
//  MainTabView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import CoreLocation
import MapKit
import SwiftUI

struct MainTabView: View {

    @Environment(\.scenePhase) var scenePhase

    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var toaster: Toaster

    @State var isInitialLoad: Bool = true

    var body: some View {
        TabView(selection: $tabManager.selectedTab) {
            NearbyView()
                .tabItem {
                    Label("TabTitle.Nearby", systemImage: "location.circle.fill")
                }
                .tag(TabType.nearby)
            FavoritesView()
                .tabItem {
                    Label("TabTitle.Favorites", systemImage: "rectangle.stack.fill")
                }
                .tag(TabType.favorites)
            NotificationsView()
                .tabItem {
                    Label("TabTitle.Notifications", systemImage: "bell.fill")
                }
                .tag(TabType.notifications)
            DirectoryView(updatedDate: $dataManager.updatedDate,
                          updatedTime: $dataManager.updatedTime)
                .tabItem {
                    Label("TabTitle.Directory", systemImage: "magnifyingglass")
                }
                .tag(TabType.directory)
            MoreView()
                .tabItem {
                    Label("TabTitle.More", systemImage: "ellipsis")
                }
                .tag(TabType.more)
        }
        .task {
            if isInitialLoad {
                tabManager.selectedTab = TabType(rawValue: settings.startupTab) ?? .nearby
                await reloadBusStopList()
                isInitialLoad = false
            }
        }
        .onReceive(tabManager.$selectedTab, perform: { newValue in
            if newValue == tabManager.previouslySelectedTab {
                navigationManager.popToRoot(for: newValue)
            }
            tabManager.previouslySelectedTab = newValue
        })
        .onChange(of: dataManager.shouldReloadBusStopList, { _, newValue in
            if newValue {
                Task {
                    await reloadBusStopList(forceServer: true)
                }
            }
        })
        .onChange(of: networkMonitor.isConnected, { _, isConnected in
            if isConnected {
                log("Network connection reappeared!")
                toaster.hideToast()
                Task {
                    log("Retrying fetch of bus stop data.")
                    await reloadBusStopList()
                    toaster.hideToast()
                }
            } else {
                log("Network connection disappeared!")
                toaster.showToast(localized("Shared.Error.InternetConnection"),
                                  type: .persistentError,
                                  hidesAutomatically: false)
            }
        })
        .onChange(of: scenePhase, { _, newPhase in
            switch newPhase {
            case .inactive:
                log("Scene became inactive.")
            case .active:
                log("Scene became active.")
                if locationManager.shouldUpdateLocationAsSoonAsPossible {
                    locationManager.updateLocation(usingOnlySignificantChanges: false)
                    locationManager.shouldUpdateLocationAsSoonAsPossible = false
                }
            case .background:
                log("Scene went into the background.")
                locationManager.shouldUpdateLocationAsSoonAsPossible = true
            @unknown default:
                log("Scene change detected, but we don't know what the change was!")
            }
        })
    }

    func reloadBusStopList(forceServer: Bool = false) async {
        toaster.showToast(localized("Directory.BusStopsLoading"), type: .spinner, hidesAutomatically: false)
        do {
            if dataManager.storedBusStopList() == nil || forceServer {
                try await dataManager.reloadBusStopListFromServer()
                log("Reloaded bus stop data from server.")
            } else {
                if let storedBusStopList = dataManager.storedBusStopList(),
                   let storedBusStopListUpdatedDate = dataManager.storedBusStopListUpdatedDate() {
                    try await dataManager.reloadBusStopListFromStoredMemory(storedBusStopList,
                                                                            updatedAt: storedBusStopListUpdatedDate)
                    log("Reloaded bus stop data from memory.")
                }
            }
            toaster.hideToast()
        } catch {
            log(error.localizedDescription)
            log("WARNING×WARNING×WARNING\nNetwork does not look like it's working, bus stop data may be incomplete!")
            toaster.showToast(localized("Shared.Error.InternetConnection"),
                              type: .persistentError,
                              hidesAutomatically: false)
        }
    }

    func reloadBusRouteList() async {
        do {
            try await dataManager.reloadBusRoutesFromServer()
            log("Reloaded bus route data from server.")
        } catch {
            log(error.localizedDescription)
            toaster.showToast(localized("Shared.Error.InternetConnection"),
                              type: .persistentError,
                              hidesAutomatically: false)
        }
    }

}
