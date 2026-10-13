//
//  API.swift
//  Buses
//
//  Created by 堅書 on 2022/04/14.
//

import Foundation

protocol TransitAPI: Sendable {
    func busStops() async throws -> [BusStop]
    func busArrivals(for stopCode: String) async throws -> BusStop
    func busRoutes() async throws -> BusRouteList
    func busRoutePolylines() async throws -> [BusRoutePolyline]
}

enum TransitAPIError: Error {
    case badResponse(statusCode: Int)
    case undecodable
}

/// The data source used throughout the app and extension.
/// Falls back to mock data when no LTA DataMall key is available, or when `UseMockData` is set.
var transit: TransitAPI {
    if UserDefaults.shared.bool(forKey: "UseMockData") || apiKeys["LTA"] == nil {
        return MockTransitAPI()
    }
    return LTADataMallAPI()
}

/// Only the app bundles `APIKeys.plist`, so the app shares it with the extension through the App Group.
nonisolated(unsafe) var apiKeys: [String: String] = {
    if let bundledKeys: [String: String] = Bundle.main.plist(named: "APIKeys") {
        UserDefaults.shared.set(bundledKeys, forKey: "APIKeys")
        return bundledKeys
    }
    return UserDefaults.shared.dictionary(forKey: "APIKeys") as? [String: String] ?? [:]
}()

struct LTADataMallAPI: TransitAPI {

    let endpoint = "https://datamall2.mytransport.sg/ltaodataservice"
    let pageSize = 500

    func busStops() async throws -> [BusStop] {
        var allBusStops: [BusStop] = []
        var skip = 0
        while true {
            let page: BusStopList = try await get("BusStops?$skip=\(skip)")
            if page.busStops.isEmpty { break }
            allBusStops.append(contentsOf: page.busStops)
            skip += pageSize
        }
        log("Fetched \(allBusStops.count) bus stop(s) from the API.")
        return allBusStops
    }

    func busArrivals(for stopCode: String) async throws -> BusStop {
        return try await get("v3/BusArrival?BusStopCode=\(stopCode)")
    }

    func busRoutes() async throws -> BusRouteList {
        try await withThrowingTaskGroup(of: BusRouteList.self) { group in
            // TODO: Bus route count may increase in the future, setting fetch at 30,000 for now
            for index in 0...60 {
                group.addTask {
                    // Add rolling delay to get around API rate limit
                    try await Task.sleep(for: .seconds(Double(index / 10) * 1.1))
                    return try await get("BusRoutes?$skip=\(index * pageSize)")
                }
            }
            let busRouteList = BusRouteList()
            for try await page in group {
                busRouteList.busRoutePoints.append(contentsOf: page.busRoutePoints)
            }
            busRouteList.metadata = "processed.by.tsugi"
            return busRouteList
        }
    }

    func busRoutePolylines() async throws -> [BusRoutePolyline] {
        let url = URL(string: "https://data.busrouter.sg/v1/routes.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let rawPolylines: [String: [String]] = decode(fromData: data) else {
            throw TransitAPIError.undecodable
        }
        return rawPolylines.map { BusRoutePolyline(serviceNo: $0.key, encodedPolylines: $0.value) }
    }

    private func get<T: Decodable>(_ path: String) async throws -> T {
        var request = URLRequest(url: URL(string: "\(endpoint)/\(path)")!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let apiKey = apiKeys["LTA"] {
            request.addValue(apiKey, forHTTPHeaderField: "AccountKey")
        } else {
            log("API key is missing! Request may fail ungracefully.", level: .error)
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        if let response = response as? HTTPURLResponse, !(200..<300).contains(response.statusCode) {
            log("Request to \(path) failed with status \(response.statusCode).", level: .error)
            throw TransitAPIError.badResponse(statusCode: response.statusCode)
        }
        guard let decoded: T = decode(fromData: data) else {
            throw TransitAPIError.undecodable
        }
        return decoded
    }

}
