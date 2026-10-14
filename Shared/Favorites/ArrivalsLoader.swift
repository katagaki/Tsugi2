//
//  ArrivalsLoader.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import Foundation

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
