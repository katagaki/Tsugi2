//
//  BusServiceView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/15.
//

import ActivityKit
import MapKit
import SwiftUI

struct BusServiceView: View {

    var mode: DataDisplayMode

    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var toaster: Toaster

    @State var liveActivityID: String = ""

    @State var isInitialDataLoading: Bool = true
    @State var busService: BusService
    @State var busStopsForMapDisplay: [BusStop] = []
    var busStop: Binding<BusStop>?
    var favoriteLocation: Binding<FavoriteLocation>?

    @State var timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()

    @State var showsAddToLocationButton: Bool

    var body: some View {
        GeometryReader { metrics in
            VStack(alignment: .trailing, spacing: 0) {
                if settings.showRoute {
                    MapWithRoute(useLegacyOverlay: true,
                                 currentBusStopCode: busStop?.wrappedValue.code ?? "",
                                 busStops: $busStopsForMapDisplay)
                    .ignoresSafeArea(edges: [.top])
                    .overlay {
                        ZStack(alignment: .topLeading) {
                            BlurGradientView()
                                .ignoresSafeArea()
                                .frame(height: metrics.safeAreaInsets.top + 44.0)
                            Color.clear
                        }
                    }
                    .overlay {
                        if !dataManager.isBusRouteListLoaded {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                }
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
                }
                .listStyle(.insetGrouped)
                .frame(width: metrics.size.width, height: (settings.showRoute ?
                                                           metrics.size.height * 0.6 : metrics.size.height))
                .shadow(radius: 2.5)
                .zIndex(1)
            }
        }
        .task {
            await reloadArrivalTimes()
            startLiveActivity()
            do {
                if settings.showRoute {
                    try await dataManager.reloadBusRoutesFromServer()
                    reloadBusRoutes()
                }
            } catch {
                log(error.localizedDescription)
            }
        }
        .onDisappear {
            Task {
                if let liveActivity = Activity<AssistantAttributes>.activities.first(where: {$0.id == liveActivityID}) {
                    await liveActivity.end(nil, dismissalPolicy: .immediate)
                    log("Live Activity \(liveActivityID) ended.")
                }
            }
        }
        .refreshable {
            Task {
                await reloadArrivalTimes()
            }
        }
        .onChange(of: dataManager.isBusRouteListLoaded, perform: { newValue in
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
                                            await favorites.saveChanges()
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
        timer.upstream.connect().cancel()
        do {
            switch mode {
            case .busStop, .favoriteLocationLiveData:
                if let busStop = busStop {
                    let fetchedBusStop = try await fetchBusArrivals(for: busStop.wrappedValue.code)
                    self.busStop?.wrappedValue.description = dataManager.busStop(
                        code: busStop.wrappedValue.code)?.name()
                    busService = fetchedBusStop.arrivals?.first(where: { busService in
                        busService.serviceNo == self.busService.serviceNo
                    }) ?? BusService(serviceNo: busService.serviceNo, operator: busService.operator)
                }
            case .favoriteLocationCustomData:
                self.busStop?.wrappedValue = try await fetchBusArrivals(for: busService.busStopCode ?? "")
                self.busStop?.wrappedValue.description = favoriteLocation?.wrappedValue.nickname ?? ""
            case .notificationItem:
                if let busStop = busStop {
                    let fetchedBusStop = try await fetchBusArrivals(for: busStop.wrappedValue.code)
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
        timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    }

    func reloadBusRoutes() {
        let busRoutePoints = dataManager.busRoute(for: busService.serviceNo,
                                                  direction: busService.direction ?? .backward)
        for busRoutePoint in busRoutePoints {
            if let busStop = dataManager.busStop(code: busRoutePoint.stopCode) {
                busStopsForMapDisplay.append(busStop)
            }
        }
    }

    func setNotification(for arrivalInfo: BusArrivalInfo) {
        if let date = arrivalInfo.estimatedArrivalTimeAsDate() {
            center.requestAuthorization(options: [.alert, .sound]) { granted, error in
                if let error = error {
                    log("Error occurred while reqesting for notification permissions: \(error.localizedDescription)")
                    toaster.showToast(localized("Notification.Error"),
                                            type: .exclamation,
                                            hidesAutomatically: true)
                } else if granted == false {
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
        var title = ""
        var userInfo: [AnyHashable: Any] = [:]
        var identifier = ""
        switch mode {
        case .busStop, .favoriteLocationLiveData, .notificationItem:
            if let busStop = busStop {
                title = localized("Notification.Arriving.Title")
                    .replacingOccurrences(of: "%1", with: busStop.wrappedValue.name())
                userInfo = ["busService": busService.serviceNo,
                            "stopCode": busStop.wrappedValue.code,
                            "stopDescription": busStop.wrappedValue.name()]
                identifier = "\(busStop.wrappedValue.code).\(busService.serviceNo)." +
                             "\(date.formatted(date: .numeric, time: .shortened))"
            }
        case .favoriteLocationCustomData:
            if let favoriteLocation = favoriteLocation?.wrappedValue {
                title = localized("Notification.Arriving.Title")
                    .replacingOccurrences(of: "%1", with: favoriteLocation.nickname ??
                                          localized("Shared.BusStop.Description.None"))
                userInfo = ["busService": busService.serviceNo,
                            "stopCode": busService.busStopCode ?? "",
                            "stopDescription": favoriteLocation.nickname ??
                            localized("Shared.BusStop.Description.None")]
                identifier = "\(busService.busStopCode ?? "").\(busService.serviceNo)." +
                             "\(date.formatted(date: .numeric, time: .shortened))"
            }
        }
        content.title = title
        content.userInfo = userInfo
        content.body = localized("Notification.Arriving.Description")
            .replacingOccurrences(of: "%s1", with: busService.serviceNo)
            .replacingOccurrences(of: "%s2", with: date.formatted(date: .omitted, time: .shortened))
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Ding.caf"))
        content.interruptionLevel = .timeSensitive
        center.add(UNNotificationRequest(identifier: identifier,
                                         content: content,
                                         trigger: trigger)) { (error) in
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

    func startLiveActivity() {
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
    }

}

struct BusServiceView_Previews: PreviewProvider {

    static var sampleBusStop: BusStop? = loadPreviewData()

    static var previews: some View {
        BusServiceView(mode: .busStop,
                              busService: sampleBusStop!.arrivals!.randomElement()!,
                              busStop: .constant(sampleBusStop!),
                              showsAddToLocationButton: true)
    }

    static private func loadPreviewData() -> BusStop? {
        if let sampleDataPath = Bundle.main.path(forResource: "BusArrivalv2-1", ofType: "json") {
            let sampleBusStop: BusStop? = decode(from: sampleDataPath)
            return sampleBusStop!
        } else {
            return nil
        }
    }

}
