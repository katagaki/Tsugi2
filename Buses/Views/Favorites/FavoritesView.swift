//
//  FavoritesView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct FavoritesView: View {
    
    var busStops: [BusStop] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(busStops, id: \.code) { stop in
                    Section {
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 16.0) {
                                ForEach(stop.arrivals ?? [], id: \.serviceNo) { service in
                                    VStack(alignment: .center, spacing: 6.0) {
                                        BusNumberPlateView(serviceNo: service.serviceNo)
                                            .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: -8.0, trailing: 0.0))
                                        Text(arrivalTimeTo(date: service.nextBus?.estimatedArrivalTime()))
                                            .font(.body)
                                            .lineLimit(1)
                                        Text(arrivalTimeTo(date: service.nextBus2?.estimatedArrivalTime()))
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    .frame(minWidth: 88.0, maxWidth: 88.0, minHeight: 0, maxHeight: .infinity, alignment: .center)
                                }
                            }
                            .padding(EdgeInsets(top: 0.0, leading: 16.0, bottom: 8.0, trailing: 16.0))
                        }
                        .listRowInsets(EdgeInsets(top: 16.0, leading: 0.0, bottom: 16.0, trailing: 0.0))
                    } header: {
                        Text(stop.code)
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .textCase(nil)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("ViewTitle.Favorites")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    
    static var sampleBusStops: [BusStop] = loadPreviewData()
    
    static var previews: some View {
        FavoritesView(busStops: sampleBusStops)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
        FavoritesView(busStops: sampleBusStops)
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
        FavoritesView(busStops: sampleBusStops)
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
    }
    
    static private func loadPreviewData() -> [BusStop] {
        if let sampleDataPath1 = Bundle.main.path(forResource: "BusArrivalv2-1", ofType: "json"),
           let sampleDataPath2 = Bundle.main.path(forResource: "BusArrivalv2-2", ofType: "json"),
           let sampleDataPath3 = Bundle.main.path(forResource: "BusArrivalv2-3", ofType: "json") {
            let sampleBusStop1: BusStop? = decode(from: sampleDataPath1)
            let sampleBusStop2: BusStop? = decode(from: sampleDataPath2)
            let sampleBusStop3: BusStop? = decode(from: sampleDataPath3)
            return [sampleBusStop1!, sampleBusStop2!, sampleBusStop3!]
        } else {
            return []
        }
    }
}
