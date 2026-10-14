//
//  ArrivalActivityIntents.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import AppIntents
import Foundation

/// Refreshes the arrival times shown in a Live Activity. Runs in the app's process.
struct RefreshArrivalActivityIntent: LiveActivityIntent {

    static let title: LocalizedStringResource = "LiveActivity.Refresh"
    static let isDiscoverable = false

    @Parameter(title: "LiveActivity.Identifier")
    var activityID: String

    init() {
        // Required by AppIntent
    }

    init(activityID: String) {
        self.activityID = activityID
    }

    func perform() async throws -> some IntentResult {
        if let activity = ArrivalActivityController.activity(id: activityID) {
            await ArrivalActivityController.update(activity)
        }
        return .result()
    }

}

/// Stops tracking a bus from its Live Activity. Runs in the app's process.
struct EndArrivalActivityIntent: LiveActivityIntent {

    static let title: LocalizedStringResource = "LiveActivity.Stop"
    static let isDiscoverable = false

    @Parameter(title: "LiveActivity.Identifier")
    var activityID: String

    init() {
        // Required by AppIntent
    }

    init(activityID: String) {
        self.activityID = activityID
    }

    func perform() async throws -> some IntentResult {
        if let activity = ArrivalActivityController.activity(id: activityID) {
            await ArrivalActivityController.end(activity)
        }
        return .result()
    }

}
