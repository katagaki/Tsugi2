//
//  BusStopView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import MapKit
import SwiftUI

struct BusStopView: View {

    @Environment(\.scenePhase) var scenePhase
    @Environment(FavoritesManager.self) var favorites
    @Environment(CoordinateManager.self) var coordinateManager
    @Environment(Toaster.self) var toaster

    @State var busStop: BusStop
    @State var busArrivals: [BusService] = []
    @State var isInitialDataLoading: Bool = true
    @State var lookAroundScene: MKLookAroundScene?

    let timer = Timer.publish(every: 10.0, tolerance: 5.0, on: .main, in: .common).autoconnect()

    var body: some View {
        List {
            if let lookAroundScene {
                Section {
                    LookAroundPreview(initialScene: lookAroundScene)
                        .frame(height: 160.0)
                        .listRowInsets(EdgeInsets())
                }
            }
            Section {
                ForEach(busArrivals, id: \.serviceNo) { bus in
                    NavigationLink(value: ViewPath.busService(bus,
                                                              atLocation: busStop.name(),
                                                              forBusStopCode: busStop.code)) {
                        ListBusServiceRow(bus: .constant(bus))
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
        .refreshable {
            reloadBusArrivals()
        }
        .onAppear {
            if isInitialDataLoading {
                reloadBusArrivals()
            }
            updateMapDisplay()
        }
        .task {
            await loadLookAroundScene()
        }
        .onReceive(timer, perform: { _ in
            reloadBusArrivals()
        })
        .onChange(of: scenePhase) { _, newPhase in
            // Timers do not fire in the background, so arrivals are out of date on returning to the app
            if newPhase == .active {
                reloadBusArrivals()
            }
        }
        .overlay {
            if isInitialDataLoading {
                HStack(alignment: .center, spacing: 16.0) {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                    Spacer()
                }
            } else {
                if busArrivals.count == 0 {
                    ListHintOverlay(image: "exclamationmark.circle.fill",
                                    text: "Shared.BusStop.BusServices.None")
                }
            }
        }
        .navigationTitle(busStop.name())
        .toolbarBackground(.visible, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SubtitledNavigationTitle(title: busStop.name(),
                                         subtitle: busStop.roadName ?? "Shared.BusStop.Road.None")
                .contextMenu {
                    Button(action: copyBusStopName) {
                        Label("Shared.BusStop.Description.Copy", systemImage: "mappin.circle")
                    }
                    Button(action: copyBusStopCode) {
                        Label("Shared.BusStop.Code.Copy", systemImage: "number")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if !favorites.favoriteLocations.contains(where: { location in
                    location.busStopCode == busStop.code && location.usesLiveBusStopData
                }) {
                    Button {
                        Task {
                            await favorites.addFavoriteLocation(busStop: busStop, usesLiveBusStopData: true)
                            toaster.showToast(localized("Shared.BusStop.Toast.Favorited",
                                                        replacing: busStop.name()),
                                              type: .checkmark,
                                              hidesAutomatically: true)
                        }
                    } label: {
                        Image(systemName: "rectangle.stack.badge.plus")
                            .font(.body)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if let originalDescription = busStop.originalDescription {
                    let urlEncodedDescription = originalDescription
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    Link(destination:
                            URL(string: "maps://?q=\(urlEncodedDescription)%20Stop")!) {
                        Image(systemName: "map")
                    }
                } else if let description = busStop.description {
                    let urlEncodedDescription = description
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    Link(destination:
                            URL(string: "maps://?q=\(urlEncodedDescription)%20Stop")!) {
                        Image(systemName: "map")
                    }
                }
            }
        }
    }

    func reloadBusArrivals() {
        Task {
            let busStopsFetched = try await transit.busArrivals(for: busStop.code)
            busArrivals = busStopsFetched.arrivals ?? []
            busArrivals.sort(by: { lhs, rhs in
                lhs.serviceNo.toInt() ?? 9999 < rhs.serviceNo.toInt() ?? 9999
            })
            isInitialDataLoading = false
        }
    }

    /// Street-level imagery helps find the right side of the road. Not every bus stop has coverage.
    func loadLookAroundScene() async {
        guard let latitude = busStop.latitude, let longitude = busStop.longitude else { return }
        let request = MKLookAroundSceneRequest(coordinate: CLLocationCoordinate2D(latitude: latitude,
                                                                                  longitude: longitude))
        do {
            lookAroundScene = try await request.scene
        } catch {
            log("Look Around is unavailable for bus stop \(busStop.code): \(error.localizedDescription)")
        }
    }

    func updateMapDisplay() {
        coordinateManager.removeAll()
        coordinateManager.addCoordinate(from: busStop)
        coordinateManager.updateCameraFlag.toggle()
        log("Bus Stop view updated displayed coordinates.")
    }

    func copyBusStopName() {
        UIPasteboard.general.string = busStop.name()
    }

    func copyBusStopCode() {
        UIPasteboard.general.string = busStop.code
    }

}
