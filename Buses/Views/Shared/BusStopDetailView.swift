//
//  BusStopDetailView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import MapKit
import SwiftUI

struct BusStopDetailView: View {
    
    var busStop: BusStop
    @State var busArrivals: [BusService] = []
    @State var isInitialDataLoading: Bool = true
    @EnvironmentObject var displayedCoordinates: CoordinateList
    @EnvironmentObject var favorites: FavoriteList
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var showToast: (String, ToastType) async -> Void
    
    var body: some View {
        List {
            Section {
                if busArrivals.count == 0 {
                    if isInitialDataLoading {
                        HStack(alignment: .center, spacing: 16.0) {
                            Spacer()
                            ProgressView()
                            .progressViewStyle(.circular)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        HStack {
                            Spacer()
                            VStack(alignment: .center, spacing: 8.0) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                                Text("Shared.BusStop.BusServices.None")
                                    .font(.body)
                            }
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                } else {
                    ForEach(busArrivals, id: \.serviceNo) { bus in
                        NavigationLink {
                            ArrivalInfoDetailView(busStop: busStop,
                                                  busService: bus,
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
                }
            } header: {
                Text("Shared.BusStop.BusServices")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            reloadBusArrivals()
        }
        .onAppear {
            if isInitialDataLoading {
                // TODO: Show only 1 annotation when bus stop view is active
                displayedCoordinates.addCoordinate(from: busStop)
                reloadBusArrivals()
            }
        }
        .onDisappear {
            displayedCoordinates.removeAll()
        }
        .onReceive(timer, perform: { _ in
            reloadBusArrivals()
        })
        .navigationTitle(busStop.description ?? "Shared.BusStop.Description.None")
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
                            favorites.addFavoriteLocation(busStop: busStop, usesLiveBusStopData: true)
                            Task {
                                await favorites.saveChanges()
                                await showToast(localized("Shared.BusStop.Toast.Favorited").replacingOccurrences(of: "%s", with: busStop.description ?? localized("Shared.BusStop.Description.None")), .Checkmark)
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
                intFrom(a.serviceNo) ?? 9999 < intFrom(b.serviceNo) ?? 9999
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
                          showToast: { _, _ in })
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}
