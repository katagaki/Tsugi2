//
//  FavoritesManager.swift
//  Buses
//
//  Created by Justin Xin on 2022/06/18.
//

import CoreData
import Foundation

class FavoritesManager {
    
    static let shared = FavoritesManager()
    private init() { }
    
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
