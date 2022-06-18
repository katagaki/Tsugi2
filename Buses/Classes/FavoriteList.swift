//
//  FavoriteList.swift
//  Buses
//
//  Created by Justin Xin on 2022/06/18.
//

import CoreData
import SwiftUI

class FavoriteList: ObservableObject {
    
    let context = FavoritesManager.shared.backgroundContext()
    
    @Published var favoriteLocations: [FavoriteLocation]
    @Published var favoriteBusServices: [FavoriteBusService]
    
    private let mainContext = FavoritesManager.shared.mainContext
    private let fetchRequestForLocations: NSFetchRequest<FavoriteLocation> = FavoriteLocation.fetchRequest()
    private let fetchRequestForBusServices: NSFetchRequest<FavoriteBusService> = FavoriteBusService.fetchRequest()
    
    init() {
        do {
            favoriteLocations = try mainContext.fetch(fetchRequestForLocations)
            favoriteBusServices = try mainContext.fetch(fetchRequestForBusServices)
        }
        catch {
            favoriteLocations = []
            favoriteBusServices = []
        }
    }
    
    func reloadData() {
        DispatchQueue.main.async { [self] in
            do {
                favoriteLocations = try mainContext.fetch(fetchRequestForLocations)
                favoriteBusServices = try mainContext.fetch(fetchRequestForBusServices)
            }
            catch {
                favoriteLocations = []
                favoriteBusServices = []
            }
        }
    }
    
    func deleteAllData(_ entity:String) {
        do {
            let busServices = try mainContext.fetch(fetchRequestForBusServices)
            let locations = try mainContext.fetch(fetchRequestForLocations)
            for location in locations {
                mainContext.delete(location)
            }
            for busService in busServices {
                mainContext.delete(busService)
            }
        } catch let error {
            print(error.localizedDescription)
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
            print(error.localizedDescription)
        }
        reloadData()
    }
    
}
