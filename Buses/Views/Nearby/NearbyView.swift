//
//  NearbyView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import MapKit
import SwiftUI

struct NearbyView: View {
    
    @EnvironmentObject var displayedCoordinates: DisplayedCoordinates
    
    var body: some View {
        NavigationView {
            List {
            }
            .onAppear {
                displayedCoordinates.removeAll()
                // TODO: Display all bus stops nearby
            }
            .navigationTitle("ViewTitle.Nearby")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NearbyView_Previews: PreviewProvider {
    static var previews: some View {
        NearbyView()
    }
}
