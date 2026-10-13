//
//  ArrivalActivityController+Background.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import BackgroundTasks
import Foundation

extension ArrivalActivityController {

    /// How often Live Activities are refreshed while the app is in the foreground.
    static let foregroundRefreshInterval: Duration = .seconds(30)

    /// Asks the system to refresh Live Activities in the background. The system decides the actual timing.
    static func scheduleBackgroundRefresh() {
        guard !activities.isEmpty else { return }
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        request.earliestBeginDate = Date.now.addingTimeInterval(5 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            log("Scheduled background refresh for Live Activities.")
        } catch {
            log("Could not schedule background refresh: \(error.localizedDescription)", level: .error)
        }
    }

    static func handleBackgroundRefresh() async {
        await updateAll()
        scheduleBackgroundRefresh()
    }

    /// Keeps Live Activities fresh while the app is open. Cancelled along with the calling task.
    static func refreshWhileActive() async {
        while !Task.isCancelled {
            if !activities.isEmpty {
                await updateAll()
            }
            try? await Task.sleep(for: foregroundRefreshInterval)
        }
    }

}
