//
//  BusStopEntity.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import AppIntents
import CoreLocation

/// A bus stop that Siri and Shortcuts can look up by name or code.
struct BusStopEntity: AppEntity {

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Intents.BusStop")
    static let defaultQuery = BusStopQuery()

    /// The five-digit bus stop code.
    let id: String
    let name: String
    let roadName: String?
    let latitude: Double?
    let longitude: Double?

    var displayRepresentation: DisplayRepresentation {
        let subtitle = [id, roadName].compactMap { $0 }.joined(separator: " · ")
        return DisplayRepresentation(title: "\(name)", subtitle: "\(subtitle)")
    }

    init(_ busStop: BusStop) {
        id = busStop.code
        name = busStop.name()
        roadName = busStop.roadName
        latitude = busStop.latitude
        longitude = busStop.longitude
    }

    var busStop: BusStop {
        let busStop = BusStop(code: id, description: name)
        busStop.roadName = roadName
        busStop.latitude = latitude
        busStop.longitude = longitude
        return busStop
    }

}

struct BusStopQuery: EntityStringQuery {

    func entities(for identifiers: [BusStopEntity.ID]) async throws -> [BusStopEntity] {
        try await BusStopDirectory.all()
            .filter { identifiers.contains($0.code) }
            .map(BusStopEntity.init)
    }

    func entities(matching string: String) async throws -> [BusStopEntity] {
        let searchTerm = string.trimmingCharacters(in: .whitespaces)
        return try await BusStopDirectory.all()
            .filter { $0.code == searchTerm || $0.matches(searchTerm) }
            .prefix(25)
            .map(BusStopEntity.init)
    }

    /// The bus stops in the user's favorites, as those are the ones they are most likely to ask about.
    func suggestedEntities() async throws -> [BusStopEntity] {
        let favoriteCodes = await MainActor.run {
            let locations = (try? FavoriteLocation.all()) ?? []
            return locations.flatMap { location in
                [location.busStopCode] + location.sortedBusServices.map(\.busStopCode)
            }
            .compactMap { $0 }
        }
        let busStops = try await BusStopDirectory.all()
        var seenCodes = Set<String>()
        return favoriteCodes.compactMap { code in
            guard seenCodes.insert(code).inserted else { return nil }
            return busStops.first { $0.code == code }.map(BusStopEntity.init)
        }
    }

}

/// Bus stops for intents, which can run before the app has loaded its own copy.
enum BusStopDirectory {

    static func all() async throws -> [BusStop] {
        if let cached = TransitCache.load([BusStop].self, from: .busStops) {
            return cached.value
        }
        do {
            return try await transit.busStops()
        } catch {
            throw IntentError.busStopsUnavailable
        }
    }

    static func nearest(to location: CLLocation, within radius: CLLocationDistance,
                        limit: Int) async throws -> [(busStop: BusStop, distance: CLLocationDistance)] {
        try await all()
            .map { ($0, location.distanceTo(busStop: $0)) }
            .filter { $0.1 <= radius }
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map { ($0.0, $0.1) }
    }

}

/// Errors shown to the user by Siri and Shortcuts.
enum IntentError: Error, CustomLocalizedStringResourceConvertible {

    case busStopsUnavailable
    case arrivalsUnavailable
    case locationUnavailable

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .busStopsUnavailable: "Intents.Error.BusStopsUnavailable"
        case .arrivalsUnavailable: "Intents.Error.ArrivalsUnavailable"
        case .locationUnavailable: "Intents.Error.LocationUnavailable"
        }
    }

}
