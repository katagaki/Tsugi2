//
//  MapRegionManager.swift
//  Buses
//
//  Created by 堅書 on 2/3/23.
//

import Foundation
import MapKit
import SwiftUI

// Huge thanks to null's answer for this solution to prevent lag
// https://stackoverflow.com/questions/67864517/
class MapRegionManager: ObservableObject {

    @Published var updateViewFlag = false

    var storedRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))

    var region: Binding<MKCoordinateRegion> {
        Binding(
            get: { self.storedRegion },
            set: { self.storedRegion = $0 }
        )
    }

    func updateRegion(newRegion: MKCoordinateRegion) {
        withAnimation {
            region.wrappedValue = newRegion
            updateViewFlag.toggle()
        }
    }

}
