//
//  WidgetIntents.swift
//  Assistant
//
//  Created by 堅書 on 2026/10/14.
//

import AppIntents

struct SelectLocationIntent: WidgetConfigurationIntent {

    static let title: LocalizedStringResource = "Widget.SelectLocation"
    static let description = IntentDescription("Widget.Description")

    @Parameter(title: "Widget.Location")
    var location: LocationEntity?

}

/// Reloads a widget's arrival times. WidgetKit refreshes the timeline after the intent runs.
struct RefreshArrivalsIntent: AppIntent {

    static let title: LocalizedStringResource = "LiveActivity.Refresh"
    static let isDiscoverable = false

    func perform() async throws -> some IntentResult {
        return .result()
    }

}

/// Moves a widget to another page of services. WidgetKit refreshes the timeline after the intent runs.
struct ChangePageIntent: AppIntent {

    static let title: LocalizedStringResource = "Widget.ChangePage"
    static let isDiscoverable = false

    @Parameter(title: "Widget.Location")
    var locationID: String

    @Parameter(title: "Widget.Page")
    var page: Int

    init() {
        // Required by AppIntent
    }

    init(locationID: UUID, page: Int) {
        self.locationID = locationID.uuidString
        self.page = page
    }

    func perform() async throws -> some IntentResult {
        if let locationID = UUID(uuidString: locationID) {
            WidgetPages.setPage(page, for: locationID)
        }
        return .result()
    }

}
