//
//  DirectoryView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import CoreLocation
import SwiftUI

struct DirectoryView: View {

    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var regionManager: RegionManager
    @EnvironmentObject var coordinateManager: CoordinateManager

    @State var previousSearchTerm: String = ""
    @State var searchTerm: String = ""
    @State var searchResults: [BusStop] = []
    @State var isSearching: Bool = false
    @Binding var updatedDate: String
    @Binding var updatedTime: String

    @State var shouldSortAlphabeticalAscending: Bool = true
    @State var shouldSortAlphabeticalDescending: Bool = false
    @State var shouldSortDistanceClosest: Bool = false

    var body: some View {
        NavigationStack(path: $navigationManager.directoryTabPath) {
            List {
                if isSearching {
                    Section {
                        ForEach($searchResults, id: \.code) { $stop in
                            NavigationLink(value: ViewPath.busStop(stop)) {
                                ListBusStopRow(busStop: $stop)
                            }
                        }
                    } header: {
                        ListSectionHeader(text: "Directory.SearchResults")
                            .font(.body)
                    }
                } else {
                    Section {
                        NavigationLink(value: ViewPath.mrtMap) {
                            HStack(alignment: .center, spacing: 16.0) {
                                Image(.listIconTrainMap)
                                Text("Directory.MRTMap")
                                    .font(.body)
                            }
                        }
                        NavigationLink(value: ViewPath.fareCalculator) {
                            HStack(alignment: .center, spacing: 16.0) {
                                Image(.listIconFareCalculator)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("Directory.FareCalculator")
                                    .font(.body)
                            }
                        }
                    } header: {
                        ListSectionHeader(text: "Directory.UsefulResources")
                            .font(.body)
                    }
                    Section {
                        ForEach($dataManager.busStops, id: \.code) { $stop in
                            NavigationLink(value: ViewPath.busStop(stop)) {
                                ListBusStopRow(busStop: $stop)
                            }
                        }
                    } header: {
                        HStack {
                            ListSectionHeader(text: "Directory.BusStops")
                                .font(.body)
                            Spacer()
                            Menu {
                                Toggle(isOn: $shouldSortAlphabeticalAscending) {
                                    Text("Directory.BusStops.Sort.AlphabeticalAscending")
                                }
                                Toggle(isOn: $shouldSortAlphabeticalDescending) {
                                    Text("Directory.BusStops.Sort.AlphabeticalDescending")
                                }
                                Toggle(isOn: $shouldSortDistanceClosest) {
                                    Text("Directory.BusStops.Sort.DistanceClosest")
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.system(size: 14.0))
                            }
                            .labelsHidden()
                            .textCase(nil)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationDestination(for: ViewPath.self, destination: { viewPath in
                switch viewPath {
                case .busService(let bus, let locationName, let busStopCode):
                    BusServiceView(busService: bus,
                                   locationName: locationName,
                                   busStopCode: busStopCode,
                                   showsAddToLocationButton: true)
                case .busStop(let busStop):
                    BusStopView(busStop: busStop)
                case .mrtMap:
                    WebView(url: URL(string: "https://www.lta.gov.sg/content/ltagov/en/map/train.html")!)
                        .navigationTitle("ViewTitle.MRTMap")
                case .fareCalculator:
                    WebView(url: URL(string: "https://www.lta.gov.sg/content/ltagov/en/map/fare-calculator.html")!)
                        .navigationTitle("ViewTitle.FareCalculator")
                default:
                    Color.clear
                }
            })
            .refreshable {
                dataManager.shouldReloadBusStopList = true
            }
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
            .onAppear {
                updateMapDisplay()
            }
            .onChange(of: searchTerm, { _, _ in
                let searchTermTrimmed = searchTerm.trimmingCharacters(in: .whitespaces)
                isSearching = (searchTermTrimmed != "" && searchTermTrimmed.count > 1)
                if isSearching {
                    if searchTermTrimmed.contains(previousSearchTerm) {
                        searchResults = searchResults.filter({ stop in
                            (stop.name()).similarTo(searchTermTrimmed)
                        })
                    } else {
                        searchResults = dataManager.busStops.filter({ stop in
                            (stop.name()).similarTo(searchTermTrimmed)
                        })
                    }
                    previousSearchTerm = searchTermTrimmed
                }
            })
            .onChange(of: shouldSortAlphabeticalAscending, { _, newValue in
                if newValue {
                    shouldSortAlphabeticalDescending = false
                    shouldSortDistanceClosest = false
                    dataManager.busStops.sort { lhs, rhs in
                        lhs.name() < rhs.name()
                    }
                } else {
                    if !shouldSortAlphabeticalAscending &&
                        !shouldSortAlphabeticalDescending &&
                        !shouldSortDistanceClosest {
                        shouldSortAlphabeticalAscending = true
                    }
                }
            })
            .onChange(of: shouldSortAlphabeticalDescending, { _, newValue in
                if newValue {
                    shouldSortAlphabeticalAscending = false
                    shouldSortDistanceClosest = false
                    dataManager.busStops.sort { lhs, rhs in
                        lhs.name() > rhs.name()
                    }
                } else {
                    if !shouldSortAlphabeticalAscending &&
                        !shouldSortAlphabeticalDescending &&
                        !shouldSortDistanceClosest {
                        shouldSortAlphabeticalDescending = true
                    }
                }
            })
            .onChange(of: shouldSortDistanceClosest, { _, newValue in
                if newValue {
                    shouldSortAlphabeticalAscending = false
                    shouldSortAlphabeticalDescending = false
                    let currentCoordinate = CLLocation(latitude: regionManager.region.wrappedValue.center.latitude,
                                                       longitude: regionManager.region.wrappedValue.center.longitude)
                    dataManager.busStops.sort { lhs, rhs in
                        return currentCoordinate.distanceTo(busStop: lhs) < currentCoordinate.distanceTo(busStop: rhs)
                    }
                } else {
                    if !shouldSortAlphabeticalAscending &&
                        !shouldSortAlphabeticalDescending &&
                        !shouldSortDistanceClosest {
                        shouldSortDistanceClosest = true
                    }
                }
            })
            .navigationTitle("ViewTitle.Directory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ViewTitle.Directory")
                        .font(.system(size: 24.0, weight: .bold))
                }
                ToolbarItem(placement: .principal) {
                    Spacer()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    VStack(alignment: .trailing) {
                        Text("Directory.LastUpdated")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(updatedDate)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    func updateMapDisplay() {
        coordinateManager.removeAll()
        coordinateManager.updateCameraFlag.toggle()
        log("Directory view updated displayed coordinates.")
    }

}
