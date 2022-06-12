//
//  DataFetchers.swift
//  Buses
//
//  Created by 堅書 on 2022/04/14.
//

import Foundation

func fetchAllBusStops() async throws -> [BusStop] {
    var allBusStops: [BusStop] = []
    var currentBusStopList: BSBusStopList?
    var currentSkipIndex: Int = 0
    repeat {
        currentBusStopList = try await fetchBusStops(from: currentSkipIndex)
        if let busStopList = currentBusStopList {
            allBusStops.append(contentsOf: busStopList.busStops)
            currentSkipIndex += 500
        } else {
            currentBusStopList = BSBusStopList(metadata: "", busStops: [])
        }
    } while currentBusStopList?.busStops.count != 0
    return allBusStops
}

func fetchBusStops(from firstIndex: Int = 0) async throws -> BSBusStopList {
    let busStopList: BSBusStopList = try await withCheckedThrowingContinuation({ continuation in
        var request = URLRequest(url: URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=\(firstIndex)")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let apiKey = apiKeys["LTA"] {
            request.addValue(apiKey, forHTTPHeaderField: "AccountKey")
        } else {
            log("API key is missing! Request may fail ungracefully.", level: .error)
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                log(error.localizedDescription, level: .error)
                continuation.resume(throwing: error)
            }
            if let data = data {
                if let busStopList: BSBusStopList = decode(fromData: data) {
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
        }.resume()
    })
    return busStopList
}
