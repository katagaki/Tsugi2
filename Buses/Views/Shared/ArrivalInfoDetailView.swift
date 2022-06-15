//
//  ArrivalInfoDetailView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/15.
//

import SwiftUI

struct ArrivalInfoDetailView: View {
    
    var busStop: BusStop
    var bus: BusService
    
    var body: some View {
        List {
            Section {
                if let nextBus = bus.nextBus {
                    ArrivalInfoCardView(arrivalInfo: nextBus)
                }
                if let nextBus = bus.nextBus2, nextBus.estimatedArrivalTime() != nil {
                    ArrivalInfoCardView(arrivalInfo: nextBus)
                }
                if let nextBus = bus.nextBus3, nextBus.estimatedArrivalTime() != nil {
                    ArrivalInfoCardView(arrivalInfo: nextBus)
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            reloadBusArrivals()
        }
        .navigationTitle(bus.serviceNo)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(bus.serviceNo)
                        .font(.system(size: 16.0, weight: .bold))
                    Text(busStop.description ?? "Shared.BusStop.Description.None")
                        .font(.system(size: 10.0, weight: .regular))
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
                }
            }
        }
    }
    
    func reloadBusArrivals() {
        
    }
    
}

struct ArrivalInfoDetailView_Previews: PreviewProvider {
    
    static var sampleBusStop: BusStop? = loadPreviewData()
    
    static var previews: some View {
        ArrivalInfoDetailView(busStop: sampleBusStop!, bus: sampleBusStop!.arrivals!.randomElement()!)
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
