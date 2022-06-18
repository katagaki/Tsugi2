//
//  FavoritesView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct FavoritesView: View {
    
    var busStops: [BusStop] = []
    @EnvironmentObject var favorites: FavoriteList
    
    var body: some View {
        NavigationView {
            List {
                ForEach(favorites.favoriteLocations, id: \.busStopCode) { stop in
                    Section {
                        FavoriteLocationCarouselView(favoriteLocation: stop)
                        .listRowInsets(EdgeInsets(top: 16.0, leading: 0.0, bottom: 16.0, trailing: 0.0))
                    } header: {
                        Text((stop.nickname ?? stop.busStopCode!)) // TODO: Get bus stop name using API
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ViewTitle.Favorites")
                        .font(.system(size: 24.0, weight: .bold))
                }
                ToolbarItem(placement: .principal) {
                    Spacer()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // TODO: Toggle editing
                    } label: {
                        Text("Favorites.Edit")
                    }

                }
            }
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
