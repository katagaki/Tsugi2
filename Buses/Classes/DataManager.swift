//
//  DataManager.swift
//  Buses
//
//  Created by 堅書 on 15/4/23.
//

import Foundation
import SwiftUI

class DataManager: ObservableObject {

    let defaults = UserDefaults.standard

    @Published var busStopList: BusStopList = BusStopList()
    @Published var shouldReloadBusStopList: Bool = false

    @Published var busRouteList: BusRouteList = BusRouteList()
    @Published var isBusRouteListLoaded: Bool = false

    @Published var busRoutePolylines: [BusRoutePolyline] = []
    @Published var isBusRoutePolylinesLoaded: Bool = false

    @Published var updatedDate: String = ""
    @Published var updatedTime: String = ""

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
        if let busRoutePolyline = busRoutePolylines.filter({ busRoutePolyline in
            busRoutePolyline.serviceNo == serviceNo
        }).first {
            return busRoutePolyline.encodedPolylines[direction.rawValue - 1]
        }
        return ""
    }

    func reloadBusStopListFromServer() async throws {
        busStopList.busStops = try await getAllBusStops()
        if defaults.bool(forKey: "UseProperText") {
            busStopList.busStops = await withTaskGroup(of: BusStop.self, returning: [BusStop].self, body: { group in
                var busStops: [BusStop] = []
                for busStop in busStopList.busStops {
                    group.addTask {
                        busStop.description = properName(for: busStop.name())
                        busStop.roadName = properName(for: busStop.roadName ??
                                                      localized("Shared.BusStop.Description.None"))
                        return busStop
                    }
                }
                for await result in group {
                    busStops.append(result)
                }
                return busStops
            })
            log("ProperText was applied.")
        }
        busStopList.busStops.sort(by: { lhs, rhs in
            lhs.description?.lowercased() ?? "" < rhs.description?.lowercased() ?? ""
        })
        setStoredBusStopList(busStopList)
        setStoredBusStopListUpdatedDate(Date.now)
        setLastUpdatedTime()
        DispatchQueue.main.async { [self] in
            shouldReloadBusStopList = false
        }
    }

    func reloadBusStopListFromStoredMemory(_ storedBusStopListJSON: String,
                                           updatedAt storedUpdatedDate: Date) async throws {
        if let storedBusStopList: BusStopList = decode(fromData: storedBusStopListJSON.data(using: .utf8) ?? Data()) {
            busStopList.metadata = storedBusStopList.metadata
            busStopList.busStops = storedBusStopList.busStops
            setLastUpdatedTime(storedUpdatedDate)
            log("Fetched bus stop data from memory with \(busStopList.busStops.count) bus stop(s).")
        } else {
            log("Could not decode stored data successfully, re-fetching bus stop data from server...", level: .error)
            try await reloadBusStopListFromServer()
        }
        DispatchQueue.main.async { [self] in
            shouldReloadBusStopList = false
        }
    }

    func reloadBusRoutesFromServer() async throws {
        if !isBusRouteListLoaded {
            let busRouteListFetched = try await getAllBusRoutes()
            busRouteList.busRoutePoints = busRouteListFetched.busRoutePoints
            busRouteList.metadata = busRouteListFetched.metadata
            isBusRouteListLoaded = true
        }
    }

    func reloadBusRoutePolylinesFromServer() async throws {
        if !isBusRoutePolylinesLoaded {
            busRoutePolylines = try await getAllBusRoutePolylines()
            isBusRoutePolylinesLoaded = true
        }
    }

    func setLastUpdatedTime(_ date: Date = Date.now) {
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        timeFormatter.timeStyle = .medium
        DispatchQueue.main.async { [self] in
            updatedDate = dateFormatter.string(from: date)
            updatedTime = timeFormatter.string(from: date)
        }
    }

    func setStoredBusStopList(_ newValue: BusStopList) {
        defaults.set(encode(newValue), forKey: "StoredBusStopList")
    }

    func setStoredBusStopListUpdatedDate(_ newValue: Date) {
        defaults.set(newValue, forKey: "StoredBusStopListUpdatedDate")
    }

    func storedBusStopList() -> String? {
        return defaults.string(forKey: "StoredBusStopList")
    }

    func storedBusStopListUpdatedDate() -> Date? {
        return defaults.object(forKey: "StoredBusStopListUpdatedDate") as? Date
    }

}
