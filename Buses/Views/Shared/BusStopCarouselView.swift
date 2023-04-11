//
//  BusStopCarouselView.swift
//  Buses
//
//  Created by 堅書 on 24/2/23.
//

import SwiftUI

struct BusStopCarouselView: View {
    
    @EnvironmentObject var busStopList: BusStopList
    @EnvironmentObject var favorites: FavoriteList
    
    var mode: DataDisplayMode
    
    @State var isInitialDataLoaded: Bool = false
    @State var busServices: [BusService] = []
    @State var busStop: BusStop?
    @State var favoriteLocation: FavoriteLocation?
    
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var showToast: (String, ToastType, Bool) async -> Void
    
    var body: some View {
        if !isInitialDataLoaded {
            HStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                Spacer()
            }
            .onAppear {
                if !isInitialDataLoaded {
                    Task {
                        await reloadArrivalTimes()
                        isInitialDataLoaded = true
                    }
                }
            }
        } else {
            if busServices.count > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8.0) {
                        ForEach(busServices, id: \.hashValue) { bus in
                            NavigationLink {
                                ArrivalInfoDetailView(mode: mode,
                                                      busService: bus,
                                                      busStop: busStop,
                                                      favoriteLocation: favoriteLocation,
                                                      showsAddToLocationButton: mode == .BusStop,
                                                      showToast: self.showToast)
                            } label: {
                                VStack(alignment: .center, spacing: 2.0) {
                                    BusNumberPlateView(serviceNo: bus.serviceNo)
                                        .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: -8.0, trailing: 0.0))
                                    Text(bus.nextBus?.estimatedArrivalTime()?.arrivalFormat() ?? localized("Shared.BusArrival.NotInService"))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Text(bus.nextBus2?.estimatedArrivalTime()?.arrivalFormat() ?? " ")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 8.0, trailing: 0.0))
                                }
                                .frame(minWidth: 88.0, maxWidth: 88.0, minHeight: 0, maxHeight: .infinity, alignment: .center)
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0.0, leading: 16.0, bottom: 0.0, trailing: 16.0))
                }
                .onReceive(timer, perform: { _ in
                    Task {
                        await reloadArrivalTimes()
                        log("Arrival time data updated.")
                    }
                })
            } else {
                Text("Shared.BusStop.BusServices.None")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding([.leading, .trailing])
            }
        }
    }
    
    func reloadArrivalTimes() async {
        do {
            switch mode {
            case .BusStop:
                if let busStop = busStop {
                    busServices = (try await fetchBusArrivals(for: busStop.code).arrivals ?? []).sorted(by: { a, b in
                        a.serviceNo.toInt() ?? 9999 < b.serviceNo.toInt() ?? 9999
                    })
                }
            case .FavoriteLocationCustomData:
                if let favoriteLocation = favoriteLocation,
                   let favoriteBusServices = favoriteLocation.busServices {
                    busServices = favoriteBusServices.reduce(into: [BusService](), { partialResult, favoriteBusService in
                        var busService: BusService = BusService(serviceNo: (favoriteBusService as! FavoriteBusService).serviceNo!, operator: .Unknown)
                        busService.busStopCode = (favoriteBusService as! FavoriteBusService).busStopCode
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
                    busServices = (try await fetchBusArrivals(for: favoriteLocation.busStopCode ?? "").arrivals ?? []).sorted(by: { a, b in
                        a.serviceNo.toInt() ?? 9999 < b.serviceNo.toInt() ?? 9999
                    })
                    if busStop == nil {
                        busStop = busStopList.busStops.first(where: { fetchedBusStop in
                            fetchedBusStop.code == favoriteLocation.busStopCode
                        })
                    }
                }
            case .NotificationItem:
                break // Mode not supported
            }
        } catch {
            log(error.localizedDescription)
        }
    }
    
}
