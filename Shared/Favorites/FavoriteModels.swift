//
//  FavoriteModels.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import Foundation
import SwiftData

@Model
final class FavoriteLocation {
    /// Stable identifier used by widgets to refer to this location.
    var identifier: UUID = UUID()
    var busStopCode: String?
    var nickname: String?
    var usesLiveBusStopData: Bool = false
    var viewIndex: Int = 0
    @Relationship(deleteRule: .cascade, inverse: \FavoriteBusService.location)
    var busServices: [FavoriteBusService] = []

    init(busStopCode: String?, nickname: String?, usesLiveBusStopData: Bool = false, viewIndex: Int = 0) {
        self.busStopCode = busStopCode
        self.nickname = nickname
        self.usesLiveBusStopData = usesLiveBusStopData
        self.viewIndex = viewIndex
    }

    /// SwiftData relationships are unordered, so order is kept in `viewIndex`.
    var sortedBusServices: [FavoriteBusService] {
        busServices.sorted { $0.viewIndex < $1.viewIndex }
    }
}

@Model
final class FavoriteBusService {
    var busStopCode: String?
    var serviceNo: String?
    var viewIndex: Int = 0
    var location: FavoriteLocation?

    init(busStopCode: String?, serviceNo: String?, viewIndex: Int = 0) {
        self.busStopCode = busStopCode
        self.serviceNo = serviceNo
        self.viewIndex = viewIndex
    }
}

enum FavoritesStore {

    /// Stored in the App Group so widgets and Live Activities can read favorites.
    static let container: ModelContainer = {
        let schema = Schema([FavoriteLocation.self, FavoriteBusService.self])
        // An explicit URL rather than groupContainer:, which traps when the App Group is unavailable
        let directory = AppGroup.containerURL.appending(path: "Library/Application Support",
                                                         directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let configuration = ModelConfiguration("Favorites", schema: schema,
                                               url: directory.appending(path: "Favorites.store"))
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            log("Could not open favorites store: \(error.localizedDescription)", level: .error)
            // swiftlint:disable:next force_try
            return try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        }
    }()

}
