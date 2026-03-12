//
//  UnifiedView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

#if canImport(CoreLocationUI)
import CoreLocationUI
#endif
import CoreLocation
import MapKit
import SwiftUI

struct UnifiedView: View {

    @Environment(\.scenePhase) var scenePhase

    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var regionManager: RegionManager
    @EnvironmentObject var coordinateManager: CoordinateManager
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var toaster: Toaster

    @State var isInitialLoad: Bool = true
    @State var isNotificationsSheetPresented: Bool = false
    @State var isMoreSheetPresented: Bool = false

    // Search
    @State var searchTerm: String = ""
    @State var previousSearchTerm: String = ""
    @State var searchResults: [BusStop] = []

    // Nearby
    @State var isNearbyBusStopsDetermined: Bool = false
    @State var nearbyBusStops: [BusStop] = []

    // Favorites editing
    @State var isEditing: Bool = false
    @State var isNewPending: Bool = false
    @State var favoriteLocationNewNickname: String = ""
    @State var locationPendingRename: FavoriteLocation?
    @State var renameText: String = ""
    @State var isRenamePending: Bool = false
    @State var locationPendingBusServiceEdit: FavoriteLocation?
    @State var isBusServiceEditPending: Bool = false

    var body: some View {
        NavigationStack(path: $navigationManager.mainPath) {
            listContent
        }
        .modifier(FavoriteAlertsModifier(
            isNewPending: $isNewPending,
            favoriteLocationNewNickname: $favoriteLocationNewNickname,
            isRenamePending: $isRenamePending,
            renameText: $renameText,
            locationPendingRename: $locationPendingRename,
            favorites: favorites
        ))
        .task {
            if isInitialLoad {
                await reloadBusStopList()
                isInitialLoad = false
            }
        }
        .onAppear {
            log("Main view appeared.")
            if !locationManager.isInUsableState() {
                locationManager.requestWhenInUseAuthorization()
            } else {
                reloadNearbyBusStops()
            }
        }
        .onChange(of: searchTerm) { _, _ in
            let searchTermTrimmed = searchTerm.trimmingCharacters(in: .whitespaces)
            if searchTermTrimmed.count > 1 {
                if searchTermTrimmed.contains(previousSearchTerm) {
                    searchResults = searchResults.filter { stop in
                        stop.name().similarTo(searchTermTrimmed)
                    }
                } else {
                    searchResults = dataManager.busStops.filter { stop in
                        stop.name().similarTo(searchTermTrimmed)
                    }
                }
                previousSearchTerm = searchTermTrimmed
            }
        }
        .onChange(of: locationManager.authorizationStatus) { _, newValue in
            if let newValue {
                handleLocationAuthorizationChange(newValue)
            }
        }
        .onChange(of: dataManager.busStops) { _, _ in
            if dataManager.busStops.count > 0 {
                log("Bus stop list changed.")
                locationManager.completion = self.reloadNearbyBusStops
                locationManager.updateLocation(usingOnlySignificantChanges: false)
            }
        }
        .onChange(of: dataManager.shouldReloadBusStopList) { _, newValue in
            if newValue {
                Task {
                    await reloadBusStopList(forceServer: true)
                }
            }
        }
        .onChange(of: networkMonitor.isConnected) { _, isConnected in
            handleNetworkChange(isConnected)
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
    }

}
