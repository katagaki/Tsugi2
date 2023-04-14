//
//  BusServicesCarousel.swift
//  Buses
//
//  Created by 堅書 on 24/2/23.
//

import SwiftUI

struct BusServicesCarousel: View {
    
    @EnvironmentObject var busStopList: BusStopList
    @EnvironmentObject var favorites: FavoriteList
    @EnvironmentObject var settings: SettingsManager
    
    @State var dataDisplayMode: DataDisplayMode
    
    @State var isInitialDataLoaded: Bool = false
    @State var isInUnstableState: Binding<Bool>?
    @State var busServices: [BusService] = []
    @State var busStop: Binding<BusStop>?
    @State var favoriteLocation: Binding<FavoriteLocation>?
    
    @State var timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if !isInitialDataLoaded {
            HStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                Spacer()
            }
            .onAppear {
                Task {
                    await reloadArrivalTimes()
                    isInitialDataLoaded = true
                }
            }
        } else if busServices.count > 0 {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8.0) {
                    ForEach(busServices, id: \.hashValue) { bus in
                        NavigationLink {
                            ArrivalInfoDetailView(mode: dataDisplayMode,
                                                  busService: bus,
                                                  busStop: busStop,
                                                  favoriteLocation: favoriteLocation,
                                                  showsAddToLocationButton: dataDisplayMode == .BusStop)
                        } label: {
                            VStack(alignment: .center, spacing: 2.0) {
                                BusNumberPlateView(carouselDisplayMode: $settings.carouselDisplayMode,
                                                   serviceNo: bus.serviceNo)
                                    .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: -8.0, trailing: 0.0))
                                switch settings.carouselDisplayMode {
                                case .Full:
                                    Text(bus.nextBus?.estimatedArrivalTime()?.arrivalFormat(style: .short) ?? localized("Shared.BusArrival.NotInService"))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Text(bus.nextBus2?.estimatedArrivalTime()?.arrivalFormat() ?? " ")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                case .Small:
                                    Text(bus.nextBus?.estimatedArrivalTime()?.arrivalFormat(style: .abbreviated) ?? localized("Shared.BusArrival.NotInService"))
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Text(bus.nextBus2?.estimatedArrivalTime()?.arrivalFormat(style: .abbreviated) ?? " ")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                case .Minimal:
                                    Text(bus.nextBus?.estimatedArrivalTime()?.arrivalFormat(style: .abbreviated) ?? localized("Shared.BusArrival.NotInService"))
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                            }
                            .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 8.0, trailing: 0.0))
                        }
                    }
                }
                .padding(EdgeInsets(top: 0.0, leading: 16.0, bottom: 0.0, trailing: 16.0))
            }
            .onReceive(timer, perform: { _ in
                if isInUnstableState == nil || !(isInUnstableState?.wrappedValue ?? true) {
                    Task {
                        await reloadArrivalTimes()
                        log("Arrival time data updated.")
                    }
                }
            })
            .onChange(of: favorites.shouldUpdateViewsAsSoonAsPossible) { newValue in
                if newValue {
                    if (isInUnstableState == nil || !(isInUnstableState?.wrappedValue ?? true)) && dataDisplayMode != .BusStop && dataDisplayMode != .NotificationItem {
                        log("View update signal received from favorites handler.")
                        Task {
                            await reloadArrivalTimes()
                            favorites.shouldUpdateViewsAsSoonAsPossible = false
                        }
                    } else {
                        favorites.shouldUpdateViewsAsSoonAsPossible = false
                    }
                }
            }
        } else {
            HStack(alignment: .center) {
                switch dataDisplayMode {
                case .FavoriteLocationCustomData:
                    if (favoriteLocation?.wrappedValue.busServices?.count ?? 0) == 0 {
                        Text("Favorites.Hint.NoBusServices")
                            .font(.body)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Shared.BusStop.BusServices.None")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                default:
                    Text("Shared.BusStop.BusServices.None")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding([.leading, .trailing])
        }
    }

    func reloadArrivalTimes() async {
        timer.upstream.connect().cancel()
        do {
            switch dataDisplayMode {
            case .BusStop:
                if let busStop = busStop {
                    log("Reloading arrival times for a bus stop type location.")
                    busServices = (try await fetchBusArrivals(for: busStop.wrappedValue.code).arrivals ?? []).sorted(by: { a, b in
                        a.serviceNo.toInt() ?? 9999 < b.serviceNo.toInt() ?? 9999
                    })
                }
            case .FavoriteLocationCustomData:
                if let favoriteLocation = favoriteLocation,
                   let favoriteBusServices = (favoriteLocation.wrappedValue.busServices?.array as? [FavoriteBusService])?.sorted(by: { a, b in
                       a.viewIndex < b.viewIndex
                   }) {
                    log("Reloading arrival times for a custom data type location.")
                    busServices = favoriteBusServices.reduce(into: [BusService](), { partialResult, favoriteBusService in
                        var busService: BusService = BusService(serviceNo: favoriteBusService.serviceNo ?? "", operator: .Unknown)
                        busService.busStopCode = favoriteBusService.busStopCode
                        partialResult.append(busService)
                    })
                    var fetchedBusServices: [BusService] = []
                    for busService in busServices {
                        if var fetchedBusService = try await fetchBusArrivals(for: busService.busStopCode ?? "").arrivals?.first(where: { fetchedBusService in
                            fetchedBusService.serviceNo == busService.serviceNo
                        }) {
                            fetchedBusService.busStopCode = busService.busStopCode
                            fetchedBusServices.append(fetchedBusService)
                        }
                    }
                    busServices = fetchedBusServices
                    // TODO: When a change is detected in Core Data, encourage reloading of bus service list
                }
            case .FavoriteLocationLiveData:
                if let favoriteLocation = favoriteLocation {
                    log("Reloading arrival times for a live data type location.")
                    busServices = (try await fetchBusArrivals(for: favoriteLocation.wrappedValue.busStopCode ?? "").arrivals ?? []).sorted(by: { a, b in
                        a.serviceNo.toInt() ?? 9999 < b.serviceNo.toInt() ?? 9999
                    })
                    busStop = .constant(busStopList.busStops.first(where: { fetchedBusStop in
                        fetchedBusStop.code == favoriteLocation.wrappedValue.busStopCode
                    }) ?? BusStop())
                }
            case .NotificationItem:
                break // Mode not supported
            }
        } catch {
            log(error.localizedDescription)
        }
        timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    }
    
}
