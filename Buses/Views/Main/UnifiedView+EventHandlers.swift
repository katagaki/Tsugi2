//
//  MainTabView+EventHandlers.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import CoreLocation
import SwiftUI

extension UnifiedView {

    // MARK: - Event Handlers

    func handleLocationAuthorizationChange(_ newValue: CLAuthorizationStatus) {
        switch newValue {
        case .authorizedWhenInUse:
            log("Location Services authorization changed to When In Use.")
            locationManager.shared.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.updateLocation(usingOnlySignificantChanges: false)
        case .notDetermined:
            log("Location Services authorization not determined yet.")
            locationManager.requestWhenInUseAuthorization()
        default:
            log("Location Services authorization possibly changed to Don't Allow.")
            nearbyBusStops.removeAll()
            coordinateManager.removeAll()
        }
    }

    func handleNetworkChange(_ isConnected: Bool) {
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
    }

    // MARK: - Favorites Editing

    func moveLocations(from source: IndexSet, to destination: Int) {
        favorites.favoriteLocations.move(fromOffsets: source, toOffset: destination)
        Task {
            await favorites.reorderLocations(favorites.favoriteLocations)
        }
    }

    func deleteLocations(at offsets: IndexSet) {
        let locationsToDelete = offsets.map { favorites.favoriteLocations[$0] }
        for location in locationsToDelete {
            Task {
                await favorites.deleteLocation(location)
            }
        }
    }

    func handleScenePhaseChange(_ newPhase: ScenePhase) {
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
    }

}
