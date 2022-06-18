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
    @EnvironmentObject var displayedCoordinates: CoordinateList
    
    @EnvironmentObject var busStopList: BusStopList
    @State var isBusStopListLoaded: Bool = true
    @State var isInitialLoad: Bool = true
    @State var updatedDate: String
    @State var updatedTime: String
    
    @EnvironmentObject var favorites: FavoriteList
    
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
                    .edgesIgnoringSafeArea(.top)
                    .safeAreaInset(edge: .bottom) {
                        Text("")
                            .frame(width: metrics.size.width, height: metrics.size.height * 0.60 - 12.0)
                    }
                    .frame(width: metrics.size.width, height: metrics.size.height)
                    .onAppear {
                        locationManager.delegate = locationManagerDelegate
                        locationManager.startUpdatingLocation()
                    }
                TabView {
                    // TODO: To implement
//                    NearbyView()
//                        .tabItem {
//                            Label("TabTitle.Nearby", systemImage: "map.fill")
//                        }
                    FavoritesView()
                        .tabItem {
                            Label("TabTitle.Favorites", systemImage: "star.fill")
                        }
                    DirectoryView(updatedDate: $updatedDate, updatedTime: $updatedTime)
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
                .shadow(radius: 2.5)
                .zIndex(1)
            }
            .onChange(of: isBusStopListLoaded, perform: { newValue in
                reloadBusStops()
            })
            .onAppear {
                if isInitialLoad {
                    Task {
//                        await favorites.deleteAllData("FavoriteLocation")
                        reloadBusStops(showsProgress: (true))
                        isInitialLoad = false
                    }
                }
            }
            .overlay {
                ZStack(alignment: .top) {
                    if !isBusStopListLoaded {
                        HStack(alignment: .center, spacing: 8.0) {
                            ProgressView()
                                .progressViewStyle(.circular)
                            Text("Directory.BusStopsLoading")
                                .font(.body)
                        }
                        .padding(EdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0))
                        .background(Color(uiColor: .systemBackground))
                        .mask {
                            RoundedRectangle(cornerRadius: 8.0)
                        }
                        .shadow(radius: 2.5)
                        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    }
                    Color.clear
                }
                .padding(EdgeInsets(top: 8.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
                .animation(.default, value: isBusStopListLoaded)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func reloadBusStops(showsProgress: Bool = false) {
        Task {
            if showsProgress {
                isBusStopListLoaded = false
            }
            let dateFormatter = DateFormatter()
            let timeFormatter = DateFormatter()
            let busStopsFetched = try await fetchAllBusStops()
            busStopList.busStops = busStopsFetched.sorted(by: { a, b in
                a.description?.lowercased() ?? "" < b.description?.lowercased() ?? ""
            })
            dateFormatter.dateStyle = .medium
            timeFormatter.timeStyle = .medium
            updatedDate = dateFormatter.string(from: Date.now)
            updatedTime = timeFormatter.string(from: Date.now)
            isBusStopListLoaded = true
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(updatedDate: "", updatedTime: "")
            .environmentObject(CoordinateList())
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
