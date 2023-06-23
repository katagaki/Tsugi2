//
//  BusServiceView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/15.
//

#if canImport(ActivityKit)
import ActivityKit
#endif
import MapKit
import SwiftUI

// swiftlint:disable type_body_length
struct BusServiceView: View {

    var mode: DataDisplayMode

    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var coordinateManager: CoordinateManager
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var toaster: Toaster

    @State var liveActivityID: String = ""

    @State var isInitialDataLoading: Bool = true
    @State var busService: BusService
    @State var busStopsForMapDisplay: [BusStop] = []
    @State var encodedPolyline: String = ""
    var busStop: Binding<BusStop>?
    var favoriteLocation: Binding<FavoriteLocation>?

    let timer = Timer.publish(every: 10.0, tolerance: 5.0, on: .main, in: .common).autoconnect()

    @State var showsAddToLocationButton: Bool

    var body: some View {
        List {
            Section {
                if let nextBus = busService.nextBus {
                    ListArrivalInfoRow(busService: busService,
                                       arrivalInfo: nextBus,
                                       setNotification: self.setNotification)
                }
                if let nextBus = busService.nextBus2, nextBus.estimatedArrivalTimeAsDate() != nil {
                    ListArrivalInfoRow(busService: busService,
                                       arrivalInfo: nextBus,
                                       setNotification: self.setNotification)
                }
                if let nextBus = busService.nextBus3, nextBus.estimatedArrivalTimeAsDate() != nil {
                    ListArrivalInfoRow(busService: busService,
                                       arrivalInfo: nextBus,
                                       setNotification: self.setNotification)
                }
            }
            if !dataManager.isBusRouteListLoaded && settings.showRoute {
                Section {
                    HStack(alignment: .center, spacing: 8.0) {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("Shared.BusArrival.LoadingRoute")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .task {
            await reloadArrivalTimes()
            startLiveActivity()
            do {
                if settings.showRoute {
                    try await dataManager.reloadBusRoutesFromServer()
                    try await dataManager.reloadBusRoutePolylinesFromServer()
                    reloadBusRoutes()
                }
                updateMapDisplay()
            } catch {
                log(error.localizedDescription)
            }
        }
        .onDisappear {
#if canImport(ActivityKit) && canImport(WidgetKit)
            Task {
                if let liveActivity = Activity<AssistantAttributes>.activities.first(where: {$0.id == liveActivityID}) {
                    await liveActivity.end(nil, dismissalPolicy: .immediate)
                    log("Live Activity \(liveActivityID) ended.")
                }
            }
#endif
        }
        .refreshable {
            Task {
                await reloadArrivalTimes()
            }
        }
        .onChange(of: dataManager.isBusRouteListLoaded, { _, newValue in
            if newValue && settings.showRoute {
                reloadBusRoutes()
            }
        })
        .onReceive(timer, perform: { _ in
            Task {
                await reloadArrivalTimes()
            }
        })
        .navigationTitle(busService.serviceNo)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                switch mode {
                case .busStop, .notificationItem:
                    SubtitledNavigationTitle(title: busService.serviceNo,
                                             subtitle: busStop?.wrappedValue.name() ?? "")
                case .favoriteLocationLiveData, .favoriteLocationCustomData:
                    SubtitledNavigationTitle(title: busService.serviceNo,
                                             subtitle: favoriteLocation?.wrappedValue.nickname ?? "")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                HStack(alignment: .center, spacing: 0.0) {
                    if showsAddToLocationButton {
                        Menu {
                            ForEach(favorites.favoriteLocations, id: \.hash) { location in
                                if !location.usesLiveBusStopData, let busStop = busStop {
                                    Button(location.nickname ?? localized("Shared.BusStop.Description.None")) {
                                        Task {
                                            await favorites.addBusServiceToFavoriteLocation(
                                                location,
                                                busStop: busStop.wrappedValue,
                                                busService: busService)
                                            toaster.showToast(
                                                localized("Shared.BusArrival.Toast.Favorited",
                                                          replacing: busService.serviceNo, location.nickname ??
                                                          localized("Shared.BusStop.Description.None")),
                                                type: .checkmark,
                                                hidesAutomatically: true)
                                        }
                                    }
                                    .disabled(favorites.find(busService.serviceNo, in: location))
                                }
                            }
                        } label: {
                            Image(systemName: "rectangle.stack.badge.plus")
                                .font(.body)
                        }
                    }
                }
            }
        }
    }

    func reloadArrivalTimes() async {
        do {
            switch mode {
            case .busStop, .favoriteLocationLiveData:
                if let busStop = busStop {
                    let fetchedBusStop = try await getBusArrivals(for: busStop.wrappedValue.code)
                    self.busStop?.wrappedValue.description = dataManager.busStop(
                        code: busStop.wrappedValue.code)?.name()
                    busService = fetchedBusStop.arrivals?.first(where: { busService in
                        busService.serviceNo == self.busService.serviceNo
                    }) ?? BusService(serviceNo: busService.serviceNo, operator: busService.operator)
                }
            case .favoriteLocationCustomData:
                self.busStop?.wrappedValue = try await getBusArrivals(for: busService.busStopCode ?? "")
                self.busStop?.wrappedValue.description = favoriteLocation?.wrappedValue.nickname ?? ""
            case .notificationItem:
                if let busStop = busStop {
                    let fetchedBusStop = try await getBusArrivals(for: busStop.wrappedValue.code)
                    busService = fetchedBusStop.arrivals?.first(where: { busService in
                        busService.serviceNo == self.busService.serviceNo
                    }) ?? BusService(serviceNo: busService.serviceNo, operator: busService.operator)
                }
            }
            log("Arrival time data updated.")
            isInitialDataLoading = false
        } catch {
            log(error.localizedDescription)
        }
    }

    func reloadBusRoutes() {
        let busRoutePoints = dataManager.busRoute(for: busService.serviceNo,
                                                  direction: busService.direction ?? .backward)
        for busRoutePoint in busRoutePoints {
            if let busStop = dataManager.busStop(code: busRoutePoint.stopCode) {
                busStopsForMapDisplay.append(busStop)
            }
        }
        encodedPolyline = dataManager
            .busRoutePolyline(for: busService.serviceNo,
                              direction: busService.direction ?? .init(rawValue: 1)!)
    }

    func updateMapDisplay() {
        coordinateManager.removeAll()
        if settings.showRoute {
            coordinateManager.replaceWithCoordinates(from: busStopsForMapDisplay)
            coordinateManager.polyline = (encodedPolyline == "" ? nil : encodedPolyline)
            coordinateManager.updateCameraFlag.toggle()
        }
        log("Bus service view updated displayed coordinates.")
    }

    func setNotification(for arrivalInfo: BusArrivalInfo) {
        if let date = arrivalInfo.estimatedArrivalTimeAsDate() {
            center.requestAuthorization(options: [.alert, .sound]) { granted, error in
                if let error = error {
                    log("Error occurred while reqesting for notification permissions: \(error.localizedDescription)")
                    toaster.showToast(localized("Notification.Error"),
                                            type: .exclamation,
                                            hidesAutomatically: true)
                } else if !granted {
                    log("Permissions for notifications was not granted, not setting notifications.")
                    toaster.showToast(localized("Notification.NoPermissions"),
                                            type: .exclamation,
                                            hidesAutomatically: true)
                } else {
                    setNotification(on: date)
                }
            }
        }
    }

    // swiftlint:disable function_body_length
    func setNotification(on date: Date) {
        let content = UNMutableNotificationContent()
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.weekday, .hour, .minute, .second],
                                                          from: date - (2 * 60)), repeats: false)
        var identifier = ""
        switch mode {
        case .busStop, .notificationItem:
            if let busStop = busStop {
                content.title = localized("Notification.Arriving.Title",
                                          replacing: busStop.wrappedValue.name())
                content.userInfo = ["busService": busService.serviceNo,
                                    "stopCode": busStop.wrappedValue.code,
                                    "stopDescription": busStop.wrappedValue.name()]
                identifier = "\(busStop.wrappedValue.code).\(busService.serviceNo)." +
                             "\(date.formatted(date: .numeric, time: .shortened))"
            }
        case .favoriteLocationLiveData:
            if let favoriteLocation = favoriteLocation?.wrappedValue {
                content.title = localized("Notification.Arriving.Title",
                                          replacing: favoriteLocation.nickname ??
                                          localized("Shared.BusStop.Description.None"))
                content.userInfo = ["busService": busService.serviceNo,
                                    "stopCode": favoriteLocation.busStopCode ?? "",
                                    "stopDescription": favoriteLocation.nickname ??
                                    localized("Shared.BusStop.Description.None")]
                identifier = "\(favoriteLocation.busStopCode ?? "").\(busService.serviceNo)." +
                             "\(date.formatted(date: .numeric, time: .shortened))"
            }
        case .favoriteLocationCustomData:
            if let favoriteLocation = favoriteLocation?.wrappedValue {
                content.title = localized("Notification.Arriving.Title",
                                          replacing: favoriteLocation.nickname ??
                                          localized("Shared.BusStop.Description.None"))
                content.userInfo = ["busService": busService.serviceNo,
                                    "stopCode": busService.busStopCode ?? "",
                                    "stopDescription": favoriteLocation.nickname ??
                                    localized("Shared.BusStop.Description.None")]
                identifier = "\(busService.busStopCode ?? "").\(busService.serviceNo)." +
                             "\(date.formatted(date: .numeric, time: .shortened))"
            }
        }
        content.body = localized("Notification.Arriving.Description",
                                 replacing: busService.serviceNo,
                                 date.formatted(date: .omitted, time: .shortened))
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Ding.caf"))
        content.interruptionLevel = .timeSensitive
        center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)) { (error) in
            if let error = error {
                log("Error occurred while setting notifications: \(error.localizedDescription)")
                toaster.showToast(localized("Notification.Error"), type: .exclamation, hidesAutomatically: true)
            } else {
                log("Notification set with content: \(content.body), " +
                    "and will appear at \((date - (2 * 60)).formatted(date: .complete, time: .complete)).")
                toaster.showToast(localized("Notification.Set"), type: .checkmark, hidesAutomatically: true)
            }
        }
    }
    // swiftlint:enable function_body_length

    func startLiveActivity() {
#if canImport(ActivityKit) && canImport(WidgetKit)
        let initialContentState = AssistantAttributes.ContentState(busService: busService)
        let activityAttributes = AssistantAttributes(serviceNo: busService.serviceNo, currentDate: Date())
        let activityContent = ActivityContent(state: initialContentState,
                                              staleDate: Calendar.current.date(byAdding: .second,
                                                                               value: 15,
                                                                               to: Date()))
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            do {
                var liveActivity: Activity<AssistantAttributes>?
                liveActivity = try Activity.request(attributes: activityAttributes, content: activityContent)
                liveActivityID = liveActivity?.id ?? ""
                log("Live Activity requested with id \(liveActivityID).")
            } catch {
                log(error.localizedDescription)
            }
        }
#endif
    }

}
// swiftlint:enable type_body_length
