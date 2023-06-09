//
//  BusStopView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import MapKit
import SwiftUI

struct BusStopView: View {

    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var coordinateManager: CoordinateManager
    @EnvironmentObject var toaster: Toaster

    @Binding var busStop: BusStop
    @State var busArrivals: [BusService] = []
    @State var isInitialDataLoading: Bool = true

    let timer = Timer.publish(every: 10.0, tolerance: 5.0, on: .main, in: .common).autoconnect()

    var body: some View {
        List(busArrivals, id: \.serviceNo) { bus in
            NavigationLink {
                BusServiceView(mode: .busStop,
                                      busService: bus,
                                      busStop: $busStop,
                                      showsAddToLocationButton: true)
            } label: {
                ListBusServiceRow(bus: .constant(bus))
            }
        }
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
        .onReceive(timer, perform: { _ in
            reloadBusArrivals()
        })
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
            ToolbarItem(placement: .primaryAction) {
                HStack(alignment: .center, spacing: 8.0) {
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
    }

    func reloadBusArrivals() {
        Task {
            let busStopsFetched = try await getBusArrivals(for: busStop.code)
            busArrivals = busStopsFetched.arrivals ?? []
            busArrivals.sort(by: { lhs, rhs in
                lhs.serviceNo.toInt() ?? 9999 < rhs.serviceNo.toInt() ?? 9999
            })
            isInitialDataLoading = false
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
