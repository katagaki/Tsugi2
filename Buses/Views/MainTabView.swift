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
    @EnvironmentObject var busStopList: BusStopList
    @EnvironmentObject var favorites: FavoriteList
    @EnvironmentObject var regionManager: MapRegionManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var shouldReloadBusStopList: BoolState
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var toaster: Toaster
    
    @State var defaultTab: Int = 0
    
    @State var isInitialLoad: Bool = true
    @State var updatedDate: String
    @State var updatedTime: String
    
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
                DirectoryView(updatedDate: $updatedDate,
                              updatedTime: $updatedTime)
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
            .onAppear {
                if isInitialLoad {
                    defaultTab = settings.startupTab
                    reloadBusStopList()
                    isInitialLoad = false
                }
            }
            .onChange(of: shouldReloadBusStopList.state, perform: { newValue in
                if newValue {
                    reloadBusStopList(forceServer: true)
                }
            })
            .onChange(of: networkMonitor.isConnected) { isConnected in
                if isConnected {
                    log("Network connection reappeared!")
                    toaster.hideToast()
                    log("Retrying fetch of bus stop data.")
                    reloadBusStopList()
                } else {
                    log("Network connection disappeared!")
                    toaster.showToast(localized("Shared.Error.InternetConnection"), type: .PersistentError, hideAutomatically: false)
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
                    .padding(EdgeInsets(top: 0.0, leading: 8.0, bottom: metrics.safeAreaInsets.bottom + 57.0, trailing: 8.0))
                    .animation(.default, value: toaster.isToastShowing)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    func reloadBusStopList(forceServer: Bool = false) {
        Task {
            toaster.showToast(localized("Directory.BusStopsLoading"), type: .Spinner, hideAutomatically: false)
            if settings.storedBusStopList() == nil || forceServer {
                await reloadBusStopListFromServer()
                log("Reloaded bus stop data from server.")
            } else {
                reloadBusStopListFromStoredMemory()
                log("Reloaded bus stop data from memory.")
            }
            shouldReloadBusStopList.state = false
            toaster.hideToast()
        }
    }
    
    func reloadBusStopListFromServer() async {
        do {
            let busStopsFetched = try await fetchAllBusStops()
            busStopList.busStops = busStopsFetched.sorted(by: { a, b in
                a.description?.lowercased() ?? "" < b.description?.lowercased() ?? ""
            })
            if settings.useProperText {
                busStopList.busStops.forEach { busStop in
                    busStop.description = properName(for: busStop.description ?? localized("Shared.BusStop.Description.None"))
                    busStop.roadName = properName(for: busStop.roadName ?? localized("Shared.BusStop.Description.None"))
                }
            }
            settings.setStoredBusStopList(busStopList)
            settings.setStoredBsuStopListUpdatedDate(Date.now)
            setLastUpdatedTimeForBusStopData()
        } catch {
            log("WARNING×WARNING×WARNING\nNetwork does not look like it's working, bus stop data may be incomplete!")
            toaster.showToast(localized("Shared.Error.InternetConnection"), type: .PersistentError, hideAutomatically: false)
        }
    }
    
    func reloadBusStopListFromStoredMemory() {
        if let storedBusStopListJSON = settings.storedBusStopList(),
           let storedUpdatedDate = settings.storedBusStopListUpdatedDate(),
           let storedBusStopList: BusStopList = decode(fromData: storedBusStopListJSON.data(using: .utf8) ?? Data()) {
            busStopList.metadata = storedBusStopList.metadata
            busStopList.busStops = storedBusStopList.busStops
            setLastUpdatedTimeForBusStopData(storedUpdatedDate)
            log("Fetched bus stop data from memory with \(busStopList.busStops.count) bus stop(s).")
            return
        }
        log("Could not decode stored data successfully, re-fetching bus stop data from server...", level: .error)
        reloadBusStopListFromStoredMemory()
    }
    
    func setLastUpdatedTimeForBusStopData(_ date: Date = Date.now) {
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        timeFormatter.timeStyle = .medium
        updatedDate = dateFormatter.string(from: date)
        updatedTime = timeFormatter.string(from: date)
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(updatedDate: "", updatedTime: "")
    }
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}
