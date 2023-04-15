//
//  NearbyMapView.swift
//  Buses
//
//  Created by 堅書 on 13/4/23.
//

import MapKit
import SwiftUI

struct NearbyMapView: View {
    
    @EnvironmentObject var regionManager: MapRegionManager
    
    @State var userTrackingMode: MapUserTrackingMode = .none
    @Binding var displayedCoordinates: CoordinateList
    
    var body: some View {
        Map(coordinateRegion: regionManager.region,
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: $userTrackingMode,
            annotationItems: displayedCoordinates.coordinates) { coordinate in
            MapAnnotation(coordinate: coordinate.clCoordinate()) {
                NavigationLink {
                    BusStopView(busStop: coordinate.busStop)
                } label: {
                    MapStopView(busStop: coordinate.busStop)
                }
            }
        }
    }
    
}
