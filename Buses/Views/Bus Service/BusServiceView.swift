//
//  BusServiceView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/15.
//

import MapKit
import Polyline
import SwiftUI

struct BusServiceView: View {

    @Environment(\.scenePhase) var scenePhase
    @Environment(DataManager.self) var dataManager
    @Environment(FavoritesManager.self) var favorites
    @Environment(CoordinateManager.self) var coordinateManager
    @Environment(SettingsManager.self) var settings
    @Environment(Toaster.self) var toaster

    @State var isLiveActivityActive: Bool = false

    @State var isInitialDataLoading: Bool = true
    @State var busService: BusService
    @State var busStopsForMapDisplay: [BusStop] = []
    @State var encodedPolyline: String = ""
    @State var locationName: String
    @State var busStopCode: String

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
            isLiveActivityActive = ArrivalActivityController.activity(serviceNo: busService.serviceNo,
                                                                      busStopCode: busStopCode) != nil
            do {
                if settings.showRoute {
                    try await dataManager.reloadBusRoutes()
                    try await dataManager.reloadBusRoutePolylines()
                    reloadBusRoutes()
                }
                updateMapDisplay()
            } catch {
                log(error.localizedDescription)
            }
        }
        .onDisappear {
            coordinateManager.liveBuses.removeAll()
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
        .onChange(of: scenePhase) { _, newPhase in
            // Timers do not fire in the background, so arrivals are out of date on returning to the app
            if newPhase == .active {
                Task {
                    await reloadArrivalTimes()
                }
            }
        }
        .navigationTitle(busService.serviceNo)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SubtitledNavigationTitle(title: busService.serviceNo,
                                         subtitle: locationName)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        await toggleLiveActivity()
                    }
                } label: {
                    if isLiveActivityActive {
                        Label("LiveActivity.Stop", systemImage: "pin.slash")
                    } else {
                        Label("LiveActivity.Start", systemImage: "pin")
                    }
                }
                .disabled(busService.nextBus?.estimatedArrivalTimeAsDate() == nil && !isLiveActivityActive)
            }
            if showsAddToLocationButton {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(favorites.favoriteLocations, id: \.persistentModelID) { location in
                            if !location.usesLiveBusStopData {
                                Button(location.nickname ?? localized("Shared.BusStop.Description.None")) {
                                    Task {
                                        await addToFavorites(location)
                                    }
                                }
                                .disabled(favorites.find(busService.serviceNo, in: location))
                            }
                        }
                    } label: {
                        Image(systemName: "rectangle.stack.badge.plus")
                    }
                }
            }
        }
    }

    func reloadArrivalTimes() async {
        do {
            let fetchedBusStop = try await transit.busArrivals(for: busStopCode)
            let serviceNo = busService.serviceNo
            if let busService = fetchedBusStop.arrivals?.first(where: { busService in
                busService.serviceNo == serviceNo
            }) {
                self.busService = busService
                withAnimation {
                    coordinateManager.liveBuses = LiveBus.buses(of: busService)
                }
            }
            log("Arrival time data updated.")
            isInitialDataLoading = false
        } catch {
            log(error.localizedDescription)
        }
    }

    func reloadBusRoutes() {
        let direction = routeDirection()
        let busRoutePoints = dataManager.busRoute(for: busService.serviceNo, direction: direction)
        for busRoutePoint in busRoutePoints {
            if let busStop = dataManager.busStop(code: busRoutePoint.stopCode) {
                busStopsForMapDisplay.append(busStop)
            }
        }
        encodedPolyline = dataManager.busRoutePolyline(for: busService.serviceNo, direction: direction)
    }

    func addToFavorites(_ location: FavoriteLocation) async {
        await favorites.addBusServiceToFavoriteLocation(
            location,
            stopCode: busStopCode,
            busService: busService)
        toaster.showToast(
            localized("Shared.BusArrival.Toast.Favorited",
                      replacing: busService.serviceNo, location.nickname ??
                      localized("Shared.BusStop.Description.None")),
            type: .checkmark,
            hidesAutomatically: true)
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

    func setNotification(on date: Date) {
        let content = UNMutableNotificationContent()
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.weekday, .hour, .minute, .second],
                                                          from: date - (2 * 60)), repeats: false)
        var identifier = ""
        content.title = localized("Notification.Arriving.Title",
                                  replacing: locationName)
        content.userInfo = ["busService": busService.serviceNo,
                            "stopCode": busStopCode,
                            "stopDescription": locationName]
        identifier = "\(busStopCode).\(busService.serviceNo)." +
                     "\(date.formatted(date: .numeric, time: .shortened))"
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

    func toggleLiveActivity() async {
        if let activity = ArrivalActivityController.activity(serviceNo: busService.serviceNo,
                                                             busStopCode: busStopCode) {
            await ArrivalActivityController.end(activity)
            isLiveActivityActive = false
            return
        }
        guard ArrivalActivityController.areActivitiesEnabled else {
            toaster.showToast(localized("LiveActivity.Disabled"), type: .exclamation, hidesAutomatically: true)
            return
        }
        do {
            try await ArrivalActivityController.start(serviceNo: busService.serviceNo,
                                                      busStopCode: busStopCode,
                                                      busStopName: locationName,
                                                      busService: busService)
            isLiveActivityActive = true
            ArrivalActivityController.scheduleBackgroundRefresh()
            toaster.showToast(localized("LiveActivity.Started"), type: .checkmark, hidesAutomatically: true)
        } catch {
            log("Could not start Live Activity: \(error.localizedDescription)", level: .error)
            toaster.showToast(localized("LiveActivity.Error"), type: .exclamation, hidesAutomatically: true)
        }
    }

}

extension BusServiceView {

    func updateMapDisplay() {
        coordinateManager.removeAll()
        coordinateManager.liveBuses = LiveBus.buses(of: busService)
        if settings.showRoute {
            coordinateManager.replaceWithCoordinates(from: busStopsForMapDisplay)
            coordinateManager.routeCoordinates = routeCoordinates()
            coordinateManager.highlightedBusStopCode = busStopCode
        } else if let busStop = dataManager.busStop(code: busStopCode) {
            // Frames the bus stop together with the buses heading to it
            coordinateManager.addCoordinate(from: busStop)
        }
        coordinateManager.updateCameraFlag.toggle()
        log("Bus service view updated displayed coordinates.")
    }

    /// Arrivals do not say which way a bus is going, so the direction is the one that passes this bus stop.
    func routeDirection() -> BusRouteDirection {
        if let direction = busService.direction {
            return direction
        }
        let passesBusStop = { (direction: BusRouteDirection) in
            dataManager.busRoute(for: busService.serviceNo, direction: direction)
                .contains { $0.direction == direction && $0.stopCode == busStopCode }
        }
        return passesBusStop(.backward) && !passesBusStop(.forward) ? .backward : .forward
    }

    /// The road-following route when one is available, otherwise a line through the route's bus stops.
    func routeCoordinates() -> [CLLocationCoordinate2D] {
        if !encodedPolyline.isEmpty,
           let decodedCoordinates: [CLLocationCoordinate2D] = decodePolyline(encodedPolyline) {
            return decodedCoordinates
        }
        return busStopsForMapDisplay.compactMap { busStop in
            guard let latitude = busStop.latitude, let longitude = busStop.longitude else { return nil }
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

}
