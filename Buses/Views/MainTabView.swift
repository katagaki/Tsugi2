//
//  MainTabView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import CoreLocation
import MapKit
import SwiftUI

struct MainTabView: View {
    
    @State var coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.30437, longitude: 103.82458), latitudinalMeters: 40000.0, longitudinalMeters: 40000.0)
    @State var userTrackingMode: MapUserTrackingMode = .follow
    @EnvironmentObject var displayedCoordinates: DisplayedCoordinates
    
    var body: some View {
        GeometryReader { metrics in
            VStack(alignment: .center, spacing: 0.0) {
                Map(coordinateRegion: $coordinateRegion,
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: $userTrackingMode,
                    annotationItems: displayedCoordinates.coordinates) { coordinate in
                    MapMarker(coordinate: coordinate.clCoordinate())
                }
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        let locationManager: CLLocationManager = CLLocationManager()
                        switch locationManager.authorizationStatus {
                                case .notDetermined: locationManager.requestWhenInUseAuthorization()
                                case .denied, .restricted: break // TODO: Show popup to continue or go to Settings
                                default: break // All good
                                }
                    }
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
                .edgesIgnoringSafeArea(.all)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: metrics.size.height * 0.60, maxHeight: metrics.size.height * 0.60)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(DisplayedCoordinates())
    }
}
