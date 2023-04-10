//
//  NearbyView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import CoreLocationUI
import MapKit
import SwiftUI

struct NearbyView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var busStopList: BusStopList
    @EnvironmentObject var regionManager: RegionManager
    
    @State var isLocationManagerDelegateAssigned: Bool = false
    @State private var locationManager: CLLocationManager = CLLocationManager()
    @StateObject private var locationManagerDelegate: LocationDelegate = LocationDelegate()
    @State var displayedCoordinates: CoordinateList = CoordinateList()
    @State var userTrackingMode: MapUserTrackingMode = .none
    @State var shouldUpdateLocationAsSoonAsPossible: Bool = false
    
    @State var isNearbyBusStopsDetermined: Bool = false
    @Binding var nearbyBusStops: [BusStop]
    
    var showToast: (String, ToastType, Bool) async -> Void
    
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
                                ListSectionHeader(text: (stop.description ?? "Shared.BusStop.Description.None"))
                            }
                        }
                    }
                    .frame(width: metrics.size.width, height: metrics.size.height * 0.55)
                    .scrollIndicators(.never)
                    .shadow(radius: 2.5)
                    .zIndex(1)
                    .listStyle(.insetGrouped)
                    .refreshable {
                        log("Reloading nearby bus stops per the request of the user.")
                        reloadNearbyBusStops()
                    }
                    .overlay {
                        if busStopList.busStops.count == 0 {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else if locationManager.authorizationStatus == .notDetermined || locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                            VStack {
                                ListHintOverlay(image: "exclamationmark.triangle.fill", text: "Nearby.Hint.NoLocation")
                                LocationButton {
                                    updateLocation(usingOnlySignificantChanges: false)
                                }
                                .symbolVariant(.fill)
                                .labelStyle(.titleAndIcon)
                                .foregroundColor(.white)
                                .cornerRadius(100.0)
                            }
                        } else {
                            if isNearbyBusStopsDetermined && nearbyBusStops.count == 0 {
                                ListHintOverlay(image: "exclamationmark.triangle.fill", text: "Nearby.Hint.NoBusStops")
                            }
                        }
                    }
                }
            }
            .onChange(of: locationManagerDelegate.authorizationStatus, perform: { newValue in
                switch newValue {
                case .authorizedWhenInUse:
                    log("Location Services authorization changed to When In Use.")
                    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    updateLocation(usingOnlySignificantChanges: false)
                case .notDetermined:
                    log("Location Services authorization not determined yet.")
                    locationManager.requestWhenInUseAuthorization()
                default:
                    log("Location Services authorization possibly changed to Don't Allow.")
                    nearbyBusStops.removeAll()
                    displayedCoordinates.removeAll()
                }
            })
            .onChange(of: busStopList.busStops, perform: { _ in
                if busStopList.busStops.count > 0 {
                    log("Bus stop list changed.")
                    if locationManager.delegate == nil {
                        locationManagerDelegate.completion = self.reloadNearbyBusStops
                        locationManager.delegate = locationManagerDelegate
                    }
                    updateLocation(usingOnlySignificantChanges: false)
                }
            })
            .onChange(of: scenePhase, perform: { newPhase in
                switch newPhase {
                    case .inactive:
                        log("Scene became inactive from Nearby view.")
                    case .active:
                        log("Scene became active from Nearby view.")
                        if shouldUpdateLocationAsSoonAsPossible {
                            updateLocation(usingOnlySignificantChanges: false)
                            shouldUpdateLocationAsSoonAsPossible = false
                        }
                    case .background:
                        shouldUpdateLocationAsSoonAsPossible = true
                        log("Scene went into the background from Nearby view.")
                    @unknown default:
                        log("Scene change detected, but we don't know what the change was!")
                }
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
            isNearbyBusStopsDetermined = true
        }
    }
    
    func updateLocation(usingOnlySignificantChanges: Bool = true) {
        if usingOnlySignificantChanges {
            log("Start monitoring for significant location changes.")
            locationManager.startMonitoringSignificantLocationChanges()
        } else {
            log("Start updating location.")
            locationManager.startUpdatingLocation()
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
    
    static func showToast(message: String, type: ToastType = .None, hideAutomatically: Bool = true) async { }
    
}

class LocationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {

    var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.354454, longitude: 103.946362),
                                    latitudinalMeters: 250.0,
                                    longitudinalMeters: 250.0)
    var completion: () -> Void = {}
    
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        region.center.latitude = (manager.location?.coordinate.latitude)!
        region.center.longitude = (manager.location?.coordinate.longitude)!
        log("Updated location.")
        manager.stopUpdatingLocation()
        log("Calling completion handler in location delegate.")
        completion()
    }
    
}
