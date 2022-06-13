//
//  MainTabView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import MapKit
import SwiftUI

struct MainTabView: View {
    
    @State var isSheetPresenting = true
    @State var coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.30437, longitude: 103.82458), latitudinalMeters: 50000.0, longitudinalMeters: 50000.0)
    @State var userTrackingMode: MapUserTrackingMode = .follow
    
    var body: some View {
        Map(coordinateRegion: $coordinateRegion,
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: $userTrackingMode)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            isSheetPresenting = true
        }
        .sheet(isPresented: $isSheetPresenting) {
            TabView {
                NearbyView()
                    .tabItem {
                        Label("TabTitle.Nearby", systemImage: "map.fill")
                    }
                FavoritesView()
                    .tabItem {
                        Label("TabTitle.Favorites", systemImage: "star.fill")
                    }
                DirectoryView()
                    .tabItem {
                        Label("TabTitle.Directory", systemImage: "book.closed.fill")
                    }
                MoreView()
                    .tabItem {
                        Label("TabTitle.More", systemImage: "ellipsis")
                    }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
