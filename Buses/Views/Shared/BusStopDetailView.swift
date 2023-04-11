//
//  BusStopDetailView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import MapKit
import SwiftUI

struct BusStopDetailView: View {
    
    @EnvironmentObject var favorites: FavoriteList
    
    var busStop: BusStop
    @State var busArrivals: [BusService] = []
    @State var isInitialDataLoading: Bool = true
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var showToast: (String, ToastType, Bool) async -> Void
    
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
                        MapStopView(busStop: busStop)
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
                    if isInitialDataLoading {
                        HStack(alignment: .center, spacing: 16.0) {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(.circular)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        if busArrivals.count > 0 {
                            Section {
                                ForEach(busArrivals, id: \.hashValue) { bus in
                                    NavigationLink {
                                        ArrivalInfoDetailView(mode: .BusStop,
                                                              busService: bus,
                                                              busStop: busStop,
                                                              showsAddToLocationButton: true,
                                                              showToast: self.showToast)
                                    } label: {
                                        HStack(alignment: .center, spacing: 8.0) {
                                            BusNumberPlateView(serviceNo: bus.serviceNo)
                                            Divider()
                                            VStack(alignment: .leading, spacing: 2.0) {
                                                HStack(alignment: .center, spacing: 4.0) {
                                                    Text(arrivalTimeTo(date: bus.nextBus?.estimatedArrivalTime()))
                                                        .font(.body)
                                                    switch bus.nextBus?.feature {
                                                    case .WheelchairAccessible:
                                                        Image(systemName: "figure.roll")
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    default:
                                                        Text("")
                                                    }
                                                    switch bus.nextBus?.type {
                                                    case .DoubleDeck:
                                                        Image(systemName: "bus.doubledecker")
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    case .none:
                                                        Text("")
                                                    default:
                                                        Image(systemName: "bus")
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                                if let arrivalTime = bus.nextBus2?.estimatedArrivalTime() {
                                                    Text(localized("Shared.BusArrival.Subsequent") + arrivalTimeTo(date: arrivalTime))
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            Spacer()
                                        }
                                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                                            return 0
                                        }
                                    }
                                }
                            } header: {
                                ListSectionHeader(text: "Shared.BusStop.BusServices")
                            }
                        }
                    }
                }
                .frame(width: metrics.size.width, height: metrics.size.height * 0.6)
                .scrollIndicators(.never)
                .shadow(radius: 2.5)
                .zIndex(1)
                .listStyle(.insetGrouped)
                .refreshable {
                    reloadBusArrivals()
                }
                .overlay {
                    if busArrivals.count == 0 && !isInitialDataLoading {
                        ListHintOverlay(image: "exclamationmark.circle.fill", text: "Shared.BusStop.BusServices.None")
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
                                await showToast(localized("Shared.BusStop.Toast.Favorited").replacingOccurrences(of: "%s", with: busStop.description ?? localized("Shared.BusStop.Description.None")), .Checkmark, true)
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
            let busStopsFetched = try await fetchBusArrivals(for: busStop.code)
            busArrivals = busStopsFetched.arrivals ?? []
            busArrivals.sort(by: { a, b in
                a.serviceNo.toInt() ?? 9999 < b.serviceNo.toInt() ?? 9999
            })
            isInitialDataLoading = false
        }
    }
    
    func copyBusStopName() {
        UIPasteboard.general.string = busStop.description ?? localized("Shared.BusStop.Description.None")
    }
    
    func copyBusStopCode() {
        UIPasteboard.general.string = busStop.code
    }
    
}

struct BusStopDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleBusStop: BusStop = BusStop()
        BusStopDetailView(busStop: sampleBusStop,
                          showToast: { _, _, _ in })
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}
