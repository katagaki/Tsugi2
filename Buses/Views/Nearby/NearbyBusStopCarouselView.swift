//
//  NearbyBusStopCarouselView.swift
//  Buses
//
//  Created by 堅書 on 24/2/23.
//

import SwiftUI

struct NearbyBusStopCarouselView: View {
    
    @Binding var nearbyBusStops: [BusStop]
    @EnvironmentObject var busStopList: BusStopList
    @State var busServices: [BusService] = []
    var busStop: BusStop
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16.0) {
                ForEach(busServices, id: \.serviceNo) { bus in
                    NavigationLink {
                        ArrivalInfoDetailView(busStop: BusStop(code: busStop.code, description: busStop.description ?? "Shared.BusStop.Description.None"), bus: bus, usesNickname: false)
                    } label: {
                        VStack(alignment: .center, spacing: 4.0) {
                            BusNumberPlateView(serviceNo: bus.serviceNo)
                                .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: -8.0, trailing: 0.0))
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
            }
            .padding(EdgeInsets(top: 0.0, leading: 16.0, bottom: 0.0, trailing: 16.0))
        }
        .onAppear {
            reloadArrivalTimes()
        }
        .onReceive(timer, perform: { _ in
            reloadArrivalTimes()
        })
    }
    
    func reloadArrivalTimes() {
        Task {
            busServices = (try await fetchBusArrivals(for: busStop.code).arrivals ?? []).sorted(by: { a, b in
                intFrom(a.serviceNo) ?? 9999 < intFrom(b.serviceNo) ?? 9999
            })
        }
    }
    
}
