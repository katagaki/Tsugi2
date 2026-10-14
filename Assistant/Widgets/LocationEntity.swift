//
//  LocationEntity.swift
//  Assistant
//
//  Created by 堅書 on 2026/10/14.
//

import AppIntents
import SwiftData

/// A favorite location that a widget can be configured to show.
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

struct SelectLocationIntent: WidgetConfigurationIntent {

    static let title: LocalizedStringResource = "Widget.SelectLocation"
    static let description = IntentDescription("Widget.Description")

    @Parameter(title: "Widget.Location")
    var location: LocationEntity?

}

/// Reloads a widget's arrival times. WidgetKit refreshes the timeline after the intent runs.
struct RefreshArrivalsIntent: AppIntent {

    static let title: LocalizedStringResource = "LiveActivity.Refresh"
    static let isDiscoverable = false

    func perform() async throws -> some IntentResult {
        return .result()
    }

}

/// Shows the next page of services. WidgetKit refreshes the timeline after the intent runs.
struct NextPageIntent: AppIntent {

    static let title: LocalizedStringResource = "Widget.NextPage"
    static let isDiscoverable = false

    @Parameter(title: "Widget.Location")
    var locationID: String

    init() {
        // Required by AppIntent
    }

    init(locationID: UUID) {
        self.locationID = locationID.uuidString
    }

    func perform() async throws -> some IntentResult {
        if let locationID = UUID(uuidString: locationID) {
            WidgetPages.advance(for: locationID)
        }
        return .result()
    }

}
