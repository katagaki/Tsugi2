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
            }
            catch {
                favoriteLocations = []
                favoriteBusServices = []
            }
        }
    }
    
    func deleteLocation(at offsets: IndexSet) async {
        do {
            let locations = try context.fetch(fetchRequestForLocations)
            try await context.perform { [self] in
                for offset in offsets {
                    context.delete(locations[offset])
                }
                try context.save()
            }
        } catch let error {
            log(error.localizedDescription)
        }
        reloadData()
    }
    
    func deleteAllData(_ entity:String) async {
        do {
            let busServices = try context.fetch(fetchRequestForBusServices)
            let locations = try context.fetch(fetchRequestForLocations)
            try await context.perform { [self] in
                for location in locations {
                    context.delete(location)
                }
                for busService in busServices {
                    context.delete(busService)
                }
                try context.save()
            }
        } catch let error {
            log(error.localizedDescription)
        }
        reloadData()
    }
    
    func addFavoriteLocation(busStopCode: String = "", nickname: String = "", usesLiveBusStopData: Bool = false, containing busServices: [BusService] = []) async {
        do {
            try await context.perform { [self] in
                let favoriteLocationEntity = FavoriteLocation.entity()
                let favoriteLocation = FavoriteLocation(entity: favoriteLocationEntity, insertInto: context)
                favoriteLocation.busStopCode = busStopCode
                favoriteLocation.nickname = (nickname == "" ? busStopCode : nickname)
                favoriteLocation.usesLiveBusStopData = usesLiveBusStopData
                for busService in busServices {
                    let favoriteBusServiceEntity = FavoriteBusService.entity()
                    let favoriteBusService = FavoriteBusService(entity: favoriteBusServiceEntity, insertInto: context)
                    favoriteBusService.busStopCode = busService.busStopCode
                    favoriteBusService.serviceNo = busService.serviceNo
                    favoriteLocation.addToBusServices(favoriteBusService)
                }
                try self.context.save()
            }
        } catch {
            log(error.localizedDescription)
        }
        reloadData()
    }
    
}
