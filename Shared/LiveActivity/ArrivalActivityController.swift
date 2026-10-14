//
//  ArrivalActivityController.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import ActivityKit
import Foundation

/// Starts, refreshes and ends arrival Live Activities.
/// Arrival times count down on their own, so refreshes only need to correct the estimates.
enum ArrivalActivityController {

    /// Identifier of the background refresh task that keeps Live Activities up to date.
    static let refreshTaskIdentifier = "com.tsubuzaki.Tsugi2-assistant.refresh"

    /// Activities are ended after this long, as nobody waits for a bus for over an hour.
    static let maximumDuration: TimeInterval = 60 * 60

    static var activities: [Activity<ArrivalAttributes>] {
        Activity<ArrivalAttributes>.activities
    }

    static var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    static func activity(serviceNo: String, busStopCode: String) -> Activity<ArrivalAttributes>? {
        activities.first {
            $0.attributes.serviceNo == serviceNo && $0.attributes.busStopCode == busStopCode
        }
    }

    static func activity(id: String) -> Activity<ArrivalAttributes>? {
        activities.first { $0.id == id }
    }

    @discardableResult
    static func start(serviceNo: String, busStopCode: String, busStopName: String,
                      busService: BusService? = nil) async throws -> Activity<ArrivalAttributes> {
        if let existingActivity = activity(serviceNo: serviceNo, busStopCode: busStopCode) {
            await update(existingActivity)
            return existingActivity
        }
        let state: ArrivalAttributes.ContentState
        if let busService {
            state = ArrivalAttributes.ContentState(busService: busService)
        } else {
            state = try await contentState(serviceNo: serviceNo, busStopCode: busStopCode)
        }
        let attributes = ArrivalAttributes(serviceNo: serviceNo, busStopCode: busStopCode, busStopName: busStopName)
        let activity = try Activity.request(attributes: attributes, content: content(for: state))
        log("Live Activity \(activity.id) started for \(serviceNo) at \(busStopCode).")
        return activity
    }

    static func update(_ activity: Activity<ArrivalAttributes>) async {
        let attributes = activity.attributes
        do {
            let state = try await contentState(serviceNo: attributes.serviceNo, busStopCode: attributes.busStopCode)
            if Date.now.timeIntervalSince(attributes.startedAt) > maximumDuration {
                await activity.end(content(for: state), dismissalPolicy: .default)
                log("Live Activity \(activity.id) ended after reaching its maximum duration.")
            } else {
                await activity.update(content(for: state))
                log("Live Activity \(activity.id) updated.")
            }
        } catch {
            log("Could not update Live Activity \(activity.id): \(error.localizedDescription)", level: .error)
        }
    }

    static func updateAll() async {
        for activity in activities {
            await update(activity)
        }
    }

    static func end(_ activity: Activity<ArrivalAttributes>) async {
        await activity.end(nil, dismissalPolicy: .immediate)
        log("Live Activity \(activity.id) ended.")
    }

    private static func contentState(serviceNo: String,
                                     busStopCode: String) async throws -> ArrivalAttributes.ContentState {
        let busStop = try await transit.busArrivals(for: busStopCode)
        return ArrivalAttributes.ContentState(busService: busStop.arrivals?.first { $0.serviceNo == serviceNo })
    }

    private static func content(
        for state: ArrivalAttributes.ContentState
    ) -> ActivityContent<ArrivalAttributes.ContentState> {
        // Estimates drift, so mark the activity stale shortly after the bus is due or when updates stop
        var staleDate = Date.now.addingTimeInterval(15 * 60)
        if let nextArrival = state.nextArrival {
            staleDate = min(staleDate, max(nextArrival, .now).addingTimeInterval(60))
        }
        // Buses arriving sooner are more relevant when several activities are running
        let minutesAway = state.nextArrival.map { max($0.timeIntervalSinceNow / 60, 0) } ?? 99
        return ActivityContent(state: state, staleDate: staleDate, relevanceScore: 100 - min(minutesAway, 99))
    }

}
