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

    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var regionManager: MapRegionManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var toaster: Toaster

    @State var displayedCoordinates: CoordinateList = CoordinateList()

    @State var isInitialDataLoaded: Bool = false
    @State var isNearbyBusStopsDetermined: Bool = false
    @State var nearbyBusStops: [BusStop] = []

    var body: some View {
        NavigationStack {
            GeometryReader { metrics in
                VStack(alignment: .trailing, spacing: 0) {
                    NearbyMapView(displayedCoordinates: $displayedCoordinates)
                        .overlay {
                            ZStack(alignment: .topLeading) {
                                BlurGradientView()
                                    .ignoresSafeArea()
                                    .frame(height: metrics.safeAreaInsets.top * 1.25)
                                Color.clear
                            }
                        }
                        .ignoresSafeArea(edges: [.top])
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
                        if dataManager.busStops.count == 0 {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else if !locationManager.isInUsableState() {
                            VStack {
                                ListHintOverlay(image: "exclamationmark.triangle.fill", text: "Nearby.Hint.NoLocation")
                                LocationButton {
                                    locationManager.updateLocation(usingOnlySignificantChanges: false)
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
            .onAppear {
                log("Nearby view appeared.")
                if !locationManager.isInUsableState() {
                    locationManager.requestWhenInUseAuthorization()
                } else {
                    reloadNearbyBusStops()
                }
            }
            .onChange(of: locationManager.authorizationStatus, perform: { newValue in
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
                    displayedCoordinates.removeAll()
                }
            })
            .onChange(of: dataManager.busStops, perform: { _ in
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        locationManager.completion = self.updateLocationManually
                        locationManager.updateLocation(usingOnlySignificantChanges: false)
                    } label: {
                        Image(systemName: "location")
                    }

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
            displayedCoordinates.removeAll()
            for busStop in nearbyBusStops {
                displayedCoordinates.addCoordinate(from: Binding<BusStop>(get: {
                    busStop
                }, set: { busStop in
                    nearbyBusStops[nearbyBusStops.firstIndex(where: { nearbyBusStop in
                        nearbyBusStop.id == busStop.id
                    })!] = busStop
                }))
            }
            log("Updated displayed coordinates to nearby bus stops.")
            isNearbyBusStopsDetermined = true
        }
    }

    func updateLocationManually() {
        regionManager.updateViewFlag = false
        regionManager.updateRegion(newRegion: locationManager.region)
        locationManager.completion = self.reloadNearbyBusStops
    }

}

struct NearbyView_Previews: PreviewProvider {
    static var previews: some View {
        NearbyView()
    }
}
