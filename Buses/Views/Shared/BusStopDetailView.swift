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
    @State var busArrivals: [BABusService] = []
    @State var coordinate = CLLocationCoordinate2D(latitude: 1.29516, longitude: 103.85892)
    @State var coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.29516, longitude: 103.85892), latitudinalMeters: 500.0, longitudinalMeters: 500.0)
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        List {
            Section {
                HStack(alignment: .center, spacing: 16.0) {
                    Image("CellCode")
                    Text("Shared.BusStop.Code")
                        .font(.body)
                    Spacer()
                    Text(busStop.code ?? "Shared.BusStop.Code.None")
                        .font(.body.monospaced())
                        .foregroundColor(.secondary)
                }
                HStack(alignment: .center, spacing: 16.0) {
                    Image("CellRoad")
                    Text(busStop.roadName ?? "Shared.BusStopRoadNameNone")
                        .font(.body)
                    Spacer()
                }
            }
            Section {
                Map(coordinateRegion: $coordinateRegion,
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: .none,
                    annotationItems: [coordinate]) { annotations in
                    MapMarker(coordinate: annotations)
                }
                    .listRowInsets(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 250.0, maxHeight: 250.0)
            }
            Section("Shared.BusStop.BusServices") {
                if busArrivals.count == 0 {
                    HStack {
                        Spacer()
                        VStack(alignment: .center, spacing: 8.0) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .symbolRenderingMode(.multicolor)
                            Text("Shared.BusStop.NoBusServices")
                                .font(.body)
                                .fontWeight(.regular)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(busArrivals, id: \.serviceNo) { service in
                        NavigationLink {
                            BusStopDetailView(busStop: busStop) // TODO: Change bus stop to bus service view when implemented
                        } label: {
                            HStack(alignment: .center, spacing: 16.0) {
                                HStack(alignment: .center) {
                                    Text(service.serviceNo)
                                        .font(Font.custom("OceanSansStd-Bold", size: 24.0))
                                        .foregroundColor(.white)
                                        .padding(EdgeInsets(top: 6.0, leading: 16.0, bottom: 2.0, trailing: 16.0))
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .lineLimit(1)
                                }
                                .background(Color("PlateColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 7.0))
                                .frame(minWidth: ((UIScreen.main.bounds.size.width) / 4.5), maxWidth: ((UIScreen.main.bounds.size.width) / 4.5), minHeight: 0, maxHeight: .infinity, alignment: .center)
                                Spacer()
                                Text(getArrivalText(arrivalTime: service.nextBus.estimatedArrivalTime()))
                                    .font(.body)
                                    .fontWeight(.regular)
                            }
                        }
                    }
                }
            }
            .font(.body)
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .textCase(nil)
        }
        .listStyle(.insetGrouped)
        .refreshable {
            reloadBusArrivals()
        }
        .navigationTitle(busStop.description ?? "Shared.BusStop.Description.None")
        .onAppear {
            coordinate = CLLocationCoordinate2D(latitude: busStop.latitude ?? 1.29516, longitude: busStop.longitude ?? 103.85892)
            coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
            reloadBusArrivals()
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
            let busStopsFetched = try await fetchBusArrivals(for: busStop.code ?? "97311")
            busArrivals = busStopsFetched.busServices.sorted(by: { a, b in
                a.serviceNo < b.serviceNo
            })
        }
    }
}

struct BusStopDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleBusStop: BusStop = BusStop(code: "97311", roadName: "Lorem Ipsum Dolor Street", description: "Opp Sample Bus Stop Secondary", latitude: 1.28459, longitude: 103.83275)
        BusStopDetailView(busStop: sampleBusStop)
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}
