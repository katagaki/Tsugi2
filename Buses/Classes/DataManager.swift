//
//  DataManager.swift
//  Buses
//
//  Created by 堅書 on 15/4/23.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class DataManager {

    @ObservationIgnored let defaults = UserDefaults.standard

    var busStopList: BusStopList = BusStopList()
    var shouldReloadBusStopList: Bool = false

    var busRouteList: BusRouteList = BusRouteList()
    var isBusRouteListLoaded: Bool = false

    var busRoutePolylines: [BusRoutePolyline] = []
    var isBusRoutePolylinesLoaded: Bool = false

    var updatedDate: String = ""
    var updatedTime: String = ""

    var busStops: [BusStop] {
        get {
            return busStopList.busStops
        }
        set(newValue) {
            busStopList.busStops = newValue
        }
    }

    var busRoutePoints: [BusRoutePoint] {
        return busRouteList.busRoutePoints
    }

    func busStop(code: String) -> BusStop? {
        return busStops.first { busStop in
            busStop.code == code
        }
    }

    func busRoute(for serviceNo: String, direction: BusRouteDirection) -> [BusRoutePoint] {
        var filteredBusRoutePoints: [BusRoutePoint]
        filteredBusRoutePoints = busRouteList.busRoutePoints.filter { point in
            point.serviceNo == serviceNo && point.direction == direction
        }
        if filteredBusRoutePoints.count == 0 {
            filteredBusRoutePoints = busRouteList.busRoutePoints.filter { point in
                point.serviceNo == serviceNo
            }
        }
        filteredBusRoutePoints.sort { lhs, rhs in
            lhs.stopSequence < rhs.stopSequence
        }
        return filteredBusRoutePoints
    }

    func busRoutePolyline(for serviceNo: String, direction: BusRouteDirection) -> String {
        if let busRoutePolyline = busRoutePolylines.first(where: { $0.serviceNo == serviceNo }),
           busRoutePolyline.encodedPolylines.indices.contains(direction.rawValue - 1) {
            return busRoutePolyline.encodedPolylines[direction.rawValue - 1]
        }
        return ""
    }

    /// Loads bus stops from the cache, going to the server when the cache is missing or stale.
    /// A stale cache is still used when the server cannot be reached.
    func reloadBusStopList(forceServer: Bool = false) async throws {
        let cached = TransitCache.load([BusStop].self, from: .busStops)
        if !forceServer, let cached, !cached.isStale {
            busStopList.busStops = cached.value
            setLastUpdatedTime(cached.updatedAt)
            log("Loaded \(cached.value.count) bus stop(s) from cache.")
        } else {
            do {
                try await reloadBusStopListFromServer()
            } catch {
                guard let cached else { throw error }
                busStopList.busStops = cached.value
                setLastUpdatedTime(cached.updatedAt)
                log("Could not refresh bus stops, using cache from \(cached.updatedAt).", level: .error)
            }
        }
        shouldReloadBusStopList = false
    }

    private func reloadBusStopListFromServer() async throws {
        var busStops = try await transit.busStops()
        if defaults.bool(forKey: SettingsKey.useProperText) {
            busStops = await withTaskGroup(of: BusStop.self, returning: [BusStop].self, body: { group in
                for busStop in busStops {
                    group.addTask {
                        busStop.originalDescription = busStop.description
                        busStop.description = properName(for: busStop.name())
                        busStop.roadName = properName(for: busStop.roadName ??
                                                      localized("Shared.BusStop.Description.None"))
                        return busStop
                    }
                }
                var busStops: [BusStop] = []
                for await result in group {
                    busStops.append(result)
                }
                return busStops
            })
            log("ProperText was applied.")
        }
        busStops.sort(by: { lhs, rhs in
            lhs.description?.lowercased() ?? "" < rhs.description?.lowercased() ?? ""
        })
        busStopList.busStops = busStops
        TransitCache.store(busStops, as: .busStops)
        setLastUpdatedTime()
        log("Reloaded \(busStops.count) bus stop(s) from server.")
    }

    func reloadBusRoutes() async throws {
        guard !isBusRouteListLoaded else { return }
        let cached = TransitCache.load(BusRouteList.self, from: .busRoutes)
        if let cached, !cached.isStale {
            busRouteList = cached.value
        } else {
            do {
                let busRouteListFetched = try await transit.busRoutes()
                TransitCache.store(busRouteListFetched, as: .busRoutes)
                busRouteList = busRouteListFetched
            } catch {
                guard let cached else { throw error }
                busRouteList = cached.value
            }
        }
        isBusRouteListLoaded = true
    }

    func reloadBusRoutePolylines() async throws {
        guard !isBusRoutePolylinesLoaded else { return }
        let cached = TransitCache.load([BusRoutePolyline].self, from: .busRoutePolylines)
        if let cached, !cached.isStale {
            busRoutePolylines = cached.value
        } else {
            do {
                let busRoutePolylinesFetched = try await transit.busRoutePolylines()
                TransitCache.store(busRoutePolylinesFetched, as: .busRoutePolylines)
                busRoutePolylines = busRoutePolylinesFetched
            } catch {
                guard let cached else { throw error }
                busRoutePolylines = cached.value
            }
        }
        isBusRoutePolylinesLoaded = true
    }

    func setLastUpdatedTime(_ date: Date = Date.now) {
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        timeFormatter.timeStyle = .medium
        updatedDate = dateFormatter.string(from: date)
        updatedTime = timeFormatter.string(from: date)
    }

}
