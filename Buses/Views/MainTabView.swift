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
    
    @State var locationManager: CLLocationManager = CLLocationManager()
    @StateObject var locationManagerDelegate: LocationDelegate = LocationDelegate()
    @State var userTrackingMode: MapUserTrackingMode = .follow
    @EnvironmentObject var displayedCoordinates: DisplayedCoordinates
    
    var body: some View {
        GeometryReader { metrics in
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $locationManagerDelegate.region,
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: $userTrackingMode,
                    annotationItems: displayedCoordinates.coordinates) { coordinate in
                    MapMarker(coordinate: coordinate.clCoordinate())
                }
                    .safeAreaInset(edge: .bottom) {
                        Text("")
                            .frame(width: metrics.size.width, height: metrics.size.height * 0.60 - 12.0)
                    }
                    .frame(width: metrics.size.width, height: metrics.size.height)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        locationManager.delegate = locationManagerDelegate
                        locationManager.startUpdatingLocation()
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
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: metrics.size.height * 0.60, maxHeight: metrics.size.height * 0.60)
                .mask {
                    RoundedCornersShape(corners: [.topLeft, .topRight], radius: 6.0)
                }
                .shadow(radius: 5.0)
                .zIndex(1)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(DisplayedCoordinates())
    }
}

class LocationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.30437, longitude: 103.82458), latitudinalMeters: 400.0, longitudinalMeters: 400.0)

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            log("Location Services authorization changed to When In Use.")
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.startUpdatingLocation()
        } else {
            log("Location Services authorization changed to Don't Allow.")
            manager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        log("Updating location...")
        region.center.latitude = (manager.location?.coordinate.latitude)!
        region.center.longitude = (manager.location?.coordinate.longitude)!
        manager.stopUpdatingLocation()
    }
}
