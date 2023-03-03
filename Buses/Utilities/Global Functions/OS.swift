//
//  Activities.swift
//  Buses 2
//
//  Created by 堅書 on 27/2/23.
//

import ActivityKit
import Foundation
import UserNotifications

// User Defaults for storing basic preferences
let defaults = UserDefaults.standard

// Notification Center for sending locally scheduled notifications
let center = UNUserNotificationCenter.current()
