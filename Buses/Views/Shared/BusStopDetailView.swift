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
    @State var isInitialDataLoaded: Bool = true
    @EnvironmentObject var displayedCoordinates: DisplayedCoordinates
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        List {
            Section {
                HStack(alignment: .center, spacing: 16.0) {
                    Image("ListIcon.Code")
                    Text("Shared.BusStop.Code")
                        .font(.body)
                    Spacer()
                    Text(busStop.code)
                        .font(.body.monospaced())
                        .foregroundColor(.secondary)
                }
                HStack(alignment: .center, spacing: 16.0) {
                    Image("ListIcon.Road")
                    Text("Shared.BusStop.Road")
                        .font(.body)
                    Spacer()
                    Text(busStop.roadName ?? "Shared.BusStop.Road.None")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            Section {
                if busArrivals.count == 0 {
                    if isInitialDataLoaded {
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
                    ForEach(busArrivals, id: \.serviceNo) { service in
                        NavigationLink {
                            BusStopDetailView(busStop: busStop) // TODO: Change bus stop to bus service view when implemented
                        } label: {
                            HStack(alignment: .center, spacing: 16.0) {
                                BusNumberPlateView(serviceNo: service.serviceNo)
                                VStack(alignment: .leading, spacing: 2.0) {
                                    HStack(alignment: .center, spacing: 4.0) {
                                        Text(arrivalTimeTo(date: service.nextBus?.estimatedArrivalTime()))
                                            .font(.body)
                                        switch service.nextBus?.feature {
                                        case .WheelchairAccessible:
                                            Image(systemName: "figure.roll")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        default:
                                            Text("")
                                        }
                                        switch service.nextBus?.type {
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
                                    if let arrivalTime = service.nextBus2?.estimatedArrivalTime() {
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
        .navigationTitle(busStop.description ?? "Shared.BusStop.Description.None")
        .onAppear {
            displayedCoordinates.addCoordinate(from: CLLocationCoordinate2D(latitude: busStop.latitude ?? 1.29516, longitude: busStop.longitude ?? 103.85892))
            if isInitialDataLoaded {
                reloadBusArrivals()
            }
        }
        .onReceive(timer, perform: { _ in
            reloadBusArrivals()
        })
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
    
    func reloadBusArrivals() {
        Task {
            let busStopsFetched = try await fetchBusArrivals(for: busStop.code)
            busArrivals = (busStopsFetched.arrivals ?? []).sorted(by: { a, b in
                a.serviceNo < b.serviceNo
            })
            isInitialDataLoaded = false
        }
    }
}

struct BusStopDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleBusStop: BusStop = BusStop(code: "46779", roadName: "Lorem Ipsum Dolor Street", description: "Opp Sample Bus Stop Secondary", latitude: 1.28459, longitude: 103.83275)
        BusStopDetailView(busStop: sampleBusStop)
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}
