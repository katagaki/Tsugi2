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
    @EnvironmentObject var toaster: Toaster

    @Binding var busStop: BusStop
    @State var busArrivals: [BusService] = []
    @State var isInitialDataLoading: Bool = true

    @State var timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { metrics in
            VStack(alignment: .trailing, spacing: 0) {
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: busStop.latitude ?? 0.0,
                                                   longitude: busStop.longitude ?? 0.0),
                    latitudinalMeters: 100.0,
                    longitudinalMeters: 100.0)),
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: .constant(.none),
                    annotationItems: [busStop]) { busStop in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: busStop.latitude ?? 0.0,
                                                                     longitude: busStop.longitude ?? 0.0)) {
                        MapStopView(busStop: $busStop)
                        }
                    }
                .overlay {
                    ZStack(alignment: .topLeading) {
                        BlurGradientView()
                            .ignoresSafeArea()
                            .frame(height: metrics.safeAreaInsets.top * 1.25)
                        Color.clear
                    }
                }
                .ignoresSafeArea(edges: [.top])
                if isInitialDataLoading {
                    HStack(alignment: .center, spacing: 16.0) {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(.circular)
                        Spacer()
                    }
                } else {
                    if busArrivals.count > 0 {
                        List(busArrivals, id: \.hashValue) { bus in
                            NavigationLink {
                                BusServiceView(mode: .busStop,
                                                      busService: bus,
                                                      busStop: $busStop,
                                                      showsAddToLocationButton: true)
                            } label: {
                                ListBusServiceRow(bus: .constant(bus))
                            }
                        }
                        .scrollIndicators(.never)
                        .listStyle(.insetGrouped)
                        .refreshable {
                            reloadBusArrivals()
                        }
                        .frame(width: metrics.size.width, height: metrics.size.height * 0.6)
                        .shadow(radius: 2.5)
                        .zIndex(1)
                    } else {
                        Color(uiColor: .systemGroupedBackground)
                            .frame(width: metrics.size.width, height: metrics.size.height * 0.6)
                            .shadow(radius: 2.5)
                            .zIndex(1)
                            .overlay {
                                ListHintOverlay(image: "exclamationmark.circle.fill",
                                                text: "Shared.BusStop.BusServices.None")
                            }
                    }
                }
            }
        }
        .onAppear {
            if isInitialDataLoading {
                reloadBusArrivals()
            }
        }
        .onReceive(timer, perform: { _ in
            reloadBusArrivals()
        })
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
                }
            }
        }
    }

    func reloadBusArrivals() {
        Task {
            timer.upstream.connect().cancel()
            let busStopsFetched = try await getBusArrivals(for: busStop.code)
            busArrivals = busStopsFetched.arrivals ?? []
            busArrivals.sort(by: { lhs, rhs in
                lhs.serviceNo.toInt() ?? 9999 < rhs.serviceNo.toInt() ?? 9999
            })
            isInitialDataLoading = false
            timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
        }
    }

    func copyBusStopName() {
        UIPasteboard.general.string = busStop.name()
    }

    func copyBusStopCode() {
        UIPasteboard.general.string = busStop.code
    }

}

struct BusStopView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleBusStop: BusStop = BusStop()
        BusStopView(busStop: .constant(sampleBusStop))
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}
