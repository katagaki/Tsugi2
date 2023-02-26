//
//  ArrivalInfoDetailView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/15.
//

import SwiftUI

struct ArrivalInfoDetailView: View {
    
    @State var busStop: BusStop
    @State var bus: BusService
    @State var isInitialDataLoading: Bool = true
    @State var usesNickname: Bool = false
    @EnvironmentObject var busStopList: BusStopList
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var showToast: (String, Bool) async -> Void
    
    var body: some View {
        List {
            Section {
                if let nextBus = bus.nextBus {
                    ArrivalInfoCardView(busService: bus,
                                        arrivalInfo: nextBus,
                                        showToast: self.showToast)
                }
                if let nextBus = bus.nextBus2, nextBus.estimatedArrivalTime() != nil {
                    ArrivalInfoCardView(busService: bus,
                                        arrivalInfo: nextBus,
                                        showToast: self.showToast)
                }
                if let nextBus = bus.nextBus3, nextBus.estimatedArrivalTime() != nil {
                    ArrivalInfoCardView(busService: bus,
                                        arrivalInfo: nextBus,
                                        showToast: self.showToast)
                }
            }
        }
        .listStyle(.grouped)
        .onAppear {
            if !isInitialDataLoading {
                reloadArrivalTimes()
            }
        }
        .refreshable {
            reloadArrivalTimes()
        }
        .onReceive(timer, perform: { _ in
            reloadArrivalTimes()
        })
        .navigationTitle(bus.serviceNo)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(bus.serviceNo)
                        .font(.system(size: 16.0, weight: .bold))
                    Text(busStop.description ?? localized("Shared.BusStop.Description.None"))
                        .font(.system(size: 12.0, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                HStack(alignment: .center, spacing: 0.0) {
                    Button {
                        // TODO: Add to favorites
                    } label: {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14.0, weight: .regular))
                    }
                    .buttonStyle(.bordered)
                    .mask {
                        Circle()
                    }
                    .disabled(true) // TODO: To implement
                }
            }
        }
    }
    
    func reloadArrivalTimes() {
        Task {
            let busStop = try await fetchBusArrivals(for: busStop.code)
            if usesNickname {
                busStop.description = self.busStop.description
            } else {
                busStop.description = busStopList.busStops.first(where: { busStopInBusStopList in
                    busStopInBusStopList.code == busStop.code
                })?.description ?? nil
            }
            let bus = busStop.arrivals?.first(where: { bus in
                bus.serviceNo == self.bus.serviceNo
            }) ?? BusService(serviceNo: bus.serviceNo, operator: bus.operator)
            self.busStop = busStop
            self.bus = bus
            isInitialDataLoading = false
        }
    }
    
}

struct ArrivalInfoDetailView_Previews: PreviewProvider {
    
    static var sampleBusStop: BusStop? = loadPreviewData()
    
    static var previews: some View {
        ArrivalInfoDetailView(busStop: sampleBusStop!,
                              bus: sampleBusStop!.arrivals!.randomElement()!,
                              showToast: self.showToast)
    }
    
    static func showToast(message: String, showsCheckmark: Bool = false) async { }
    
    static private func loadPreviewData() -> BusStop? {
        if let sampleDataPath = Bundle.main.path(forResource: "BusArrivalv2-1", ofType: "json") {
            let sampleBusStop: BusStop? = decode(from: sampleDataPath)
            return sampleBusStop!
        } else {
            return nil
        }
    }
    
}
