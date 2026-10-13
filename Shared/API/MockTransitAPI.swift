//
//  MockTransitAPI.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import CoreLocation
import Foundation

/// Generated transit data around City Hall, used when no LTA DataMall key is available.
/// Arrival times are derived from the current time, so they count down and roll over like real data.
struct MockTransitAPI: TransitAPI {

    struct Stop {
        let code: String
        let name: String
        let road: String
        let latitude: Double
        let longitude: Double

        init(_ code: String, _ name: String, _ road: String, _ latitude: Double, _ longitude: Double) {
            self.code = code
            self.name = name
            self.road = road
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    struct Service {
        let serviceNo: String
        let `operator`: BusOperator
        let headwayMinutes: Int
        let type: BusType
        let stopCodes: [String]
    }

    static let stops: [Stop] = [
        Stop("01112", "OPP BUGIS STN EXIT C", "Victoria St", 1.30011, 103.85576),
        Stop("01013", "ST. JOSEPH'S CH", "Victoria St", 1.29770, 103.85361),
        Stop("01019", "BRAS BASAH CPLX", "Victoria St", 1.29698, 103.85302),
        Stop("01012", "HOTEL GRAND PACIFIC", "Victoria St", 1.29684, 103.85253),
        Stop("04111", "CITY HALL STN EXIT B", "North Bridge Rd", 1.29323, 103.85215),
        Stop("04121", "FUNAN", "North Bridge Rd", 1.29136, 103.84987),
        Stop("04167", "CLARKE QUAY STN EXIT A", "Eu Tong Sen St", 1.28856, 103.84651),
        Stop("05013", "CHINATOWN STN EXIT E", "New Bridge Rd", 1.28398, 103.84391),
        Stop("02089", "SUNTEC TWR TWO", "Temasek Blvd", 1.29525, 103.85879),
        Stop("02049", "MARINA CTR TER", "Raffles Blvd", 1.29115, 103.85869),
        Stop("02151", "THE ESPLANADE", "Raffles Ave", 1.29015, 103.85575),
        Stop("03011", "RAFFLES PL STN EXIT F", "Raffles Quay", 1.28356, 103.85131),
        Stop("03031", "LAU PA SAT", "Robinson Rd", 1.28059, 103.85020),
        Stop("04149", "SUPREME CT", "St Andrew's Rd", 1.29050, 103.85085)
    ]

    static let services: [Service] = [
        Service(serviceNo: "7", operator: .sbsTransit, headwayMinutes: 9, type: .doubleDeck,
                stopCodes: ["01112", "01013", "01012", "04111", "04121", "04167", "05013"]),
        Service(serviceNo: "14", operator: .sbsTransit, headwayMinutes: 12, type: .doubleDeck,
                stopCodes: ["02049", "02089", "01019", "04111", "04149", "03011", "03031"]),
        Service(serviceNo: "36", operator: .sbsTransit, headwayMinutes: 8, type: .doubleDeck,
                stopCodes: ["02049", "02151", "04149", "04111", "01012", "01013", "01112"]),
        Service(serviceNo: "61", operator: .sbsTransit, headwayMinutes: 14, type: .singleDeck,
                stopCodes: ["01112", "01019", "04111", "04121", "04167"]),
        Service(serviceNo: "75", operator: .sbsTransit, headwayMinutes: 15, type: .singleDeck,
                stopCodes: ["02089", "02049", "02151", "03011", "03031"]),
        Service(serviceNo: "107", operator: .sbsTransit, headwayMinutes: 11, type: .doubleDeck,
                stopCodes: ["01013", "01012", "04111", "04149", "02151", "02049"]),
        Service(serviceNo: "174", operator: .sbsTransit, headwayMinutes: 10, type: .doubleDeck,
                stopCodes: ["01112", "01013", "04111", "04121", "04167", "05013"]),
        Service(serviceNo: "190", operator: .sbsTransit, headwayMinutes: 7, type: .bendy,
                stopCodes: ["05013", "04167", "04121", "04111", "01012", "01019"]),
        Service(serviceNo: "961M", operator: .smrt, headwayMinutes: 13, type: .doubleDeck,
                stopCodes: ["01112", "01019", "04111", "04149", "03011"])
    ]

    /// Average time a mock bus spends travelling between two consecutive stops.
    static let secondsPerSegment: Double = 150.0

    func busStops() async throws -> [BusStop] {
        return Self.stops.map { stop in
            let busStop = BusStop(code: stop.code, description: stop.name)
            busStop.roadName = stop.road
            busStop.latitude = stop.latitude
            busStop.longitude = stop.longitude
            return busStop
        }
    }

    func busArrivals(for stopCode: String) async throws -> BusStop {
        let busStop = BusStop(code: stopCode, description: nil)
        let now = Date.now
        busStop.arrivals = Self.services.compactMap { service in
            guard let stopIndex = service.stopCodes.firstIndex(of: stopCode) else { return nil }
            var busService = BusService(serviceNo: service.serviceNo, operator: service.operator)
            let arrivals = (0..<3).map { index in
                arrivalInfo(for: service, at: stopIndex, busIndex: index, now: now)
            }
            busService.nextBus = arrivals[0]
            busService.nextBus2 = arrivals[1]
            busService.nextBus3 = arrivals[2]
            return busService
        }
        return busStop
    }

    func busRoutes() async throws -> BusRouteList {
        let busRouteList = BusRouteList()
        busRouteList.busRoutePoints = Self.services.flatMap { service in
            service.stopCodes.enumerated().map { index, stopCode in
                BusRoutePoint(serviceNo: service.serviceNo, operator: service.operator,
                              direction: .forward, stopSequence: index + 1, stopCode: stopCode)
            }
        }
        return busRouteList
    }

    func busRoutePolylines() async throws -> [BusRoutePolyline] {
        return Self.services.map { service in
            let coordinates = service.stopCodes.compactMap(Self.coordinate(of:))
            let encoded = Self.encodePolyline(coordinates)
            return BusRoutePolyline(serviceNo: service.serviceNo, encodedPolylines: [encoded, encoded])
        }
    }

    // MARK: Generation

    private func arrivalInfo(for service: Service, at stopIndex: Int, busIndex: Int, now: Date) -> BusArrivalInfo {
        let headway = Double(service.headwayMinutes * 60)
        let phase = Double(Self.seed(service.serviceNo) % service.headwayMinutes) * 60.0
        let timeAtStop = now.timeIntervalSince1970 + phase - Double(stopIndex) * Self.secondsPerSegment
        let secondsUntil = headway - timeAtStop.truncatingRemainder(dividingBy: headway) + Double(busIndex) * headway
        let arrival = now.addingTimeInterval(secondsUntil)
        let tripNumber = Int((now.timeIntervalSince1970 + secondsUntil) / headway)
        let loads: [BusLoad] = [.seatsAvailable, .seatsAvailable, .standingAvailable, .limitedStanding]

        var info = BusArrivalInfo()
        info.firstBusStopCode = service.stopCodes.first
        info.lastBusStopCode = service.stopCodes.last
        info.estimatedArrivalTime = Self.iso8601.string(from: arrival)
        info.visitNumber = "1"
        info.load = loads[Self.seed("\(service.serviceNo).\(tripNumber)") % loads.count]
        info.feature = .wheelchairAccessible
        info.type = service.type
        if let position = position(of: service, arrivingAt: stopIndex, in: secondsUntil) {
            info.latitude = String(position.latitude)
            info.longitude = String(position.longitude)
        }
        return info
    }

    /// Where the bus is now, given it reaches the stop at `stopIndex` in `secondsUntil` seconds.
    private func position(of service: Service, arrivingAt stopIndex: Int,
                          in secondsUntil: Double) -> CLLocationCoordinate2D? {
        let segmentsAway = secondsUntil / Self.secondsPerSegment
        let routeProgress = Double(stopIndex) - segmentsAway
        guard routeProgress >= 0 else { return nil }
        let fromIndex = Int(routeProgress.rounded(.down))
        let toIndex = min(fromIndex + 1, service.stopCodes.count - 1)
        guard let from = Self.coordinate(of: service.stopCodes[fromIndex]),
              let destination = Self.coordinate(of: service.stopCodes[toIndex]) else { return nil }
        let fraction = routeProgress - Double(fromIndex)
        return CLLocationCoordinate2D(latitude: from.latitude + (destination.latitude - from.latitude) * fraction,
                                      longitude: from.longitude + (destination.longitude - from.longitude) * fraction)
    }

    private static func coordinate(of stopCode: String) -> CLLocationCoordinate2D? {
        guard let stop = stops.first(where: { $0.code == stopCode }) else { return nil }
        return CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
    }

    private static func seed(_ string: String) -> Int {
        // Stable across launches, unlike Hasher
        return string.unicodeScalars.reduce(5381) { ($0 &* 33 &+ Int($1.value)) & 0x7FFFFFFF }
    }

    private static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Singapore")
        return formatter
    }()

    private static func encodePolyline(_ coordinates: [CLLocationCoordinate2D]) -> String {
        var encoded = ""
        var previous = (latitude: 0, longitude: 0)
        for coordinate in coordinates {
            let latitude = Int((coordinate.latitude * 1e5).rounded())
            let longitude = Int((coordinate.longitude * 1e5).rounded())
            for delta in [latitude - previous.latitude, longitude - previous.longitude] {
                var value = delta < 0 ? ~(delta << 1) : (delta << 1)
                while value >= 0x20 {
                    encoded.unicodeScalars.append(UnicodeScalar(UInt8((0x20 | (value & 0x1f)) + 63)))
                    value >>= 5
                }
                encoded.unicodeScalars.append(UnicodeScalar(UInt8(value + 63)))
            }
            previous = (latitude, longitude)
        }
        return encoded
    }

}
