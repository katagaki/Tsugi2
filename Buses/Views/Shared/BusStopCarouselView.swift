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
    @State var busServices: [BusService] = []
    @State var busStop: BusStop?
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
                        ForEach(busServices, id: \.serviceNo) { bus in
                            NavigationLink {
                                ArrivalInfoDetailView(busStop: busStop ?? BusStop(code: favoriteLocation?.busStopCode ?? "00000",
                                                                                  description: favoriteLocation?.nickname ?? localized("Shared.BusStop.Description.None")),
                                                      busService: bus,
                                                      usesNickname: false,
                                                      showToast: self.showToast)
                            } label: {
                                VStack(alignment: .center, spacing: 2.0) {
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
                        intFrom(a.serviceNo) ?? 9999 < intFrom(b.serviceNo) ?? 9999
                    })
                }
            case .FavoriteLocationCustomData:
                busServices = []
            case .FavoriteLocationLiveData:
                if let favoriteLocation = favoriteLocation {
                    busServices = (try await fetchBusArrivals(for: favoriteLocation.busStopCode!).arrivals ?? []).sorted(by: { a, b in
                        intFrom(a.serviceNo) ?? 9999 < intFrom(b.serviceNo) ?? 9999
                    })
                }
            }
        } catch {
            log(error.localizedDescription)
        }
    }
    
}

enum CarouselMode {
    case BusStop
    case FavoriteLocationCustomData
    case FavoriteLocationLiveData
}
