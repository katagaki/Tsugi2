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
