//
//  NotificationHandler.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import UserNotifications

/// Opens the bus service an arrival notification is about when the user taps it.
final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {

    private let navigationManager: NavigationManager

    init(navigationManager: NavigationManager) {
        self.navigationManager = navigationManager
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        guard let serviceNo = userInfo["busService"] as? String,
              let busStopCode = userInfo["stopCode"] as? String else { return }
        let locationName = userInfo["stopDescription"] as? String ?? ""
        await navigationManager.open(.busServiceNamed(serviceNo, atLocation: locationName,
                                                      forBusStopCode: busStopCode))
        log("Opened bus service \(serviceNo) from a notification.")
    }

    /// Shows arrival notifications even while the app is open.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

}
