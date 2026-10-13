//
//  LegacyFavoritesMigrator.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import CoreData
import SwiftData

/// Copies favorites from the Core Data store used before version 2.0 into SwiftData.
/// The legacy store is left untouched so that downgrading does not lose data.
enum LegacyFavoritesMigrator {

    static let migratedKey = "LegacyFavoritesMigrated"

    static var legacyStoreURL: URL {
        NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Favorites.sqlite")
    }

    @MainActor
    static func migrateIfNeeded(into context: ModelContext) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: migratedKey) else { return }
        guard FileManager.default.fileExists(atPath: legacyStoreURL.path) else {
            defaults.set(true, forKey: migratedKey)
            return
        }
        do {
            let count = try migrate(into: context)
            defaults.set(true, forKey: migratedKey)
            log("Migrated \(count) favorite location(s) from Core Data.")
        } catch {
            log("Could not migrate legacy favorites: \(error.localizedDescription)", level: .error)
        }
    }

    @MainActor
    private static func migrate(into context: ModelContext) throws -> Int {
        guard let modelURL = Bundle.main.url(forResource: "Favorites", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CocoaError(.fileReadNoSuchFile)
        }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        _ = try coordinator.addPersistentStore(type: .sqlite, at: legacyStoreURL,
                                               options: [NSReadOnlyPersistentStoreOption: true])
        let legacyContext = NSManagedObjectContext(.mainQueue)
        legacyContext.persistentStoreCoordinator = coordinator

        let request = NSFetchRequest<NSManagedObject>(entityName: "FavoriteLocation")
        request.sortDescriptors = [NSSortDescriptor(key: "viewIndex", ascending: true)]
        let legacyLocations = try legacyContext.fetch(request)

        for (locationIndex, legacyLocation) in legacyLocations.enumerated() {
            let location = FavoriteLocation(
                busStopCode: legacyLocation.value(forKey: "busStopCode") as? String,
                nickname: legacyLocation.value(forKey: "nickname") as? String,
                usesLiveBusStopData: legacyLocation.value(forKey: "usesLiveBusStopData") as? Bool ?? false,
                viewIndex: locationIndex
            )
            context.insert(location)
            // The legacy relationship is ordered, which is the order the user arranged services in
            let legacyServices = (legacyLocation.value(forKey: "busServices") as? NSOrderedSet)?
                .array as? [NSManagedObject] ?? []
            for (serviceIndex, legacyService) in legacyServices.enumerated() {
                let busService = FavoriteBusService(
                    busStopCode: legacyService.value(forKey: "busStopCode") as? String,
                    serviceNo: legacyService.value(forKey: "serviceNo") as? String,
                    viewIndex: serviceIndex
                )
                context.insert(busService)
                busService.location = location
            }
        }
        try context.save()
        return legacyLocations.count
    }

}
