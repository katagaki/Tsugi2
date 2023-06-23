//
//  NearbyView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

#if canImport(CoreLocationUI)
import CoreLocationUI
#endif
import MapKit
import SwiftUI

struct NearbyView: View {

    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var regionManager: RegionManager
    @EnvironmentObject var coordinateManager: CoordinateManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var toaster: Toaster

    @State var isInitialDataLoaded: Bool = false
    @State var isNearbyBusStopsDetermined: Bool = false
    @State var nearbyBusStops: [BusStop] = []

    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing, spacing: 0) {
                List($nearbyBusStops, id: \.hashValue) { $stop in
                    Section {
                        BusServicesCarousel(dataDisplayMode: .busStop,
                                            busStop: $stop,
                                            favoriteLocation: nil)
                        .listRowInsets(EdgeInsets(top: 16.0, leading: 0.0, bottom: 16.0, trailing: 0.0))
                    } header: {
                        HStack(alignment: .center, spacing: 0.0) {
                            ListSectionHeader(text: (stop.name()))
                                .font(Font.custom("LTA-Identity", size: 16.0))
                            Spacer()
                            if !favorites.favoriteLocations.contains(where: { location in
                                location.busStopCode == stop.code && location.usesLiveBusStopData
                            }) {
                                Button {
                                    Task {
                                        await favorites.addFavoriteLocation(busStop: stop,
                                                                            usesLiveBusStopData: true)
                                        toaster.showToast(localized("Shared.BusStop.Toast.Favorited",
                                                                    replacing: stop.name()),
                                                          type: .checkmark,
                                                          hidesAutomatically: true)
                                    }
                                } label: {
                                    Image(systemName: "rectangle.stack.badge.plus")
                                        .font(.system(size: 14.0))
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    log("Reloading nearby bus stops per the request of the user.")
                    reloadNearbyBusStops()
                }
                .overlay {
                    if dataManager.busStops.count == 0 {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else if !locationManager.isInUsableState() {
                        VStack {
                            ListHintOverlay(image: "exclamationmark.triangle.fill", text: "Nearby.Hint.NoLocation")
#if !os(xrOS)
                            LocationButton {
                                locationManager.updateLocation(usingOnlySignificantChanges: false)
                            }
                            .symbolVariant(.fill)
                            .labelStyle(.titleAndIcon)
                            .foregroundColor(.white)
                            .cornerRadius(100.0)
#endif
                        }
                    } else {
                        if isNearbyBusStopsDetermined && nearbyBusStops.count == 0 {
                            ListHintOverlay(image: "exclamationmark.triangle.fill", text: "Nearby.Hint.NoBusStops")
                        }
                    }
                }
            }
            .onAppear {
                log("Nearby view appeared.")
                if !locationManager.isInUsableState() {
                    locationManager.requestWhenInUseAuthorization()
                } else {
                    reloadNearbyBusStops()
                }
            }
            .onChange(of: locationManager.authorizationStatus, { _, newValue in
                switch newValue {
                case .authorizedWhenInUse:
                    log("Location Services authorization changed to When In Use.")
                    locationManager.shared.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    locationManager.updateLocation(usingOnlySignificantChanges: false)
                case .notDetermined:
                    log("Location Services authorization not determined yet.")
                    locationManager.requestWhenInUseAuthorization()
                default:
                    log("Location Services authorization possibly changed to Don't Allow.")
                    nearbyBusStops.removeAll()
                    coordinateManager.removeAll()
                }
            })
            .onChange(of: dataManager.busStops, { _, _ in
                if dataManager.busStops.count > 0 {
                    log("Bus stop list changed.")
                    locationManager.completion = self.reloadNearbyBusStops
                    locationManager.updateLocation(usingOnlySignificantChanges: false)
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
            let currentCoordinate = CLLocation(latitude: locationManager.region.center.latitude,
                                               longitude: locationManager.region.center.longitude)
            var busStopListSortedByDistance: [BusStop] = dataManager.busStops
            busStopListSortedByDistance = busStopListSortedByDistance.filter { busStop in
                currentCoordinate.distanceTo(busStop: busStop) < 500.0
            }
            busStopListSortedByDistance.sort { lhs, rhs in
                return currentCoordinate.distanceTo(busStop: lhs) < currentCoordinate.distanceTo(busStop: rhs)
            }
            nearbyBusStops.removeAll()
            nearbyBusStops.append(contentsOf: busStopListSortedByDistance)
            log("Reloaded nearby bus stop data.")
            regionManager.updateRegion(newRegion: locationManager.region)
            log("Updated Map region.")
            updateMapDisplay()
            isNearbyBusStopsDetermined = true
        }
    }

    func updateMapDisplay() {
        coordinateManager.removeAll()
        coordinateManager.replaceWithCoordinates(from: nearbyBusStops)
        coordinateManager.updateCameraFlag.toggle()
        log("Nearby view updated displayed coordinates.")
    }

}
