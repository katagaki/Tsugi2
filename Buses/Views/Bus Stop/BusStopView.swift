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
                Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: busStop.latitude ?? 0.0, longitude: busStop.longitude ?? 0.0),
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
                            .frame(height: metrics.safeAreaInsets.top + 44.0)
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
                                BusServiceView(mode: .BusStop,
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
                                ListHintOverlay(image: "exclamationmark.circle.fill", text: "Shared.BusStop.BusServices.None")
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
        .navigationTitle(busStop.description ?? "Shared.BusStop.Description.None")
        .toolbarBackground(.visible, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(busStop.description ?? "Shared.BusStop.Description.None")
                        .font(.system(size: 16.0, weight: .bold))
                    Text(busStop.roadName ?? "Shared.BusStop.Road.None")
                        .font(.system(size: 12.0, weight: .regular))
                        .foregroundColor(.secondary)
                }
                .padding([.leading, .trailing], 8.0)
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
                    if favorites.favoriteLocations.contains(where: { location in
                        location.busStopCode == busStop.code && location.usesLiveBusStopData == true
                    }) == false {
                        Button {
                            Task {
                                await favorites.addFavoriteLocation(busStop: busStop, usesLiveBusStopData: true)
                                await favorites.saveChanges()
                                toaster.showToast(localized("Shared.BusStop.Toast.Favorited").replacingOccurrences(of: "%s", with: busStop.description ?? localized("Shared.BusStop.Description.None")),
                                                        type: .Checkmark,
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
            let busStopsFetched = try await fetchBusArrivals(for: busStop.code)
            busArrivals = busStopsFetched.arrivals ?? []
            busArrivals.sort(by: { a, b in
                a.serviceNo.toInt() ?? 9999 < b.serviceNo.toInt() ?? 9999
            })
            isInitialDataLoading = false
            timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
        }
    }
    
    func copyBusStopName() {
        UIPasteboard.general.string = busStop.description ?? localized("Shared.BusStop.Description.None")
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
