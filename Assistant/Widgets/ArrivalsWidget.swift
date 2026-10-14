//
//  ArrivalsWidget.swift
//  Assistant
//
//  Created by 堅書 on 2026/10/14.
//

import AppIntents
import SwiftUI
import WidgetKit

struct ArrivalsWidget: Widget {

    static let kind = "ArrivalsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: SelectLocationIntent.self,
                               provider: ArrivalsProvider()) { entry in
            ArrivalsWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Widget.Title")
        .description("Widget.Description")
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge,
                            .accessoryRectangular, .accessoryCircular, .accessoryInline])
    }

}

// MARK: - Timeline

struct ServiceArrival: Identifiable, Hashable {

    struct Arrival: Hashable {
        let date: Date
        let load: BusLoad?
        let feature: BusFeature?
        let type: BusType?
    }

    var id: String { "\(busStopCode).\(serviceNo)" }
    let serviceNo: String
    let busStopCode: String
    /// The next few buses, soonest first.
    let arrivals: [Arrival]

}

struct ArrivalsEntry: TimelineEntry {

    enum Status {
        case loaded
        case noLocations
        case failed
    }

    let date: Date
    let status: Status
    var locationID: UUID?
    var locationName: String = ""
    var services: [ServiceArrival] = []
    /// The page the user moved to with the page buttons. Views clamp it to the pages they have.
    var page: Int = 0

    static let placeholder = ArrivalsEntry(date: .now, status: .loaded, locationName: "City Hall", services: [
        sample("7", in: 2, load: .seatsAvailable, type: .doubleDeck),
        sample("14", in: 5, load: .standingAvailable, type: .doubleDeck),
        sample("36", in: 8, load: .seatsAvailable, type: .doubleDeck),
        sample("61", in: 11, load: .limitedStanding, type: .singleDeck)
    ])

    private static func sample(_ serviceNo: String, in minutes: Double,
                               load: BusLoad, type: BusType) -> ServiceArrival {
        ServiceArrival(serviceNo: serviceNo, busStopCode: "", arrivals: [
            ServiceArrival.Arrival(date: .now.addingTimeInterval(minutes * 60), load: load,
                                   feature: .wheelchairAccessible, type: type)
        ])
    }

}

struct ArrivalsProvider: AppIntentTimelineProvider {

    /// The timeline has one entry per minute so that "X min" labels stay correct between refreshes.
    static let timelineLength = 15

    func placeholder(in context: Context) -> ArrivalsEntry {
        .placeholder
    }

    func snapshot(for configuration: SelectLocationIntent, in context: Context) async -> ArrivalsEntry {
        if context.isPreview {
            return .placeholder
        }
        return await entry(for: configuration.location)
    }

    func timeline(for configuration: SelectLocationIntent, in context: Context) async -> Timeline<ArrivalsEntry> {
        let entry = await entry(for: configuration.location)
        guard entry.status == .loaded else {
            return Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(5 * 60)))
        }
        let entries = (0..<Self.timelineLength).map { minute in
            ArrivalsEntry(date: entry.date.addingTimeInterval(TimeInterval(minute * 60)), status: entry.status,
                          locationID: entry.locationID, locationName: entry.locationName,
                          services: entry.services, page: entry.page)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }

    private func entry(for entity: LocationEntity?) async -> ArrivalsEntry {
        guard let location = await ArrivalsLoader.location(for: entity) else {
            return ArrivalsEntry(date: .now, status: .noLocations)
        }
        do {
            let services = try await ArrivalsLoader.arrivals(for: location)
            return ArrivalsEntry(date: .now, status: .loaded, locationID: location.id, locationName: location.name,
                                 services: services, page: WidgetPages.page(for: location.id))
        } catch {
            log("Widget could not load arrivals: \(error.localizedDescription)", level: .error)
            return ArrivalsEntry(date: .now, status: .failed, locationName: location.name)
        }
    }

}

/// Reads favorites into plain values, then fetches arrivals for them.
enum ArrivalsLoader {

    struct Location {
        let id: UUID
        let name: String
        let busStopCode: String
        let usesLiveBusStopData: Bool
        /// Pairs of bus stop code and service number, in the order the user arranged them.
        let services: [(busStopCode: String, serviceNo: String)]
    }

    @MainActor
    static func location(for entity: LocationEntity?) -> Location? {
        guard let locations = try? FavoriteLocation.all(),
              let location = locations.first(where: { $0.identifier == entity?.id }) ?? locations.first else {
            return nil
        }
        return Location(
            id: location.identifier,
            name: location.nickname ?? location.busStopCode ?? "",
            busStopCode: location.busStopCode ?? "",
            usesLiveBusStopData: location.usesLiveBusStopData,
            services: location.sortedBusServices.compactMap { service in
                guard let busStopCode = service.busStopCode, let serviceNo = service.serviceNo else { return nil }
                return (busStopCode, serviceNo)
            }
        )
    }

    static func arrivals(for location: Location) async throws -> [ServiceArrival] {
        if location.usesLiveBusStopData {
            let busStop = try await transit.busArrivals(for: location.busStopCode)
            return (busStop.arrivals ?? [])
                .sorted { $0.serviceNo.toInt() ?? 9999 < $1.serviceNo.toInt() ?? 9999 }
                .map { serviceArrival($0, at: location.busStopCode) }
        }
        var busStops: [String: BusStop] = [:]
        for busStopCode in Set(location.services.map(\.busStopCode)) {
            busStops[busStopCode] = try await transit.busArrivals(for: busStopCode)
        }
        return location.services.map { busStopCode, serviceNo in
            if let busService = busStops[busStopCode]?.arrivals?.first(where: { $0.serviceNo == serviceNo }) {
                return serviceArrival(busService, at: busStopCode)
            }
            return ServiceArrival(serviceNo: serviceNo, busStopCode: busStopCode, arrivals: [])
        }
    }

    private static func serviceArrival(_ busService: BusService, at busStopCode: String) -> ServiceArrival {
        let arrivals = [busService.nextBus, busService.nextBus2, busService.nextBus3].compactMap { arrivalInfo in
            arrivalInfo?.estimatedArrivalTimeAsDate().map { date in
                ServiceArrival.Arrival(date: date, load: arrivalInfo?.load,
                                       feature: arrivalInfo?.feature, type: arrivalInfo?.type)
            }
        }
        return ServiceArrival(serviceNo: busService.serviceNo, busStopCode: busStopCode, arrivals: arrivals)
    }

}

/// Remembers which page of services each location's widgets are showing.
enum WidgetPages {

    static func page(for locationID: UUID) -> Int {
        UserDefaults.shared.integer(forKey: key(for: locationID))
    }

    static func setPage(_ page: Int, for locationID: UUID) {
        UserDefaults.shared.set(max(page, 0), forKey: key(for: locationID))
    }

    private static func key(for locationID: UUID) -> String {
        "WidgetPage.\(locationID.uuidString)"
    }

}
