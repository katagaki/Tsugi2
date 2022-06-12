//
//  NearbyView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import MapKit
import SwiftUI

struct NearbyView: View {
    
    @State var coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.30437, longitude: 103.82458), latitudinalMeters: 50000.0, longitudinalMeters: 50000.0)
    @State var userTrackingMode: MapUserTrackingMode = .follow
    
    var body: some View {
        Map(coordinateRegion: $coordinateRegion,
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: $userTrackingMode)
        .edgesIgnoringSafeArea(.all)
    }
}

struct NearbyView_Previews: PreviewProvider {
    static var previews: some View {
        NearbyView()
    }
}
