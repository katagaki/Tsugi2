//
//  FavoritesManager.swift
//  Buses
//
//  Created by 堅書 on 2022/06/18.
//

import CoreData
import SwiftUI

// swiftlint:disable type_body_length
class FavoritesManager: ObservableObject {

    private let context = FavoritesCoreDataManager.shared.mainContext
    private let fetchRequestForLocations: NSFetchRequest<FavoriteLocation> = FavoriteLocation.fetchRequest()
    private let fetchRequestForBusServices: NSFetchRequest<FavoriteBusService> = FavoriteBusService.fetchRequest()

    @Published var favoriteLocations: [FavoriteLocation]
    @Published var favoriteBusServices: [FavoriteBusService]

    @Published var updateViewFlag = false

    init() {
        do {
            favoriteLocations = try context.fetch(fetchRequestForLocations)
            favoriteBusServices = try context.fetch(fetchRequestForBusServices)
            favoriteLocations.sort { lhs, rhs in
                lhs.viewIndex < rhs.viewIndex
            }
            favoriteBusServices.sort { lhs, rhs in
                lhs.viewIndex < rhs.viewIndex
            }

            var consistencyCheckRequired: Bool = false

            if favoriteLocations.first(where: { favoriteLocation in
                favoriteLocation.viewIndex == 0
            }) != favoriteLocations.last(where: { favoriteLocation in
                favoriteLocation.viewIndex == 0
            }) ||
                !favoriteLocations.compactMap({ favoriteLocation in
                    return favoriteLocation.viewIndex
                }).isDistinct() {
                for index in 0..<favoriteLocations.count {
                    favoriteLocations[index].viewIndex = Int16(index)
                }
                consistencyCheckRequired = true
                log("View indexes reset for favorite locations after consistency check was performed.")
            }

            for favoriteLocation in favoriteLocations {
                if let favoriteLocationBusServices = favoriteLocation.busServices?.array as? [FavoriteBusService],
                   favoriteLocationBusServices.first(where: { favoriteBusService in
                        favoriteBusService.viewIndex == 0
                    }) != favoriteLocationBusServices.last(where: { favoriteBusService in
                        favoriteBusService.viewIndex == 0
                    }) {
                    for index in 0..<favoriteLocationBusServices.count {
                        favoriteLocationBusServices[index].viewIndex = Int16(index)
                    }
                    consistencyCheckRequired = true
                    log("View indexes reset for a favorite location's bus services during consistency check.")
                }
            }

            if consistencyCheckRequired {
                try context.save()
            }

            log("Favorites data loaded.")
        } catch {
            log(error.localizedDescription)
            favoriteLocations = []
            favoriteBusServices = []
        }
    }

    func reloadData() {
        do {
            favoriteLocations = try context.fetch(fetchRequestForLocations)
            favoriteBusServices = try context.fetch(fetchRequestForBusServices)
            favoriteLocations.sort { lhs, rhs in
                lhs.viewIndex < rhs.viewIndex
            }
            favoriteBusServices.sort { lhs, rhs in
                lhs.viewIndex < rhs.viewIndex
            }
            log("Favorites data reloaded.")
            updateViewFlag.toggle()
        } catch {
            log(error.localizedDescription)
            favoriteLocations = []
            favoriteBusServices = []
        }
    }

    func addBusServiceToFavoriteLocation(_ favoriteLocation: FavoriteLocation,
                                         busStop: BusStop,
                                         busService: BusService) async {
        let favoriteBusServiceEntity = FavoriteBusService.entity()
        let favoriteBusService = FavoriteBusService(entity: favoriteBusServiceEntity, insertInto: context)
        favoriteBusService.busStopCode = busStop.code
        favoriteBusService.serviceNo = busService.serviceNo
        favoriteLocation.addToBusServices(favoriteBusService)
        // TODO: Add and set view index
        log("Favorite bus service added to favorite location.")
        await saveChanges()
    }

    func addBusServiceToFavoriteLocation(_ favoriteLocation: FavoriteLocation,
                                         stopCode: String,
                                         busService: BusService) async {
        let favoriteBusServiceEntity = FavoriteBusService.entity()
        let favoriteBusService = FavoriteBusService(entity: favoriteBusServiceEntity, insertInto: context)
        favoriteBusService.busStopCode = stopCode
        favoriteBusService.serviceNo = busService.serviceNo
        favoriteLocation.addToBusServices(favoriteBusService)
        // TODO: Add and set view index
        log("Favorite bus service added to favorite location.")
        await saveChanges()
    }

    func addFavoriteLocation(busStop: BusStop,
                             nickname: String = "",
                             usesLiveBusStopData: Bool = false,
                             containing busServices: [BusService] = []) async {
        await moveAllDown()
        let favoriteLocationEntity = FavoriteLocation.entity()
        let favoriteLocation = FavoriteLocation(entity: favoriteLocationEntity, insertInto: context)
        favoriteLocation.busStopCode = busStop.code
        favoriteLocation.nickname = (nickname == "" ? busStop.description : nickname)
        favoriteLocation.usesLiveBusStopData = usesLiveBusStopData
        favoriteLocation.viewIndex = 0
        log("Favorite location added using bus stop.")
        await saveChanges()
    }

    func createNewFavoriteLocation(nickname: String) async {
        await moveAllDown()
        let favoriteLocationEntity = FavoriteLocation.entity()
        let favoriteLocation = FavoriteLocation(entity: favoriteLocationEntity, insertInto: context)
        favoriteLocation.busStopCode = ""
        favoriteLocation.nickname = nickname
        favoriteLocation.usesLiveBusStopData = false
        favoriteLocation.viewIndex = 0
        log("New favorite location created.")
        await saveChanges()
    }

    func moveUp(_ favoriteLocation: FavoriteLocation) async {
        let originalIndex: Int16 = favoriteLocation.viewIndex
        if originalIndex > 0 {
            let locationToSwapWith = favoriteLocations[Int(originalIndex) - 1]
            favoriteLocation.viewIndex = Int16(originalIndex - 1)
            locationToSwapWith.viewIndex = Int16(originalIndex)
        }
        log("Favorite location moved up.")
        await saveChanges()
    }

    func moveDown(_ favoriteLocation: FavoriteLocation) async {
        let originalIndex: Int16 = favoriteLocation.viewIndex
        if originalIndex < favoriteLocations.count - 1 {
            let locationToSwapWith = favoriteLocations[Int(originalIndex) + 1]
            favoriteLocation.viewIndex = Int16(originalIndex + 1)
            locationToSwapWith.viewIndex = Int16(originalIndex)
        }
        log("Favorite location moved down.")
        await saveChanges()
    }

    func moveAllDown() async {
        for favoriteLocation in favoriteLocations {
            favoriteLocation.viewIndex += 1
        }
        log("All favorite locations moved down.")
    }

    func moveBusServiceUp(_ favoriteLocation: FavoriteLocation, busService: FavoriteBusService) async {
        let originalViewIndex: Int16 = busService.viewIndex
        let newViewIndex: Int16 = busService.viewIndex - 1
        if newViewIndex >= 0,
           let favoriteLocationBusServices = favoriteLocation.busServices?.array as? [FavoriteBusService],
           let favoriteBusServiceToSwapWith = favoriteLocationBusServices.first(where: { favoriteBusService in
               favoriteBusService.viewIndex == newViewIndex
            }) {
            favoriteBusServiceToSwapWith.viewIndex = originalViewIndex
            busService.viewIndex = newViewIndex
        }
        log("Bus service moved up.")
        await saveChanges()
    }

    func moveBusServiceDown(_ favoriteLocation: FavoriteLocation, busService: FavoriteBusService) async {
        let originalViewIndex: Int16 = busService.viewIndex
        let newViewIndex: Int16 = busService.viewIndex + 1
        if newViewIndex < favoriteLocation.busServices?.count ?? 0,
           let favoriteLocationBusServices = favoriteLocation.busServices?.array as? [FavoriteBusService],
           let favoriteBusServiceToSwapWith = favoriteLocationBusServices.first(where: { favoriteBusService in
               favoriteBusService.viewIndex == newViewIndex
            }) {
            favoriteBusServiceToSwapWith.viewIndex = originalViewIndex
            busService.viewIndex = newViewIndex
        }
        log("Bus service moved down.")
        await saveChanges()
    }

    func rename(_ favoriteLocation: FavoriteLocation, to newNickname: String) async {
        favoriteLocation.nickname = newNickname
        log("Favorite location renamed.")
        await saveChanges()
    }

    func deleteLocation(_ favoriteLocation: FavoriteLocation) async {
        if favoriteLocation.viewIndex < favoriteLocations.count - 1 {
            for index in (Int(favoriteLocation.viewIndex) + 1)..<favoriteLocations.count {
                favoriteLocations.first(where: { favoriteLocation in
                    favoriteLocation.viewIndex == index
                })!.viewIndex -= 1
            }
        }
        context.delete(favoriteLocation)
        log("Favorite location deleted.")
        await saveChanges()
    }

    func deleteBusService(_ favoriteLocation: FavoriteLocation, busService: FavoriteBusService) async {
        favoriteLocation.removeFromBusServices(busService)
        log("Favorite bus service deleted.")
        await saveChanges()
    }

    func deleteAllData(_ entity: String) {
        do {
            let busServices = try context.fetch(fetchRequestForBusServices)
            let locations = try context.fetch(fetchRequestForLocations)
            for location in locations {
                context.delete(location)
            }
            for busService in busServices {
                context.delete(busService)
            }
            log("All favorites deleted.")
        } catch let error {
            log(error.localizedDescription)
        }
        reloadData()
    }

    func find(_ serviceNo: String, in favoriteLocation: FavoriteLocation) -> Bool {
        for favoriteBusService in favoriteBusServices where favoriteBusService.serviceNo == serviceNo {
            if let parentLocations = favoriteBusService.parentLocations,
               parentLocations.contains(favoriteLocation) {
                return true
            }
        }
        return false
    }

    func saveChanges() async {
        do {
            try await context.perform { [self] in
                if context.hasChanges {
                    try context.save()
                    log("Favorites saved.")
                    reloadData()
                }
            }
        } catch {
            log(error.localizedDescription)
        }
    }

    class FavoritesCoreDataManager {

        static let shared = FavoritesCoreDataManager()

        private init() {
            // No init required
        }

        private lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "Favorites")
            container.loadPersistentStores { _, error in
                if let error = error {
                    log(error.localizedDescription)
                }
            }
            return container
        }()

        var mainContext: NSManagedObjectContext {
            return persistentContainer.viewContext
        }

        func backgroundContext() -> NSManagedObjectContext {
            return persistentContainer.newBackgroundContext()
        }

    }

}
// swiftlint:enable type_body_length
