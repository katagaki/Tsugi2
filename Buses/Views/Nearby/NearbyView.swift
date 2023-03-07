//
//  NearbyView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import MapKit
import SwiftUI

struct NearbyView: View {
    
    @EnvironmentObject var busStopList: BusStopList
    
    @State var isLocationManagerDelegateAssigned: Bool = false
    @State private var locationManager: CLLocationManager = CLLocationManager()
    @StateObject private var locationManagerDelegate: LocationDelegate = LocationDelegate()
    @StateObject var regionManager: RegionManager = RegionManager()
    @State var displayedCoordinates: CoordinateList = CoordinateList()
    @State var userTrackingMode: MapUserTrackingMode = .follow
    
    @Binding var nearbyBusStops: [BusStop]
    
    var showToast: (String, ToastType) async -> Void
    
    var body: some View {
        NavigationStack {
            GeometryReader { metrics in
                VStack(alignment: .trailing, spacing: 0) {
                    Map(coordinateRegion: regionManager.region,
                        interactionModes: .all,
                        showsUserLocation: true,
                        userTrackingMode: $userTrackingMode,
                        annotationItems: displayedCoordinates.coordinates) { coordinate in
                        MapAnnotation(coordinate: coordinate.clCoordinate()) {
                            NavigationLink(destination: BusStopDetailView(busStop: coordinate.busStop, showToast: self.showToast)) {
                                MapStopView(busStop: coordinate.busStop)
                            }
                        }
                    }
                        .overlay {
                            ZStack(alignment: .topLeading) {
                                BlurGradientView()
                                    .ignoresSafeArea()
                                    .frame(height: metrics.safeAreaInsets.top + 44.0)
                                Color.clear
                            }
                        }
                        .ignoresSafeArea(edges: [.top])
                    List {
                        ForEach(nearbyBusStops, id: \.code) { stop in
                            Section {
                                BusStopCarouselView(mode: .BusStop,
                                                    busStop: stop,
                                                    showToast: self.showToast)
                                .listRowInsets(EdgeInsets(top: 16.0, leading: 0.0, bottom: 16.0, trailing: 0.0))
                            } header: {
                                Text((stop.description ?? "Shared.BusStop.Description.None")) // TODO: Get bus stop name using API
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .textCase(nil)
                            }
                        }
                    }
                    .frame(width: metrics.size.width, height: metrics.size.height * 0.55)
                    .scrollIndicators(.never)
                    .shadow(radius: 2.5)
                    .zIndex(1)
                    .listStyle(.insetGrouped)
                    .refreshable {
                        reloadNearbyBusStops()
                    }
                    .overlay {
                        if busStopList.busStops.count == 0 {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            if nearbyBusStops.count == 0 {
                                VStack(alignment: .center, spacing: 4.0) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .symbolRenderingMode(.multicolor)
                                        .font(.system(size: 32.0, weight: .regular))
                                        .foregroundColor(.secondary)
                                    Text("Nearby.Hint")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(16.0)
                            }
                        }
                    }
                }
            }
            .onAppear {
                if !isLocationManagerDelegateAssigned {
                    locationManagerDelegate.completion = self.reloadNearbyBusStops
                    locationManager.delegate = locationManagerDelegate
                    isLocationManagerDelegateAssigned = true
                }
                if locationManager.authorizationStatus != .authorizedWhenInUse {
                    locationManager.requestWhenInUseAuthorization()
                }
            }
            .onChange(of: busStopList.busStops, perform: { _ in
                updateLocation(usingOnlySignificantChanges: false)
            })
            .navigationTitle("ViewTitle.Nearby")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ViewTitle.Nearby")
                        .font(.system(size: 24.0, weight: .bold))
                }
                ToolbarItem(placement: .principal) {
                    Spacer()
                }
            }
        }
    }
    
    func reloadNearbyBusStops() {
        Task {
            let currentCoordinate = CLLocation(latitude: locationManagerDelegate.region.center.latitude, longitude: locationManagerDelegate.region.center.longitude)
            var busStopListSortedByDistance: [BusStop] = busStopList.busStops
            busStopListSortedByDistance = busStopListSortedByDistance.filter { busStop in
                distanceBetween(location: currentCoordinate, busStop: busStop) < 250.0
            }
            busStopListSortedByDistance.sort { a, b in
                return distanceBetween(location: currentCoordinate, busStop: a) < distanceBetween(location: currentCoordinate, busStop: b)
            }
            nearbyBusStops.removeAll()
            nearbyBusStops.append(contentsOf: busStopListSortedByDistance[0..<(busStopListSortedByDistance.count >= 10 ? 10 : busStopListSortedByDistance.count)])
            log("Reloaded nearby bus stop data.")
            updateRegion(newRegion: locationManagerDelegate.region)
            log("Updated Map region.")
            displayedCoordinates.removeAll()
            for busStop in nearbyBusStops {
                displayedCoordinates.addCoordinate(from: busStop)
            }
            log("Updated displayed coordinates to nearby bus stops.")
        }
    }
    
    func updateLocation(usingOnlySignificantChanges: Bool = true) {
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            if usingOnlySignificantChanges {
                locationManager.startMonitoringSignificantLocationChanges()
            } else {
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    func updateRegion(newRegion: MKCoordinateRegion) {
        withAnimation {
            regionManager.region.wrappedValue = newRegion
            regionManager.updateViewFlag.toggle()
        }
    }
    
}

struct NearbyView_Previews: PreviewProvider {
    static var previews: some View {
        NearbyView(nearbyBusStops: .constant([]),
                   showToast: self.showToast)
    }
    
    static func showToast(message: String, type: ToastType = .None) async { }
    
}

class LocationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {

    var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.284987, longitude: 103.851721),
                                    latitudinalMeters: 250.0,
                                    longitudinalMeters: 250.0)
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
