//
//  FavoritesManager.swift
//  Buses
//
//  Created by 堅書 on 2023/04/23.
//

import SwiftData
import SwiftUI
import WidgetKit

@MainActor
@Observable
class FavoritesManager {

    @ObservationIgnored private let context: ModelContext

    var favoriteLocations: [FavoriteLocation] = []

    var updateViewFlag = false

    init(container: ModelContainer = FavoritesStore.container) {
        context = container.mainContext
        LegacyFavoritesMigrator.migrateIfNeeded(into: context)
        reloadData()
        normalizeViewIndexes()
        log("Favorites data loaded.")
    }

    func reloadData() {
        do {
            favoriteLocations = try context.fetch(FetchDescriptor<FavoriteLocation>(
                sortBy: [SortDescriptor(\.viewIndex)]
            ))
            updateViewFlag.toggle()
        } catch {
            log(error.localizedDescription)
            favoriteLocations = []
        }
    }

    /// Repairs duplicate view indexes so that moving items up and down behaves predictably.
    private func normalizeViewIndexes() {
        var changed = false
        for (index, location) in favoriteLocations.enumerated() where location.viewIndex != index {
            location.viewIndex = index
            changed = true
        }
        for location in favoriteLocations {
            for (index, busService) in location.sortedBusServices.enumerated() where busService.viewIndex != index {
                busService.viewIndex = index
                changed = true
            }
        }
        if changed {
            log("View indexes reset after consistency check was performed.")
            save(reloading: false)
        }
    }

    func addBusServiceToFavoriteLocation(_ favoriteLocation: FavoriteLocation,
                                         busStop: BusStop,
                                         busService: BusService) async {
        addBusServiceToFavoriteLocation(favoriteLocation, stopCode: busStop.code, serviceNo: busService.serviceNo)
    }

    func addBusServiceToFavoriteLocation(_ favoriteLocation: FavoriteLocation,
                                         stopCode: String,
                                         busService: BusService) async {
        addBusServiceToFavoriteLocation(favoriteLocation, stopCode: stopCode, serviceNo: busService.serviceNo)
    }

    private func addBusServiceToFavoriteLocation(_ favoriteLocation: FavoriteLocation,
                                                 stopCode: String,
                                                 serviceNo: String) {
        let favoriteBusService = FavoriteBusService(busStopCode: stopCode, serviceNo: serviceNo,
                                                    viewIndex: favoriteLocation.busServices.count)
        context.insert(favoriteBusService)
        favoriteBusService.location = favoriteLocation
        log("Favorite bus service added to favorite location.")
        save()
    }

    func addFavoriteLocation(busStop: BusStop,
                             nickname: String = "",
                             usesLiveBusStopData: Bool = false) async {
        moveAllDown()
        context.insert(FavoriteLocation(busStopCode: busStop.code,
                                        nickname: nickname == "" ? busStop.description : nickname,
                                        usesLiveBusStopData: usesLiveBusStopData))
        log("Favorite location added using bus stop.")
        save()
    }

    func createNewFavoriteLocation(nickname: String) async {
        moveAllDown()
        context.insert(FavoriteLocation(busStopCode: "", nickname: nickname))
        log("New favorite location created.")
        save()
    }

    func moveUp(_ favoriteLocation: FavoriteLocation) async {
        let originalIndex = favoriteLocation.viewIndex
        if originalIndex > 0 {
            let locationToSwapWith = favoriteLocations[originalIndex - 1]
            favoriteLocation.viewIndex = originalIndex - 1
            locationToSwapWith.viewIndex = originalIndex
        }
        log("Favorite location moved up.")
        save()
    }

    func moveDown(_ favoriteLocation: FavoriteLocation) async {
        let originalIndex = favoriteLocation.viewIndex
        if originalIndex < favoriteLocations.count - 1 {
            let locationToSwapWith = favoriteLocations[originalIndex + 1]
            favoriteLocation.viewIndex = originalIndex + 1
            locationToSwapWith.viewIndex = originalIndex
        }
        log("Favorite location moved down.")
        save()
    }

    private func moveAllDown() {
        for favoriteLocation in favoriteLocations {
            favoriteLocation.viewIndex += 1
        }
    }

    func reorderLocations(_ orderedLocations: [FavoriteLocation]) async {
        for (index, location) in orderedLocations.enumerated() {
            location.viewIndex = index
        }
        log("Favorite locations reordered.")
        save(reloading: false)
    }

    func reorderBusServices(_ favoriteLocation: FavoriteLocation,
                            orderedServices: [FavoriteBusService]) async {
        for (index, service) in orderedServices.enumerated() {
            service.viewIndex = index
        }
        log("Bus services reordered.")
        save(reloading: false)
    }

    func rename(_ favoriteLocation: FavoriteLocation, to newNickname: String) async {
        favoriteLocation.nickname = newNickname
        log("Favorite location renamed.")
        save()
    }

    func deleteLocation(_ favoriteLocation: FavoriteLocation) async {
        let deletedIndex = favoriteLocation.viewIndex
        for location in favoriteLocations where location.viewIndex > deletedIndex {
            location.viewIndex -= 1
        }
        favoriteLocations.removeAll { $0.persistentModelID == favoriteLocation.persistentModelID }
        context.delete(favoriteLocation)
        log("Favorite location deleted.")
        save(reloading: false)
    }

    func deleteBusService(_ favoriteLocation: FavoriteLocation, busService: FavoriteBusService) async {
        let remainingServices = favoriteLocation.sortedBusServices.filter { $0 != busService }
        context.delete(busService)
        for (index, service) in remainingServices.enumerated() {
            service.viewIndex = index
        }
        log("Favorite bus service deleted.")
        save()
    }

    func find(_ serviceNo: String, in favoriteLocation: FavoriteLocation) -> Bool {
        return favoriteLocation.busServices.contains { $0.serviceNo == serviceNo }
    }

    private func save(reloading: Bool = true) {
        do {
            if context.hasChanges {
                try context.save()
                log("Favorites saved.")
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            log(error.localizedDescription)
        }
        if reloading {
            reloadData()
        }
    }

}
