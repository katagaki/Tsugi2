//
//  BusesShortcuts.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import AppIntents

/// Phrases that work with Siri as soon as the app is installed.
struct BusesShortcuts: AppShortcutsProvider {

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetLocationArrivalsIntent(),
            phrases: [
                "Check \(\.$location) in \(.applicationName)",
                "When is the next bus at \(\.$location) in \(.applicationName)",
                "Get bus arrivals in \(.applicationName)"
            ],
            shortTitle: "Intents.Shortcut.LocationArrivals",
            systemImageName: "bus.fill"
        )
        AppShortcut(
            intent: GetBusArrivalsIntent(),
            phrases: [
                "Check a bus stop in \(.applicationName)",
                "When is the next bus with \(.applicationName)"
            ],
            shortTitle: "Intents.Shortcut.BusStopArrivals",
            systemImageName: "clock.fill"
        )
        AppShortcut(
            intent: GetNearbyBusStopsIntent(),
            phrases: [
                "Find nearby bus stops in \(.applicationName)",
                "What bus stops are near me in \(.applicationName)"
            ],
            shortTitle: "Intents.Shortcut.NearbyBusStops",
            systemImageName: "location.fill"
        )
    }

}
