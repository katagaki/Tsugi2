//
//  DataFetchers.swift
//  Buses
//
//  Created by 堅書 on 2022/04/14.
//

import Foundation

// MARK: BusStops API

func fetchAllBusStops() async throws -> [BusStop] {
    var allBusStops: [BusStop] = []
    var currentBusStopList: BusStopList?
    var currentSkipIndex: Int = 0
    repeat {
        currentBusStopList = try await fetchBusStops(from: currentSkipIndex)
        if let busStopList = currentBusStopList {
            allBusStops.append(contentsOf: busStopList.busStops)
            currentSkipIndex += 500
        } else {
            currentBusStopList = BusStopList()
        }
    } while currentBusStopList?.busStops.count != 0
    return allBusStops
}

func fetchBusStops(from firstIndex: Int = 0) async throws -> BusStopList {
    let busStopList: BusStopList = try await withCheckedThrowingContinuation({ continuation in
        var request = URLRequest(url: URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=\(firstIndex)")!)
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

// MARK: BusArrivalv2 API

func fetchBusArrivals(for stopCode: String) async throws -> BusStop {
    let busArrivals: BusStop = try await withCheckedThrowingContinuation({ continuation in
        var request = URLRequest(url: URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=\(stopCode)")!)
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

