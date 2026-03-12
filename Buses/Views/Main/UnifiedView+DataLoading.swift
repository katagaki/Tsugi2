//
//  MainTabView+DataLoading.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import CoreLocation
import MapKit
import SwiftUI

extension UnifiedView {

    // MARK: - Data Loading

    func reloadBusStopList(forceServer: Bool = false) async {
        toaster.showToast(localized("Directory.BusStopsLoading"),
                          type: .spinner,
                          hidesAutomatically: false)
        do {
            if dataManager.storedBusStopList() == nil || forceServer {
                try await dataManager.reloadBusStopListFromServer()
                log("Reloaded bus stop data from server.")
            } else {
                if let storedBusStopList = dataManager.storedBusStopList(),
                   let storedBusStopListUpdatedDate = dataManager.storedBusStopListUpdatedDate() {
                    try await dataManager.reloadBusStopListFromStoredMemory(
                        storedBusStopList,
                        updatedAt: storedBusStopListUpdatedDate
                    )
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

    func reloadNearbyBusStops() {
        Task {
            let currentCoordinate = CLLocation(
                latitude: locationManager.region.center.latitude,
                longitude: locationManager.region.center.longitude
            )
            var busStopListSortedByDistance: [BusStop] = dataManager.busStops
            busStopListSortedByDistance = busStopListSortedByDistance.filter { busStop in
                currentCoordinate.distanceTo(busStop: busStop) < 500.0
            }
            busStopListSortedByDistance.sort { lhs, rhs in
                currentCoordinate.distanceTo(busStop: lhs) < currentCoordinate.distanceTo(busStop: rhs)
            }
            nearbyBusStops.removeAll()
            nearbyBusStops.append(contentsOf: busStopListSortedByDistance)
            log("Reloaded nearby bus stop data.")
            regionManager.updateRegion(newRegion: locationManager.region)
            log("Updated Map region.")
            coordinateManager.removeAll()
            coordinateManager.replaceWithCoordinates(from: nearbyBusStops)
            coordinateManager.updateCameraFlag.toggle()
            log("Updated displayed coordinates.")
            isNearbyBusStopsDetermined = true
        }
    }

}
