//
//  DeepLink.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import Foundation

/// Links into the app, used by widgets to open a specific bus.
enum DeepLink: Equatable {

    static let scheme = "tsugi2"

    case busService(serviceNo: String, busStopCode: String, locationName: String)

    var url: URL {
        var components = URLComponents()
        components.scheme = Self.scheme
        switch self {
        case .busService(let serviceNo, let busStopCode, let locationName):
            components.host = "service"
            components.queryItems = [URLQueryItem(name: "no", value: serviceNo),
                                     URLQueryItem(name: "stop", value: busStopCode),
                                     URLQueryItem(name: "name", value: locationName)]
        }
        return components.url ?? URL(string: "\(Self.scheme)://")!
    }

    init?(url: URL) {
        guard url.scheme == Self.scheme,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        let query = Dictionary((components.queryItems ?? []).map { ($0.name, $0.value ?? "") },
                               uniquingKeysWith: { first, _ in first })
        switch components.host {
        case "service":
            guard let serviceNo = query["no"], let busStopCode = query["stop"] else { return nil }
            self = .busService(serviceNo: serviceNo, busStopCode: busStopCode,
                               locationName: query["name"] ?? busStopCode)
        default:
            return nil
        }
    }

}
