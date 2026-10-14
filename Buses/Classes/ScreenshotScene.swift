//
//  ScreenshotScene.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import SwiftData
import SwiftUI

/// Stages a screen for the App Store screenshots.
///
/// Chosen with the `-ScreenshotScene` launch argument by `Assets/App Store/capture.sh`,
/// and only in debug builds, so release builds always start as usual.
enum ScreenshotScene: String {
    case nearby
    case locations
    case route
    case search
    case busStop

    static let current: ScreenshotScene? = {
#if DEBUG
        UserDefaults.standard.string(forKey: "ScreenshotScene").flatMap(ScreenshotScene.init)
#else
        nil
#endif
    }()

    var detent: PresentationDetent {
        switch self {
        case .nearby, .route: .half
        case .locations, .search, .busStop: .large
        }
    }

    var searchTerm: String? {
        self == .search ? "Bedok Stn" : nil
    }

    /// Where the sheet is navigated to once the bus stops nearby are known.
    @MainActor func path(dataManager: DataManager) -> ViewPath? {
        switch self {
        case .route:
            let busStopCode = "66359"
            return .busServiceNamed("22", atLocation: dataManager.busStop(code: busStopCode)?.name() ?? "",
                                    forBusStopCode: busStopCode)
        case .busStop:
            return dataManager.busStop(code: "66359").map { .busStop($0) }
        default:
            return nil
        }
    }

    /// Held here, as the favorites manager keeps only its context.
    @MainActor private static var stagedContainer: ModelContainer?

    /// Favorites kept apart from the real ones, so that staging leaves them and iCloud alone.
    @MainActor func favoritesContainer() -> ModelContainer {
        if let container = Self.stagedContainer {
            return container
        }
        let schema = Schema([FavoriteLocation.self, FavoriteBusService.self])
        // Started afresh on each launch
        let url = URL.temporaryDirectory.appending(path: "Screenshots.store")
        for suffix in ["", "-shm", "-wal"] {
            try? FileManager.default.removeItem(at: URL(filePath: url.path() + suffix))
        }
        let configuration = ModelConfiguration("Screenshots", schema: schema, url: url, cloudKitDatabase: .none)
        // swiftlint:disable:next force_try
        let container = try! ModelContainer(for: schema, configurations: configuration)
        Self.stagedContainer = container
        let context = container.mainContext
        // A live location is named after its bus stop, as when it is added from the nearby list
        let locations = [
            StagedLocation(nickname: Self.nickname(home: true), busStopCode: "66359",
                           serviceNos: ["22", "43", "53", "70"]),
            StagedLocation(nickname: "Serangoon Station Exit E", busStopCode: "66351", serviceNos: []),
            StagedLocation(nickname: Self.nickname(home: false), busStopCode: "09048",
                           serviceNos: ["7", "14", "16", "65", "111"])
        ]
        // Nearby bus stops are the focus there, so they are kept close to the top
        for (index, location) in locations.prefix(self == .nearby ? 1 : locations.count).enumerated() {
            let favoriteLocation = FavoriteLocation(busStopCode: location.busStopCode,
                                                    nickname: location.nickname,
                                                    usesLiveBusStopData: location.serviceNos.isEmpty,
                                                    viewIndex: index)
            context.insert(favoriteLocation)
            for (serviceIndex, serviceNo) in location.serviceNos.enumerated() {
                let busService = FavoriteBusService(busStopCode: location.busStopCode, serviceNo: serviceNo,
                                                    viewIndex: serviceIndex)
                context.insert(busService)
                busService.location = favoriteLocation
            }
        }
        try? context.save()
        return container
    }

    private static func nickname(home: Bool) -> String {
        switch Locale.preferredLanguages.first?.prefix(2) {
        case "ja": home ? "自宅" : "職場"
        case "zh": home ? "家" : "公司"
        case "ms": home ? "Rumah" : "Pejabat"
        default: home ? "Home" : "Work"
        }
    }

}

private struct StagedLocation {
    let nickname: String
    let busStopCode: String
    let serviceNos: [String]
}
