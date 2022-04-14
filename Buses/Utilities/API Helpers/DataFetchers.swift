//
//  DataFetchers.swift
//  Buses
//
//  Created by 堅書 on 2022/04/14.
//

import Foundation

func fetchBusStops() async throws -> BSBusStopList {
    let busStopList: BSBusStopList = try await withCheckedThrowingContinuation({ continuation in
        var request = URLRequest(url: URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusStops")!)
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
                    log("Fetched bus stop data from the API.", level: .info)
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
