//
//  NearbyView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import MapKit
import SwiftUI

struct NearbyView: View {
    
    @EnvironmentObject var displayedCoordinates: CoordinateList
    @EnvironmentObject var busStopList: BusStopList
    
    @Binding var nearbyBusStops: [BusStop]
    
    var showToast: (String, Bool) async -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(nearbyBusStops, id: \.code) { stop in
                    NavigationLink {
                        BusStopDetailView(busStop: stop,
                                          showToast: self.showToast)
                    } label: {
                        HStack(alignment: .center, spacing: 16.0) {
                            Image("ListIcon.BusStop")
                            VStack(alignment: .leading, spacing: 2.0) {
                                Text(verbatim: stop.description ?? "Shared.BusStop.Description.None")
                                    .font(.body)
                                Text(verbatim: stop.roadName ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("ViewTitle.Nearby")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ViewTitle.Nearby")
                        .font(.system(size: 24.0, weight: .bold))
                }
                ToolbarItem(placement: .principal) {
                    Spacer()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(alignment: .center, spacing: 8.0) {
                        if nearbyBusStops.count == 0 {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                }
            }
        }
    }
}

struct NearbyView_Previews: PreviewProvider {
    static var previews: some View {
        NearbyView(nearbyBusStops: .constant([]), showToast: self.showToast)
    }
    
    static func showToast(message: String, showsCheckmark: Bool = false) async { }
    
}
