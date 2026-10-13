//
//  API.swift
//  Buses
//
//  Created by 堅書 on 2022/04/14.
//

import Foundation

let apiEndpoint = "https://datamall2.mytransport.sg/ltaodataservice"
var apiKeys: [String: String] = [:]

func loadAPIKeys() {
    if let storedAPIKeys = Bundle.main.plist(named: "APIKeys") {
        apiKeys = storedAPIKeys
        log("Loaded \(apiKeys.count) API key(s).")
    } else {
        log("Could not load API keys.", level: .error)
    }
}

func getAllBusStops() async throws -> [BusStop] {
    var allBusStops: [BusStop] = []
    var currentBusStopList: BusStopList?
    var currentSkipIndex: Int = 0
    repeat {
        currentBusStopList = try await getBusStops(from: currentSkipIndex)
        if let busStopList = currentBusStopList {
            allBusStops.append(contentsOf: busStopList.busStops)
            currentSkipIndex += 500
        } else {
            currentBusStopList = BusStopList()
        }
    } while currentBusStopList?.busStops.count != 0
    return allBusStops
}

func getBusStops(from firstIndex: Int = 0) async throws -> BusStopList {
    let busStopList: BusStopList = try await withCheckedThrowingContinuation({ continuation in
        var request = URLRequest(url: URL(string: "\(apiEndpoint)/BusStops?$skip=\(firstIndex)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let apiKey = apiKeys["LTA"] {
            request.addValue(apiKey, forHTTPHeaderField: "AccountKey")
        } else {
            log("API key is missing! Request may fail ungracefully.", level: .error)
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                log(error.localizedDescription, level: .error)
                log(String(data: data ?? Data(), encoding: .utf8) ?? "No data found.")
                continuation.resume(throwing: error)
            } else {
                if let data = data {
                    if let busStopList: BusStopList = decode(fromData: data) {
                        log("Fetched bus stop data from the API for skip index \(firstIndex).")
                        continuation.resume(returning: busStopList)
                    } else {
                        log("Could not decode the data successfully.", level: .error)
                        continuation.resume(throwing: NSError(domain: "", code: 1))
                    }
                } else {
                    log("No data was returned.", level: .error)
                    continuation.resume(throwing: NSError(domain: "", code: 1))
                }
            }
        }.resume()
    })
    return busStopList
}

func getBusArrivals(for stopCode: String) async throws -> BusStop {
    let busArrivals: BusStop = try await withCheckedThrowingContinuation({ continuation in
        var request = URLRequest(url: URL(string: "\(apiEndpoint)/v3/BusArrival?BusStopCode=\(stopCode)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let apiKey = apiKeys["LTA"] {
            request.addValue(apiKey, forHTTPHeaderField: "AccountKey")
        } else {
            log("API key is missing! Request may fail ungracefully.", level: .error)
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                log(error.localizedDescription, level: .error)
                log(String(data: data ?? Data(), encoding: .utf8) ?? "No data found.")
                continuation.resume(throwing: error)
            } else {
                if let data = data {
                    if let busArrivals: BusStop = decode(fromData: data) {
                        log("Fetched bus arrival data for \(stopCode) from the API.")
                        continuation.resume(returning: busArrivals)
                    } else {
                        log("Could not decode the data successfully.", level: .error)
                        continuation.resume(throwing: NSError(domain: "", code: 1))
                    }
                } else {
                    log("No data was returned.", level: .error)
                    continuation.resume(throwing: NSError(domain: "", code: 1))
                }
            }
        }.resume()
    })
    return busArrivals
}

func getAllBusRoutes() async throws -> BusRouteList {
    return try await withThrowingTaskGroup(of: BusRouteList.self, body: { group in
        let finalBusRouteList = BusRouteList()
        // TODO: Bus route count may increase in the future, setting fetch at 30,000 for now
        for index in 0...60 {
            group.addTask {
                // Add rolling delay to get around API rate limit
                let sleepTime = UInt64(index / 10) * UInt64(1100000000)
                if sleepTime > 0 {
                    try await Task.sleep(nanoseconds: sleepTime)
                }
                let busRouteList = try await getBusRoutes(from: index * 500)
                return busRouteList
            }
        }
        let finalBusRoutePoints: [BusRoutePoint] = try await group.reduce(
            into: [BusRoutePoint](), { partialResult, busRouteList in
            partialResult.append(contentsOf: busRouteList.busRoutePoints)
        })
        finalBusRouteList.metadata = "processed.by.tsugi"
        finalBusRouteList.busRoutePoints = finalBusRoutePoints
        return finalBusRouteList
    })
}

func getBusRoutes(from firstIndex: Int = 0) async throws -> BusRouteList {
    let busRouteList: BusRouteList = try await withCheckedThrowingContinuation({ continuation in
        var request = URLRequest(url: URL(string: "\(apiEndpoint)/BusRoutes?$skip=\(firstIndex)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let apiKey = apiKeys["LTA"] {
            request.addValue(apiKey, forHTTPHeaderField: "AccountKey")
        } else {
            log("API key is missing! Request may fail ungracefully.", level: .error)
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                log(error.localizedDescription, level: .error)
                log(String(data: data ?? Data(), encoding: .utf8) ?? "No data found.")
                continuation.resume(throwing: error)
            } else {
                if let data = data {
                    if let busRouteList: BusRouteList = decode(fromData: data) {
                        log("Fetched bus route data from the API for skip index \(firstIndex).")
                        continuation.resume(returning: busRouteList)
                    } else {
                        log("Could not decode the data successfully.", level: .error)
                        continuation.resume(throwing: NSError(domain: "", code: 1))
                    }
                } else {
                    log("No data was returned.", level: .error)
                    continuation.resume(throwing: NSError(domain: "", code: 1))
                }
            }
        }.resume()
    })
    return busRouteList
}

func getAllBusRoutePolylines() async throws -> [BusRoutePolyline] {
    let busRoutePolylines: [BusRoutePolyline] = try await withCheckedThrowingContinuation({ continuation in
        var request = URLRequest(url: URL(string: "https://data.busrouter.sg/v1/routes.json")!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                log(error.localizedDescription, level: .error)
                log(String(data: data ?? Data(), encoding: .utf8) ?? "No data found.")
                continuation.resume(throwing: error)
            } else {
                if let data = data {
                    if let busRoutePolylinesRawData: [String: [String]] = decode(fromData: data) {
                        log("Fetched bus route polylines.")
                        var busRoutePolylines: [BusRoutePolyline] = []
                        for (key, value) in busRoutePolylinesRawData {
                            var busRoutePolyline = BusRoutePolyline(serviceNo: "", encodedPolylines: [])
                            busRoutePolyline.serviceNo = key
                            busRoutePolyline.encodedPolylines = value
                            busRoutePolylines.append(busRoutePolyline)
                        }
                        log("Successfully decoded polyline data to compatible format.")
                        continuation.resume(returning: busRoutePolylines)
                    } else {
                        log("Could not decode the data successfully.", level: .error)
                        continuation.resume(throwing: NSError(domain: "", code: 1))
                    }
                } else {
                    log("No data was returned.", level: .error)
                    continuation.resume(throwing: NSError(domain: "", code: 1))
                }
            }
        }.resume()
    })
    return busRoutePolylines
}

func getAllBusServices() async throws -> [BusService] {
    var allBusServices: [BusService] = []
    var currentBusServiceList: BusServiceList?
    var currentSkipIndex: Int = 0
    repeat {
        currentBusServiceList = try await getBusServices(from: currentSkipIndex)
        if let busServiceList = currentBusServiceList {
            allBusServices.append(contentsOf: busServiceList.busServices)
            currentSkipIndex += 500
        } else {
            currentBusServiceList = BusServiceList()
        }
    } while currentBusServiceList?.busServices.count != 0
    return allBusServices
}

func getBusServices(from firstIndex: Int = 0) async throws -> BusServiceList {
    let busServiceList: BusServiceList = try await withCheckedThrowingContinuation({ continuation in
        var request = URLRequest(url: URL(string: "\(apiEndpoint)/BusServices?$skip=\(firstIndex)")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let apiKey = apiKeys["LTA"] {
            request.addValue(apiKey, forHTTPHeaderField: "AccountKey")
        } else {
            log("API key is missing! Request may fail ungracefully.", level: .error)
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                log(error.localizedDescription, level: .error)
                log(String(data: data ?? Data(), encoding: .utf8) ?? "No data found.")
                continuation.resume(throwing: error)
            } else {
                if let data = data {
                    if let busServiceList: BusServiceList = decode(fromData: data) {
                        log("Fetched bus service data from the API for skip index \(firstIndex).")
                        continuation.resume(returning: busServiceList)
                    } else {
                        log("Could not decode the data successfully.", level: .error)
                        continuation.resume(throwing: NSError(domain: "", code: 1))
                    }
                } else {
                    log("No data was returned.", level: .error)
                    continuation.resume(throwing: NSError(domain: "", code: 1))
                }
            }
        }.resume()
    })
    return busServiceList
}
