//
//  FavoriteList.swift
//  Buses
//
//  Created by Justin Xin on 2022/06/18.
//

import CoreData
import SwiftUI

class FavoriteList: ObservableObject {
    
    private let context = FavoritesManager.shared.mainContext
    private let fetchRequestForLocations: NSFetchRequest<FavoriteLocation> = FavoriteLocation.fetchRequest()
    private let fetchRequestForBusServices: NSFetchRequest<FavoriteBusService> = FavoriteBusService.fetchRequest()
    
    @Published var favoriteLocations: [FavoriteLocation]
    @Published var favoriteBusServices: [FavoriteBusService]
    
    
    init() {
        do {
            favoriteLocations = try context.fetch(fetchRequestForLocations)
            favoriteBusServices = try context.fetch(fetchRequestForBusServices)
            favoriteLocations.sort { a, b in
                a.viewIndex < b.viewIndex
            }
        }
        catch {
            favoriteLocations = []
            favoriteBusServices = []
        }
    }
    
    func reloadData() {
        do {
            favoriteLocations = try context.fetch(fetchRequestForLocations)
            favoriteBusServices = try context.fetch(fetchRequestForBusServices)
            favoriteLocations.sort { a, b in
                a.viewIndex < b.viewIndex
            }
            
            // Retroactively add indexes for stability
            for i in 0..<favoriteLocations.count {
                favoriteLocations[i].viewIndex = Int16(i)
            }
            for favoriteLocation in favoriteLocations {
                if let favoriteLocationBusServices = favoriteLocation.busServices?.array as? [FavoriteBusService] {
                    for i in 0..<favoriteLocationBusServices.count {
                        favoriteLocationBusServices[i].viewIndex = Int16(i)
                    }
                }
            }
            
            log("Favorites data reloaded.")
        } catch {
            favoriteLocations = []
            favoriteBusServices = []
        }
    }
    
    func addBusStopToFavoriteLocation(_ favoriteLocation: FavoriteLocation, busStop: BusStop, busService: BusService) async {
        let favoriteBusServiceEntity = FavoriteBusService.entity()
        let favoriteBusService = FavoriteBusService(entity: favoriteBusServiceEntity, insertInto: context)
        favoriteBusService.busStopCode = busStop.code
        favoriteBusService.serviceNo = busService.serviceNo
        favoriteLocation.addToBusServices(favoriteBusService)
        log("Favorite bus service added to favorite location.")
    }
    
    func addFavoriteLocation(busStop: BusStop, nickname: String = "", usesLiveBusStopData: Bool = false, containing busServices: [BusService] = []) async {
        let favoriteLocationEntity = FavoriteLocation.entity()
        let favoriteLocation = FavoriteLocation(entity: favoriteLocationEntity, insertInto: context)
        favoriteLocation.busStopCode = busStop.code
        favoriteLocation.nickname = (nickname == "" ? busStop.description : nickname)
        favoriteLocation.usesLiveBusStopData = usesLiveBusStopData
        await moveAllDown()
        favoriteLocation.viewIndex = 0
        for busService in busServices {
            let favoriteBusServiceEntity = FavoriteBusService.entity()
            let favoriteBusService = FavoriteBusService(entity: favoriteBusServiceEntity, insertInto: context)
            favoriteBusService.busStopCode = busService.busStopCode
            favoriteBusService.serviceNo = busService.serviceNo
            favoriteLocation.addToBusServices(favoriteBusService)
        }
        log("Favorite location added using bus stop.")
    }
    
    func addNewFavoriteLocation(nickname: String) async {
        let favoriteLocationEntity = FavoriteLocation.entity()
        let favoriteLocation = FavoriteLocation(entity: favoriteLocationEntity, insertInto: context)
        favoriteLocation.busStopCode = ""
        favoriteLocation.nickname = nickname
        favoriteLocation.usesLiveBusStopData = false
        await moveAllDown()
        favoriteLocation.viewIndex = 0
        log("New favorite location added.")
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
    
    func rename(_ favoriteLocation: FavoriteLocation, to newNickname: String) async {
        favoriteLocation.nickname = newNickname
        log("Favorite location renamed.")
        await saveChanges()
    }
    
    func deleteLocation(_ favoriteLocation: FavoriteLocation) async {
        context.delete(favoriteLocation)
        log("Favorite location deleted.")
        await saveChanges()
    }
    
    func deleteAllData(_ entity:String) {
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
        for favoriteBusService in favoriteBusServices {
            if favoriteBusService.serviceNo == serviceNo {
                if let parentLocations = favoriteBusService.parentLocations {
                    if parentLocations.contains(favoriteLocation) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func saveChanges(andReload willReload: Bool = true) async {
        do {
            try await context.perform { [self] in
                if context.hasChanges {
                    try context.save()
                    log("Favorites saved.")
                    if willReload {
                        reloadData()
                    }
                }
            }
        } catch {
            log(error.localizedDescription)
        }
    }
    
}
