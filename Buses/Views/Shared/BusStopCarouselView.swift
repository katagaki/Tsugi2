//
//  BusStopCarouselView.swift
//  Buses
//
//  Created by 堅書 on 24/2/23.
//

import SwiftUI

struct BusStopCarouselView: View {
    
    var mode: CarouselMode
    
    @State var isInitialDataLoaded: Bool = false
    @EnvironmentObject var favorites: FavoriteList
    @EnvironmentObject var busStopList: BusStopList
    @Binding var nearbyBusStops: [BusStop]
    @State var busServices: [BusService] = []
    var busStop: BusStop?
    var favoriteLocation: FavoriteLocation?
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var showToast: (String, ToastType) async -> Void
    
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
                    reloadArrivalTimes()
                    isInitialDataLoaded = true
                }
            }
        } else {
            if busServices.count == 0 {
                Text("Shared.BusStop.BusServices.None")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding([.leading, .trailing])
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16.0) {
                        ForEach(busServices, id: \.serviceNo) { bus in
                            NavigationLink {
                                ArrivalInfoDetailView(busStop: BusStop(code: busStop?.code ?? "00000",
                                                                       description: busStop?.description ?? "Shared.BusStop.Description.None"),
                                                      busService: bus,
                                                      usesNickname: false,
                                                      showToast: self.showToast)
                            } label: {
                                VStack(alignment: .center, spacing: 4.0) {
                                    BusNumberPlateView(serviceNo: bus.serviceNo)
                                        .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: -8.0, trailing: 0.0))
                                    Text(arrivalTimeTo(date: bus.nextBus?.estimatedArrivalTime()))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Text(arrivalTimeTo(date: bus.nextBus2?.estimatedArrivalTime(), returnBlankWhenNotInService: true))
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
                    reloadArrivalTimes()
                })
            }
        }
    }
    
    func reloadArrivalTimes() {
        switch mode {
        case .BusStop:
            if let busStop = busStop {
                Task {
                    busServices = (try await fetchBusArrivals(for: busStop.code).arrivals ?? []).sorted(by: { a, b in
                        intFrom(a.serviceNo) ?? 9999 < intFrom(b.serviceNo) ?? 9999
                    })
                }
            }
        case .FavoriteLocationCustomData:
            busServices = []
        case .FavoriteLocationLiveData:
            if let favoriteLocation = favoriteLocation {
                Task {
                    busServices = (try await fetchBusArrivals(for: favoriteLocation.busStopCode!).arrivals ?? []).sorted(by: { a, b in
                        intFrom(a.serviceNo) ?? 9999 < intFrom(b.serviceNo) ?? 9999
                    })
                }
            }
        }
    }
    
}

enum CarouselMode {
    case BusStop
    case FavoriteLocationCustomData
    case FavoriteLocationLiveData
}
