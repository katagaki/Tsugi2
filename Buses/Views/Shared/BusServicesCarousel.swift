//
//  BusServicesCarousel.swift
//  Buses
//
//  Created by 堅書 on 24/2/23.
//

import SwiftUI

struct BusServicesCarousel: View {

    @Environment(\.scenePhase) var scenePhase
    @Environment(DataManager.self) var dataManager
    @Environment(FavoritesManager.self) var favorites
    @Environment(SettingsManager.self) var settings

    var dataDisplayMode: DataDisplayMode

    @State var isInitialDataLoaded: Bool = false
    @State var busServices: [BusService] = []
    var locationName: String
    var busStopCode: String?
    var favoriteLocation: FavoriteLocation?

    let timer = Timer.publish(every: 10.0, tolerance: 5.0, on: .main, in: .common).autoconnect()

    var fontHackOffset: CGFloat {
        return 2.0
    }

    var body: some View {
        @Bindable var settings = settings
        HStack {
            if !isInitialDataLoaded {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                    Spacer()
                }
            } else if busServices.count > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8.0) {
                        ForEach(busServices, id: \.hashValue) { bus in
                            NavigationLink(value: ViewPath.busService(bus,
                                                                      atLocation: locationName,
                                                                      forBusStopCode: busStopCode ?? "")) {
                                VStack(alignment: .center, spacing: 2.0) {
                                    BusNumberPlateView(
                                        carouselDisplayMode: $settings.carouselDisplayMode,
                                        serviceNo: bus.serviceNo
                                    )
                                    Group {
                                        switch settings.carouselDisplayMode {
                                        case .full:
                                            Text(bus.nextBus?.estimatedArrivalTimeAsDate()?.arrivalFormat(style: .short) ??
                                                 localized("Shared.BusArrival.NotInService"))
                                            .font(.system(size: 16.0))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            Text(bus.nextBus2?.estimatedArrivalTimeAsDate()?.arrivalFormat() ?? " ")
                                                .font(.system(size: 16.0))
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        case .small:
                                            Text(bus.nextBus?.estimatedArrivalTimeAsDate()?
                                                .arrivalFormat(style: .abbreviated) ??
                                                 localized("Shared.BusArrival.NotInService"))
                                            .font(.system(size: 14.0))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            Text(bus.nextBus2?.estimatedArrivalTimeAsDate()?
                                                .arrivalFormat(style: .abbreviated) ?? " ")
                                            .font(.system(size: 14.0))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                        case .minimal:
                                            Text(bus.nextBus?.estimatedArrivalTimeAsDate()?
                                                .arrivalFormat(style: .abbreviated) ??
                                                 localized("Shared.BusArrival.NotInService"))
                                            .font(.system(size: 12.0))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        }
                                    }
                                    .offset(y: fontHackOffset)
                                }
                                .frame(minWidth: settings.carouselDisplayMode.width(),
                                       maxWidth: settings.carouselDisplayMode.width(),
                                       minHeight: 0,
                                       maxHeight: .infinity,
                                       alignment: .center)
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, 16.0, for: .scrollContent)
            } else {
                HStack(alignment: .center) {
                    if dataDisplayMode == .favoriteLocationCustomData {
                        if (favoriteLocation?.busServices?.count ?? 0) == 0 {
                            Text("Favorites.Hint.NoBusServices")
                                .font(.body)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Shared.BusStop.BusServices.None")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Shared.BusStop.BusServices.None")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16.0)
            }
        }
        .task {
            await reloadArrivalTimes()
            isInitialDataLoaded = true
        }
        .onReceive(timer, perform: { _ in
            Task {
                await reloadArrivalTimes()
                log("Arrival time data updated.")
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
        .onChange(of: favorites.updateViewFlag, { _, _ in
            if dataDisplayMode != .busStop && dataDisplayMode != .notificationItem {
                log("View update signal received from favorites handler.")
                Task {
                    await reloadArrivalTimes()
                }
            }
        })
    }

    func reloadArrivalTimes() async {
        do {
            switch dataDisplayMode {
            case .busStop, .favoriteLocationLiveData:
                log("Reloading arrival times for a bus stop type location or favorite location using live data.")
                busServices = (try await transit.busArrivals(for: busStopCode ?? "").arrivals ?? [])
                    .sorted(by: { lhs, rhs in
                    lhs.serviceNo.toInt() ?? 9999 < rhs.serviceNo.toInt() ?? 9999
                })
            case .favoriteLocationCustomData:
                // A deleted location can still be on screen while its row animates away
                if let favoriteLocation, !favoriteLocation.isDeleted {
                    let favoriteBusServicesSorted = favoriteLocation.sortedBusServices
                    log("Reloading arrival times for a favorite location using custom data.")
                    try await reloadArrivalTimes(for: favoriteLocation,
                                                 favoriteBusServices: favoriteBusServicesSorted)
                }
            case .notificationItem:
                break // Mode not supported
            }
        } catch {
            log(error.localizedDescription)
        }
    }

    func reloadArrivalTimes(for favoriteLocation: FavoriteLocation,
                            favoriteBusServices: [FavoriteBusService]) async throws {
        busServices = favoriteBusServices.reduce(
            into: [BusService](), { partialResult, favoriteBusService in
                var busService: BusService = BusService(serviceNo: favoriteBusService.serviceNo ?? "",
                                                        operator: .unknown)
                busService.busStopCode = favoriteBusService.busStopCode
                partialResult.append(busService)
            })
        var fetchedBusServices: [BusService] = []
        for busService in busServices {
            if var fetchedBusService = try await transit.busArrivals(
                for: busService.busStopCode ?? "").arrivals?
                .first(where: { fetchedBusService in
                    fetchedBusService.serviceNo == busService.serviceNo
                }) {
                fetchedBusService.busStopCode = busService.busStopCode
                fetchedBusServices.append(fetchedBusService)
            }
        }
        busServices = fetchedBusServices
    }

}
