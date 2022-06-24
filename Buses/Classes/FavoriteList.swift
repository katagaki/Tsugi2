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
        DispatchQueue.main.async { [self] in
            do {
                favoriteLocations = try context.fetch(fetchRequestForLocations)
                favoriteBusServices = try context.fetch(fetchRequestForBusServices)
                favoriteLocations.sort { a, b in
                    a.viewIndex < b.viewIndex
                }
                
                // Retroactively add indexes (should be removed in final build)
                for i in 0..<favoriteLocations.count {
                    favoriteLocations[i].viewIndex = Int16(i)
                }
                Task {
                    await saveChanges(andReload: false)
                }
                
                log("Favorites data reloaded.")
            } catch {
                favoriteLocations = []
                favoriteBusServices = []
            }
        }
    }
    
    func addFavoriteLocation(busStop: BusStop, nickname: String = "", usesLiveBusStopData: Bool = false, containing busServices: [BusService] = []) {
        let favoriteLocationEntity = FavoriteLocation.entity()
        let favoriteLocation = FavoriteLocation(entity: favoriteLocationEntity, insertInto: context)
        favoriteLocation.busStopCode = busStop.code
        favoriteLocation.nickname = (nickname == "" ? busStop.description : nickname)
        favoriteLocation.usesLiveBusStopData = usesLiveBusStopData
        for busService in busServices {
            let favoriteBusServiceEntity = FavoriteBusService.entity()
            let favoriteBusService = FavoriteBusService(entity: favoriteBusServiceEntity, insertInto: context)
            favoriteBusService.busStopCode = busService.busStopCode
            favoriteBusService.serviceNo = busService.serviceNo
            favoriteLocation.addToBusServices(favoriteBusService)
        }
        log("Favorite location added using bus stop.")
    }
    
    func addNewFavoriteLocation(nickname: String) {
        let favoriteLocationEntity = FavoriteLocation.entity()
        let favoriteLocation = FavoriteLocation(entity: favoriteLocationEntity, insertInto: context)
        favoriteLocation.busStopCode = ""
        favoriteLocation.nickname = nickname
        favoriteLocation.usesLiveBusStopData = false
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
