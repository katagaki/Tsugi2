//
//  FavoriteLocationCarouselView.swift
//  Buses
//
//  Created by Justin Xin on 2022/06/18.
//

import SwiftUI

struct FavoriteLocationCarouselView: View {
    
    @EnvironmentObject var favorites: FavoriteList
    @EnvironmentObject var busStopList: BusStopList
    @State var busServices: [BusService] = []
    var favoriteLocation: FavoriteLocation
//    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16.0) {
                if favoriteLocation.usesLiveBusStopData {
                    ForEach(busServices, id: \.serviceNo) { bus in
                        NavigationLink {
                            ArrivalInfoDetailView(busStop: BusStop(code: favoriteLocation.busStopCode ?? bus.busStopCode!, description: favoriteLocation.nickname), bus: bus, usesNickname: true)
                        } label: {
                            VStack(alignment: .center, spacing: 4.0) {
                                // Fix layout issues in iOS 16
                                if #available(iOS 16, *) {
                                    BusNumberPlateView(serviceNo: bus.serviceNo)
                                        .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: -8.0, trailing: 0.0))
                                } else {
                                    BusNumberPlateView(serviceNo: bus.serviceNo)
                                }
                                Text(arrivalTimeTo(date: bus.nextBus?.estimatedArrivalTime()))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                // Fix layout issues in iOS 16
                                if #available(iOS 16, *) {
                                    Text(arrivalTimeTo(date: bus.nextBus2?.estimatedArrivalTime(), returnBlankWhenNotInService: true))
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 8.0, trailing: 0.0))
                                } else {
                                    Text(arrivalTimeTo(date: bus.nextBus2?.estimatedArrivalTime(), returnBlankWhenNotInService: true))
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .frame(minWidth: 88.0, maxWidth: 88.0, minHeight: 0, maxHeight: .infinity, alignment: .center)
                        }
                    }
                } else {
                    ForEach(favorites.favoriteBusServices, id: \.serviceNo) { bus in
                        if bus.parentLocations?.contains(favoriteLocation) ?? false {
                            VStack(alignment: .center, spacing: 6.0) {
                                BusNumberPlateView(serviceNo: bus.serviceNo ?? "")
                                    .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
//                                Text(arrivalTimeTo(date: bus.nextBus?.estimatedArrivalTime()))
//                                    .font(.body)
//                                    .lineLimit(1)
//                                Text(arrivalTimeTo(date: bus.nextBus2?.estimatedArrivalTime(), returnBlankWhenNotInService: true))
//                                    .font(.body)
//                                    .foregroundColor(.secondary)
//                                    .lineLimit(1)
                                // TODO: When onAppear, populate the data immediately and use timer to update periodically
                            }
                            .frame(minWidth: 88.0, maxWidth: 88.0, minHeight: 0, maxHeight: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 0.0, leading: 16.0, bottom: 0.0, trailing: 16.0))
        }
        .onAppear {
            reloadArrivalTimes()
        }
//        .onReceive(timer, perform: { _ in
//            reloadArrivalTimes()
//        })
    }
    
    func reloadArrivalTimes() {
        if favoriteLocation.usesLiveBusStopData {
            Task {
                busServices = (try await fetchBusArrivals(for: favoriteLocation.busStopCode!).arrivals ?? []).sorted(by: { a, b in
                    intFrom(a.serviceNo) ?? 9999 < intFrom(b.serviceNo) ?? 9999
                })
            }
        } else {
            // TODO: Load bus arrival times based on linked bus services
        }
    }
    
}

struct FavoriteLocationCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteLocationCarouselView(favoriteLocation: FavoriteLocation())
    }
}
