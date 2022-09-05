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
    @State var displayedCoordinate: CLLocationCoordinate2D
    @EnvironmentObject var displayedCoordinates: CoordinateList
    @EnvironmentObject var favorites: FavoriteList
//    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var showToast: (String, Bool) async -> Void
    
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
                            ArrivalInfoDetailView(busStop: busStop, bus: bus)
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
                displayedCoordinates.addCoordinate(from: displayedCoordinate)
                reloadBusArrivals()
            }
        }
//        .onReceive(timer, perform: { _ in
//            reloadBusArrivals()
//        })
//        .onDisappear {
//            timer.upstream.connect().cancel()
//        }
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
            }
            ToolbarItem(placement: .primaryAction) {
                HStack(alignment: .center, spacing: 0.0) {
                    Menu {
                        Button(action: copyBusStopName) {
                            Label("Shared.BusStop.Description.Copy", systemImage: "mappin.circle")
                        }
                        Button(action: copyBusStopCode) {
                            Label("Shared.BusStop.Code.Copy", systemImage: "number")
                        }
                    } label: {
                        Button {
                        } label: {
                            Image(systemName: "square.on.square")
                                .font(.system(size: 14.0, weight: .regular))
                        }
                        .buttonStyle(.bordered)
                        .mask {
                            Circle()
                        }
                    }
                    Button {
                        favorites.addFavoriteLocation(busStop: busStop, usesLiveBusStopData: true)
                        Task {
                            await favorites.saveChanges()
                            await showToast(localized("Shared.BusStop.Toast.Favorited"), true)
                        }
                    } label: {
                        Image(systemName: "rectangle.stack.badge.plus")
                            .font(.system(size: 12.5, weight: .regular))
                    }
                    .buttonStyle(.bordered)
                    .mask {
                        Circle()
                    }
                }
            }
        }
    }
    
    func reloadBusArrivals() {
        Task {
            let busStopsFetched = try await fetchBusArrivals(for: busStop.code)
            busArrivals = (busStopsFetched.arrivals ?? []).sorted(by: { a, b in
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
                          displayedCoordinate: CLLocationCoordinate2D(latitude: 1.29516, longitude: 103.85892),
                          showToast: { _, _ in })
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}
