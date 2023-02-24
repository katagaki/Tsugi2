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
    
    @State private var locationManager: CLLocationManager = CLLocationManager()
    @StateObject private var locationManagerDelegate: LocationDelegate = LocationDelegate()
    @State var region: MKCoordinateRegion = MKCoordinateRegion()
    @State var userTrackingMode: MapUserTrackingMode = .follow
    @EnvironmentObject var displayedCoordinates: CoordinateList
    
    @EnvironmentObject var busStopList: BusStopList
    @State var isBusStopListLoaded: Bool = true
    @State var isInitialLoad: Bool = true
    @State var isLocationManagerDelegateAssigned: Bool = false
    @State var updatedDate: String
    @State var updatedTime: String
    
    @State var nearbyBusStops: [BusStop] = []
    
    @State var isToastShowing: Bool = false
    @State var toastMessage: String = ""
    @State var toastCheckmark: Bool = false
    
    let locationUpdateTimer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    
    @EnvironmentObject var favorites: FavoriteList
    
    var body: some View {
        GeometryReader { metrics in
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $region,
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: $userTrackingMode,
                    annotationItems: displayedCoordinates.coordinates) { coordinate in
                    MapAnnotation(coordinate: coordinate.clCoordinate()) {
                        // TODO: Fix opening bus stop view
                        NavigationLink(destination: BusStopDetailView(busStop: coordinate.busStop, showToast: self.showToast)) {
                            Button(action: {}) {
                                VStack(alignment: .center, spacing: 4.0) {
                                    Image("ListIcon.Bus")
                                        .resizable()
                                        .frame(minWidth: 20.0, maxWidth: 20.0, minHeight: 20.0, maxHeight: 20.0)
                                        .shadow(radius: 6.0)
                                    StrokeText(text: coordinate.busStop.description ?? "", width: 1.0, color: Color.init(uiColor: .systemBackground).opacity(0.5))
                                        .foregroundColor(.primary)
                                        .font(.caption)
                                        .shadow(radius: 6.0)
                                }
                            }
                        }
                    }
//                    MapMarker(coordinate: coordinate.clCoordinate())
                }
                    .edgesIgnoringSafeArea(.top)
                    .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: metrics.size.height * 0.60, trailing: 0.0))
                TabView(selection: $defaultTab) {
                    // TODO: To implement
                    NearbyView(nearbyBusStops: $nearbyBusStops,
                               showToast: self.showToast)
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
                // TODO: Restore rounded corners when it's possible to manually offset Map elements like in UIKit
//                .mask {
//                    RoundedCornersShape(corners: [.topLeft, .topRight], radius: 12.0)
//                }
                .shadow(radius: 2.5)
                .zIndex(1)
            }
            .onReceive(locationUpdateTimer, perform: { _ in
                if locationManager.authorizationStatus == .authorizedWhenInUse {
                    locationManager.startUpdatingLocation()
                }
            })
            .onChange(of: nearbyBusStops, perform: { newValue in
                displayedCoordinates.removeAll()
                for busStop in nearbyBusStops {
                    displayedCoordinates.addCoordinate(from: busStop)
                }
                log("Updated displayed coordinates.")
            })
            .onAppear {
                if isInitialLoad {
                    defaultTab = defaults.integer(forKey: "StartupTab")
                    Task {
                        reloadBusStops(showsProgress: (true))
                        isInitialLoad = false
                    }
                }
                if !isLocationManagerDelegateAssigned {
                    locationManagerDelegate.completion = self.reloadNearbyBusStops
                    locationManager.delegate = locationManagerDelegate
                    isLocationManagerDelegateAssigned = true
                }
                if locationManager.authorizationStatus != .authorizedWhenInUse {
                    locationManager.requestWhenInUseAuthorization()
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
    
    func showToast(message: String, showsCheckmark: Bool = false) async {
        toastMessage = message
        toastCheckmark = showsCheckmark
        isToastShowing = true
        try! await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
        isToastShowing = false
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
            log("Reloaded bus stop data.")
        }
    }
    
    func reloadNearbyBusStops() {
        Task {
            let currentCoordinate = CLLocation(latitude: locationManagerDelegate.region.center.latitude, longitude: locationManagerDelegate.region.center.longitude)
            var busStopListSortedByDistance: [BusStop] = busStopList.busStops
            busStopListSortedByDistance.sort { a, b in
                let busStopCoordinateA = CLLocation(latitude: a.latitude ?? 0.0, longitude: a.longitude ?? 0.0)
                let busStopCoordinateB = CLLocation(latitude: b.latitude ?? 0.0, longitude: b.longitude ?? 0.0)
                let distanceA = currentCoordinate.distance(from: busStopCoordinateA)
                let distanceB = currentCoordinate.distance(from: busStopCoordinateB)
                return distanceA < distanceB
            }
            nearbyBusStops.removeAll()
            nearbyBusStops.append(contentsOf: busStopListSortedByDistance[0..<(busStopListSortedByDistance.count >= 10 ? 10 : busStopListSortedByDistance.count)])
            log("Reloaded nearby bus stop data.")
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

    var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.30437, longitude: 103.82458), latitudinalMeters: 400.0, longitudinalMeters: 400.0)
    var completion: () -> Void = {}
    
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
        region.center.latitude = (manager.location?.coordinate.latitude)!
        region.center.longitude = (manager.location?.coordinate.longitude)!
        log("Updated location.")
        manager.stopUpdatingLocation()
        completion()
    }
    
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}
