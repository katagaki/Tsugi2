//
//  TransitCache.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import Foundation

/// Stores slow-changing transit data as JSON in the App Group caches directory,
/// so that it survives launches and can be read by the extension.
enum TransitCache {

    enum Entry: String, CaseIterable {
        case busStops = "BusStops"
        case busRoutes = "BusRoutes"
        case busRoutePolylines = "BusRoutePolylines"
    }

    struct Cached<Value> {
        let value: Value
        let updatedAt: Date

        var isStale: Bool {
            Date.now.timeIntervalSince(updatedAt) > TransitCache.maxAge
        }
    }

    /// Bus stops and routes rarely change, so a week-old copy is still good to use.
    static let maxAge: TimeInterval = 7 * 24 * 60 * 60

    static func load<Value: Decodable>(_ type: Value.Type, from entry: Entry) -> Cached<Value>? {
        let url = url(for: entry)
        guard let data = try? Data(contentsOf: url),
              let value = try? JSONDecoder().decode(Value.self, from: data),
              let updatedAt = try? url.resourceValues(forKeys: [.contentModificationDateKey])
                .contentModificationDate else {
            return nil
        }
        return Cached(value: value, updatedAt: updatedAt)
    }

    static func store<Value: Encodable>(_ value: Value, as entry: Entry) {
        do {
            try JSONEncoder().encode(value).write(to: url(for: entry), options: .atomic)
        } catch {
            log("Could not cache \(entry.rawValue): \(error.localizedDescription)", level: .error)
        }
    }

    static func clear() {
        for entry in Entry.allCases {
            try? FileManager.default.removeItem(at: url(for: entry))
        }
    }

    private static func url(for entry: Entry) -> URL {
        // Mock data is kept apart so it never mixes with real data
        let prefix = transit is MockTransitAPI ? "Mock" : ""
        return AppGroup.cachesURL.appending(path: "\(prefix)\(entry.rawValue).json")
    }

}
