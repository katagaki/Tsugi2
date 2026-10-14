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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge,
                            .accessoryRectangular, .accessoryCircular, .accessoryInline])
    }

}

// MARK: - Timeline

struct ServiceArrival: Identifiable, Hashable {
    var id: String { "\(busStopCode).\(serviceNo)" }
    let serviceNo: String
    let busStopCode: String
    let nextArrival: Date?
    let followingArrival: Date?
    let load: BusLoad?
}

struct ArrivalsEntry: TimelineEntry {

    enum Status {
        case loaded
        case noLocations
        case failed
    }

    let date: Date
    let status: Status
    var locationName: String = ""
    var services: [ServiceArrival] = []

    static let placeholder = ArrivalsEntry(date: .now, status: .loaded, locationName: "City Hall", services: [
        ServiceArrival(serviceNo: "7", busStopCode: "", nextArrival: .now.addingTimeInterval(120),
                       followingArrival: .now.addingTimeInterval(660), load: .seatsAvailable),
        ServiceArrival(serviceNo: "14", busStopCode: "", nextArrival: .now.addingTimeInterval(300),
                       followingArrival: .now.addingTimeInterval(1020), load: .standingAvailable),
        ServiceArrival(serviceNo: "36", busStopCode: "", nextArrival: .now.addingTimeInterval(480),
                       followingArrival: .now.addingTimeInterval(960), load: .seatsAvailable)
    ])

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
                          locationName: entry.locationName, services: entry.services)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }

    private func entry(for entity: LocationEntity?) async -> ArrivalsEntry {
        guard let location = await ArrivalsLoader.location(for: entity) else {
            return ArrivalsEntry(date: .now, status: .noLocations)
        }
        do {
            let services = try await ArrivalsLoader.arrivals(for: location)
            return ArrivalsEntry(date: .now, status: .loaded, locationName: location.name, services: services)
        } catch {
            log("Widget could not load arrivals: \(error.localizedDescription)", level: .error)
            return ArrivalsEntry(date: .now, status: .failed, locationName: location.name)
        }
    }

}

/// Reads favorites into plain values, then fetches arrivals for them.
enum ArrivalsLoader {

    struct Location {
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
            return ServiceArrival(serviceNo: serviceNo, busStopCode: busStopCode,
                                  nextArrival: nil, followingArrival: nil, load: nil)
        }
    }

    private static func serviceArrival(_ busService: BusService, at busStopCode: String) -> ServiceArrival {
        ServiceArrival(serviceNo: busService.serviceNo, busStopCode: busStopCode,
                       nextArrival: busService.nextBus?.estimatedArrivalTimeAsDate(),
                       followingArrival: busService.nextBus2?.estimatedArrivalTimeAsDate(),
                       load: busService.nextBus?.load)
    }

}
