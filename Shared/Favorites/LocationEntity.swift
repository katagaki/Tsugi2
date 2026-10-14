//
//  LocationEntity.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import AppIntents
import SwiftData

/// A favorite location, used to configure widgets and by Siri and Shortcuts.
struct LocationEntity: AppEntity {

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Widget.Location"
    static let defaultQuery = LocationQuery()

    let id: UUID
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    init(_ location: FavoriteLocation) {
        id = location.identifier
        name = location.nickname ?? location.busStopCode ?? ""
    }

}

struct LocationQuery: EntityQuery {

    func entities(for identifiers: [LocationEntity.ID]) async throws -> [LocationEntity] {
        try await locations().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [LocationEntity] {
        try await locations()
    }

    func defaultResult() async -> LocationEntity? {
        try? await locations().first
    }

    @MainActor
    private func locations() throws -> [LocationEntity] {
        try FavoriteLocation.all().map(LocationEntity.init)
    }

}

extension FavoriteLocation {

    @MainActor
    static func all() throws -> [FavoriteLocation] {
        try FavoritesStore.container.mainContext.fetch(FetchDescriptor<FavoriteLocation>(
            sortBy: [SortDescriptor(\.viewIndex)]
        ))
    }

}
