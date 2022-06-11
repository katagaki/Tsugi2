//
//  FavoritesView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct FavoritesView: View {
    
    var busStops: [BABusStop] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(busStops, id: \.code) { stop in
                    Section(header: Text(stop.code)) {
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 16.0) {
                                ForEach(stop.busServices, id: \.serviceNo) { service in
                                    VStack(alignment: .center, spacing: 6.0) {
                                        HStack(alignment: .center) {
                                            Text(service.serviceNo)
                                                .font(Font.custom("OceanSansStd-Bold", size: 24.0))
                                                .foregroundColor(.white)
                                                .padding(EdgeInsets(top: 6.0, leading: 16.0, bottom: 2.0, trailing: 16.0))
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .lineLimit(1)
                                        }
                                        .background(Color("PlateColor"))
                                        .clipShape(RoundedRectangle(cornerRadius: 7.0))
                                        Text(getArrivalText(arrivalTime: service.nextBus.estimatedArrivalTime()))
                                            .font(.body)
                                            .fontWeight(.regular)
                                        Text(getArrivalText(arrivalTime: service.nextBus2.estimatedArrivalTime()))
                                            .font(.body)
                                            .fontWeight(.regular)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(minWidth: ((UIScreen.main.bounds.size.width) / 4.5), maxWidth: ((UIScreen.main.bounds.size.width) / 4.5), minHeight: 0, maxHeight: .infinity, alignment: .center)
                                }
                            }
                            .padding(EdgeInsets(top: 0.0, leading: 16.0, bottom: 0.0, trailing: 16.0))
                        }
                        .listRowInsets(EdgeInsets(top: 16.0, leading: 0.0, bottom: 16.0, trailing: 0.0))
                    }
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .textCase(nil)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("ViewTitle.Favorites")
        }
    }
    
    func getArrivalText(arrivalTime: Date?) -> String {
        if let arrivalTime = arrivalTime {
            return arrivalTimeTo(date: arrivalTime)
        } else {
            return "N/A"
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    
    static var sampleBusStops: [BABusStop] = loadPreviewData()
    
    static var previews: some View {
        FavoritesView(busStops: sampleBusStops)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
        FavoritesView(busStops: sampleBusStops)
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
        FavoritesView(busStops: sampleBusStops)
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
    }
    
    static private func loadPreviewData() -> [BABusStop] {
        if let sampleDataPath1 = Bundle.main.path(forResource: "BusArrivalv2-1", ofType: "json"),
           let sampleDataPath2 = Bundle.main.path(forResource: "BusArrivalv2-2", ofType: "json"),
           let sampleDataPath3 = Bundle.main.path(forResource: "BusArrivalv2-3", ofType: "json") {
            let sampleBusStop1: BABusStop? = decode(from: sampleDataPath1)
            let sampleBusStop2: BABusStop? = decode(from: sampleDataPath2)
            let sampleBusStop3: BABusStop? = decode(from: sampleDataPath3)
            return [sampleBusStop1!, sampleBusStop2!, sampleBusStop3!]
        } else {
            return []
        }
    }
}
