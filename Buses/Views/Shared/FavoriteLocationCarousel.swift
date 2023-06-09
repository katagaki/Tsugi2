//
//  FavoriteLocationCarousel.swift
//  Buses
//
//  Created by 堅書 on 2023/06/03.
//

import SwiftUI

struct FavoriteLocationCarousel: View {

    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var settings: SettingsManager

    @State var isInitialDataLoaded: Bool = false
    @State var busServices: [BusService] = []
    @Binding var location: FavoriteLocation

    @State var timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()

    var body: some View {
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
                            NavigationLink {
                                BusServiceView(mode: dataDisplayMode,
                                               busService: bus,
                                               busStop: busStop,
                                               favoriteLocation: favoriteLocation,
                                               showsAddToLocationButton: dataDisplayMode == .busStop)
                            } label: {
                                switch settings.carouselDisplayMode {
                                case .full:
                                    BusServicesCarouselItem(serviceNo: bus.serviceNo,
                                                            arrivalTime1: bus.nextBus?.estimatedArrivalTimeAsDate()?
                                                                .arrivalFormat(style: .short) ??
                                                                localized("Shared.BusArrival.NotInService"),
                                                            arrivalTime2: bus.nextBus2?.estimatedArrivalTimeAsDate()?
                                                                .arrivalFormat() ?? " ")
                                case .small:
                                    BusServicesCarouselItem(serviceNo: bus.serviceNo,
                                                            arrivalTime1: bus.nextBus?.estimatedArrivalTimeAsDate()?
                                                                .arrivalFormat(style: .abbreviated) ??
                                                                localized("Shared.BusArrival.NotInService"),
                                                            arrivalTime2: bus.nextBus2?.estimatedArrivalTimeAsDate()?
                                                                .arrivalFormat(style: .abbreviated) ?? " ")
                                case .minimal:
                                    BusServicesCarouselItem(serviceNo: bus.serviceNo,
                                                            arrivalTime1: bus.nextBus?.estimatedArrivalTimeAsDate()?
                                                                .arrivalFormat(style: .abbreviated) ??
                                                                localized("Shared.BusArrival.NotInService"),
                                                            arrivalTime2: "")
                                }
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0.0, leading: 16.0, bottom: 0.0, trailing: 16.0))
                }
            } else {
                HStack(alignment: .center) {
                    if dataDisplayMode == .favoriteLocationCustomData {
                        if (favoriteLocation?.wrappedValue.busServices?.count ?? 0) == 0 {
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
                .padding([.leading, .trailing])
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
        .onChange(of: favorites.updateViewFlag) { _ in
            if dataDisplayMode != .busStop && dataDisplayMode != .notificationItem {
                log("View update signal received from favorites handler.")
                Task {
                    await reloadArrivalTimes()
                }
            }
        }
    }

    func reloadArrivalTimes() async {
        timer.upstream.connect().cancel()
        do {
            switch dataDisplayMode {
            case .busStop:
                if let busStop = busStop {
                    log("Reloading arrival times for a bus stop type location.")
                    try await reloadArrivalTimes(for: busStop.wrappedValue)
                }
            case .favoriteLocationCustomData, .favoriteLocationLiveData:
                if let favoriteLocation = favoriteLocation,
                   let favoriteBusServices = favoriteLocation.wrappedValue.busServices?.array as? [FavoriteBusService] {
                    let favoriteBusServicesSorted = (
                        favoriteBusServices.sorted(by: { lhs, rhs in
                           lhs.viewIndex < rhs.viewIndex
                       }))
                    log("Reloading arrival times for a favorite location.")
                    try await reloadArrivalTimes(for: favoriteLocation.wrappedValue,
                                                 favoriteBusServices: favoriteBusServicesSorted,
                                                 isDataCustom: !favoriteLocation.usesLiveBusStopData.wrappedValue)
                }
            case .notificationItem:
                break // Mode not supported
            }
        } catch {
            log(error.localizedDescription)
        }
        timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    }

    func reloadArrivalTimes(for favoriteLocation: FavoriteLocation,
                            favoriteBusServices: [FavoriteBusService],
                            isDataCustom: Bool) async throws {
        if isDataCustom {
            busServices = favoriteBusServices.reduce(
                into: [BusService](), { partialResult, favoriteBusService in
                    var busService: BusService = BusService(serviceNo: favoriteBusService.serviceNo ?? "",
                                                            operator: .unknown)
                    busService.busStopCode = favoriteBusService.busStopCode
                    partialResult.append(busService)
                })
            var fetchedBusServices: [BusService] = []
            for busService in busServices {
                if var fetchedBusService = try await getBusArrivals(
                    for: busService.busStopCode ?? "").arrivals?
                    .first(where: { fetchedBusService in
                        fetchedBusService.serviceNo == busService.serviceNo
                    }) {
                    fetchedBusService.busStopCode = busService.busStopCode
                    fetchedBusServices.append(fetchedBusService)
                }
            }
            busServices = fetchedBusServices
       } else {
           let fetchedBusStop = try await getBusArrivals(
            for: favoriteLocation.busStopCode ?? "")
           busServices = fetchedBusStop.arrivals?.sorted(by: { lhs, rhs in
               lhs.serviceNo.toInt() ?? 9999 < rhs.serviceNo.toInt() ?? 9999
           }) ?? []
       }
    }

    func reloadArrivalTimes(for busStop: BusStop) async throws {
        busServices = (try await getBusArrivals(for: busStop.code).arrivals ?? [])
            .sorted(by: { lhs, rhs in
            lhs.serviceNo.toInt() ?? 9999 < rhs.serviceNo.toInt() ?? 9999
        })
    }

}
