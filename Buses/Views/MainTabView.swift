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
    
    let defaults = UserDefaults.standard
    
    @State var defaultTab: Int = 0
    
    @State var locationManager: CLLocationManager = CLLocationManager()
    @StateObject var locationManagerDelegate: LocationDelegate = LocationDelegate()
    @State var userTrackingMode: MapUserTrackingMode = .none
    @EnvironmentObject var displayedCoordinates: CoordinateList
    
    @EnvironmentObject var busStopList: BusStopList
    @State var isBusStopListLoaded: Bool = true
    @State var isInitialLoad: Bool = true
    @State var isLocationManagerDelegateAssigned: Bool = false
    @State var updatedDate: String
    @State var updatedTime: String
    
    @State var isToastShowing: Bool = false
    @State var toastMessage: String = ""
    @State var toastCheckmark: Bool = false
    
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
                        if !isLocationManagerDelegateAssigned {
                            locationManager.delegate = locationManagerDelegate
                            isLocationManagerDelegateAssigned = true
                        }
                        locationManager.startUpdatingLocation()
                    }
                TabView(selection: $defaultTab) {
                    // TODO: To implement
                    NearbyView()
                        .tabItem {
                            Label("TabTitle.Nearby", systemImage: "location.circle.fill")
                        }
                        .tag(0)
                    FavoritesView()
                        .tabItem {
                            Label("TabTitle.Favorites", systemImage: "rectangle.stack.fill")
                        }
                        .tag(1)
                    NotificationsView()
                        .tabItem {
                            Label("TabTitle.Notifications", systemImage: "bell.fill")
                        }
                        .tag(2)
                    DirectoryView(updatedDate: $updatedDate,
                                  updatedTime: $updatedTime,
                                  showToast: self.showToast)
                        .tabItem {
                            Label("TabTitle.Directory", systemImage: "magnifyingglass")
                        }
                        .tag(3)
                    MoreView()
                        .tabItem {
                            Label("TabTitle.More", systemImage: "ellipsis")
                        }
                        .tag(4)
                }
                
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: metrics.size.height * 0.60, maxHeight: metrics.size.height * 0.60)
                .mask {
                    RoundedCornersShape(corners: [.topLeft, .topRight], radius: 6.0)
                }
                .shadow(radius: 2.5)
                .zIndex(1)
            }
            .onAppear {
                if isInitialLoad {
                    defaultTab = defaults.integer(forKey: "StartupTab")
                    Task {
                        reloadBusStops(showsProgress: (true))
                        isInitialLoad = false
                    }
                }
            }
            .overlay {
                ZStack(alignment: .top) {
                    if !isBusStopListLoaded {
                        ToastView(message: localized("Directory.BusStopsLoading"), showsProgressView: true)
                    }
                    Color.clear
                }
                .padding(EdgeInsets(top: 8.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
                .animation(.default, value: isBusStopListLoaded)
            }
            .overlay {
                ZStack(alignment: .top) {
                    if isToastShowing {
                        ToastView(message: toastMessage, showsCheckmark: toastCheckmark)
                    }
                    Color.clear
                }
                .padding(EdgeInsets(top: 8.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
                .animation(.default, value: isToastShowing)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func showToast(message: String, showsCheckmark: Bool = false) {
        toastMessage = message
        toastCheckmark = showsCheckmark
        isToastShowing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isToastShowing = false
        }
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
            DispatchQueue.main.async {
                for busStop in busStopList.busStops {
                    displayedCoordinates.addCoordinate(from: CLLocationCoordinate2D(latitude: busStop.latitude ?? 0.0, longitude: busStop.longitude ?? 0.0))
                }
            }
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
