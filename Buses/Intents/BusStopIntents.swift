//
//  BusStopIntents.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import AppIntents
import CoreLocation

/// Finds the bus stops closest to the user.
struct GetNearbyBusStopsIntent: AppIntent {

    static let title: LocalizedStringResource = "Intents.GetNearbyBusStops.Title"
    static let description = IntentDescription("Intents.GetNearbyBusStops.Description")

    /// Matches the radius of the Nearby section in the app.
    static let searchRadius: CLLocationDistance = 500.0
    static let resultLimit = 5

    func perform() async throws -> some IntentResult & ReturnsValue<[BusStopEntity]> & ProvidesDialog {
        let location = try await CurrentLocation.fetch()
        let nearest = try await BusStopDirectory.nearest(to: location, within: Self.searchRadius,
                                                         limit: Self.resultLimit)
        guard !nearest.isEmpty else {
            return .result(value: [], dialog: "Intents.Dialog.NoNearbyBusStops")
        }
        let names = nearest.map { busStop, distance in
            let distance = Measurement(value: distance, unit: UnitLength.meters)
                .formatted(.measurement(width: .abbreviated, usage: .road))
            return localized("Intents.Dialog.BusStopDistance", replacing: busStop.name(), distance)
        }
        let summary = localized("Intents.Dialog.NearbyBusStops",
                                replacing: ListFormatter.localizedString(byJoining: names))
        return .result(value: nearest.map { BusStopEntity($0.busStop) },
                       dialog: IntentDialog("\(summary)"))
    }

}

/// Shows a bus stop and its arrivals in the app.
struct OpenBusStopIntent: OpenIntent {

    static let title: LocalizedStringResource = "Intents.OpenBusStop.Title"
    static let description = IntentDescription("Intents.OpenBusStop.Description")

    @Parameter(title: "Intents.BusStop")
    var target: BusStopEntity

    @Dependency var navigationManager: NavigationManager

    @MainActor
    func perform() async throws -> some IntentResult {
        navigationManager.open(.busStop(target.busStop))
        return .result()
    }

}

/// A one-off location fix for intents, which run without the app's location manager.
enum CurrentLocation {

    static let timeout: Duration = .seconds(10)

    static func fetch() async throws -> CLLocation {
        let status = CLLocationManager().authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            throw IntentError.locationUnavailable
        }
        return try await withThrowingTaskGroup(of: CLLocation?.self) { group in
            group.addTask {
                for try await update in CLLocationUpdate.liveUpdates() {
                    if let location = update.location {
                        return location
                    }
                }
                return nil
            }
            group.addTask {
                try await Task.sleep(for: timeout)
                return nil
            }
            let location = try await group.next() ?? nil
            group.cancelAll()
            guard let location else {
                throw IntentError.locationUnavailable
            }
            return location
        }
    }

}
