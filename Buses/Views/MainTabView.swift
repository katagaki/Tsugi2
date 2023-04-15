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
    
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var regionManager: MapRegionManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var toaster: Toaster
    
    @State var defaultTab: Int = 0
    
    @State var isInitialLoad: Bool = true
    
    var body: some View {
        GeometryReader { metrics in
            TabView(selection: $defaultTab) {
                NearbyView()
                    .tabItem {
                        Label("TabTitle.Nearby", systemImage: "location.circle.fill")
                    }
                    .tag(0)
                FavoritesView()
                    .tabItem {
                        Label("TabTitle.Favorites", systemImage: "rectangle.stack.fill")
                    }
                    .tag(1)
                NotificationsView()
                    .tabItem {
                        Label("TabTitle.Notifications", systemImage: "bell.fill")
                    }
                    .tag(2)
                DirectoryView(updatedDate: $dataManager.updatedDate,
                              updatedTime: $dataManager.updatedTime)
                    .tabItem {
                        Label("TabTitle.Directory", systemImage: "magnifyingglass")
                    }
                    .tag(3)
                MoreView()
                    .tabItem {
                        Label("TabTitle.More", systemImage: "ellipsis")
                    }
                    .tag(4)
            }
            .task {
                if isInitialLoad {
                    defaultTab = settings.startupTab
                    await reloadBusStopList()
                    isInitialLoad = false
                }
            }
            .onChange(of: dataManager.shouldReloadBusStopList, perform: { newValue in
                if newValue {
                    Task {
                        await reloadBusStopList(forceServer: true)
                    }
                }
            })
            .onChange(of: networkMonitor.isConnected) { isConnected in
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
                    toaster.showToast(localized("Shared.Error.InternetConnection"), type: .PersistentError, hidesAutomatically: false)
                }
            }
            .onChange(of: scenePhase, perform: { newPhase in
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
            .overlay {
                    ZStack(alignment: .bottom) {
                        if toaster.isToastShowing {
                            ToastView(message: toaster.toastMessage, toastType: toaster.toastType)
                                .onTapGesture {
                                    if toaster.toastType != .PersistentError && toaster.toastType != .Spinner {
                                        toaster.hideToast()
                                    }
                                }
                        }
                        Color.clear
                    }
                    .padding(EdgeInsets(top: 0.0, leading: 16.0, bottom: metrics.safeAreaInsets.bottom + 65.0, trailing: 16.0))
                    .animation(.default, value: toaster.isToastShowing)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    func reloadBusStopList(forceServer: Bool = false) async {
        toaster.showToast(localized("Directory.BusStopsLoading"), type: .Spinner, hidesAutomatically: false)
        do {
            if dataManager.storedBusStopList() == nil || forceServer {
                try await dataManager.reloadBusStopListFromServer()
                log("Reloaded bus stop data from server.")
            } else {
                if let storedBusStopList = dataManager.storedBusStopList(),
                   let storedBusStopListUpdatedDate = dataManager.storedBusStopListUpdatedDate() {
                    try await dataManager.reloadBusStopListFromStoredMemory(storedBusStopList, updatedAt: storedBusStopListUpdatedDate)
                    log("Reloaded bus stop data from memory.")
                }
            }
            toaster.hideToast()
        } catch {
            log(error.localizedDescription)
            log("WARNING×WARNING×WARNING\nNetwork does not look like it's working, bus stop data may be incomplete!")
            toaster.showToast(localized("Shared.Error.InternetConnection"), type: .PersistentError, hidesAutomatically: false)
        }
    }
    
    func reloadBusRouteList() async {
        do {
            try await dataManager.reloadBusRoutesFromServer()
            log("Reloaded bus route data from server.")
        } catch {
            log(error.localizedDescription)
            toaster.showToast(localized("Shared.Error.InternetConnection"), type: .PersistentError, hidesAutomatically: false)
        }
    }
    
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
