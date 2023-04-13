//
//  DirectoryView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import CoreLocation
import SwiftUI

struct DirectoryView: View {
    
    @EnvironmentObject var busStopList: BusStopList
    @EnvironmentObject var regionManager: RegionManager
    @EnvironmentObject var shouldReloadBusStopList: BoolState
    
    @State var previousSearchTerm: String = ""
    @State var searchTerm: String = ""
    @State var searchResults: [BusStop] = []
    @State var isSearching: Bool = false
    @Binding var updatedDate: String
    @Binding var updatedTime: String
    
    @State var shouldSortAlphabeticalAscending: Bool = true
    @State var shouldSortAlphabeticalDescending: Bool = false
    @State var shouldSortDistanceClosest: Bool = false
    
    var showToast: (String, ToastType, Bool) async -> Void
    
    var body: some View {
        NavigationStack {
            List {
                if isSearching {
                    Section {
                        ForEach(searchResults, id: \.code) { stop in
                            NavigationLink {
                                BusStopDetailView(busStop: stop,
                                                  showToast: self.showToast)
                            } label: {
                                HStack(alignment: .center, spacing: 16.0) {
                                    Image("ListIcon.BusStop")
                                    VStack(alignment: .leading, spacing: 2.0) {
                                        Text(verbatim: stop.description ?? "Shared.BusStop.Description.None")
                                            .font(.body)
                                        Text(verbatim: stop.roadName ?? "")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    } header: {
                        ListSectionHeader(text: "Directory.SearchResults")
                    }
                } else {
                    Section {
                        NavigationLink {
                            DirectoryMRTMapView()
                        } label: {
                            HStack(alignment: .center, spacing: 16.0) {
                                Image("ListIcon.TrainMap")
                                Text("Directory.MRTMap")
                                    .font(.body)
                            }
                        }
                    } header: {
                        ListSectionHeader(text: "Directory.UsefulResources")
                    }
                    Section {
                        ForEach(busStopList.busStops, id: \.code) { stop in
                            NavigationLink {
                                BusStopDetailView(busStop: stop,
                                                  showToast: self.showToast)
                            } label: {
                                HStack(alignment: .center, spacing: 16.0) {
                                    Image("ListIcon.BusStop")
                                    VStack(alignment: .leading, spacing: 2.0) {
                                        Text(verbatim: stop.description ?? "Shared.BusStop.Description.None")
                                            .font(.body)
                                        Text(verbatim: stop.roadName ?? "")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    } header: {
                        HStack {
                            ListSectionHeader(text: "Directory.BusStops")
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
            .refreshable {
                shouldReloadBusStopList.state = true
            }
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchTerm) { _ in
                let searchTermTrimmed = searchTerm.trimmingCharacters(in: .whitespaces)
                isSearching = (searchTermTrimmed != "" && searchTermTrimmed.count > 1)
                if isSearching {
                    if searchTermTrimmed.contains(previousSearchTerm) {
                        searchResults = searchResults.filter({ stop in
                            (stop.description ?? "").similarTo(searchTermTrimmed)
                        })
                    } else {
                        searchResults = busStopList.busStops.filter({ stop in
                            (stop.description ?? "").similarTo(searchTermTrimmed)
                        })
                    }
                    previousSearchTerm = searchTermTrimmed
                }
            }
            .onChange(of: shouldSortAlphabeticalAscending, perform: { newValue in
                if newValue {
                    shouldSortAlphabeticalDescending = false
                    shouldSortDistanceClosest = false
                    busStopList.busStops.sort { a, b in
                        a.description ?? "" < b.description ?? ""
                    }
                } else {
                    if !shouldSortAlphabeticalAscending &&
                        !shouldSortAlphabeticalDescending &&
                        !shouldSortDistanceClosest {
                        shouldSortAlphabeticalAscending = true
                    }
                }
            })
            .onChange(of: shouldSortAlphabeticalDescending, perform: { newValue in
                if newValue {
                    shouldSortAlphabeticalAscending = false
                    shouldSortDistanceClosest = false
                    busStopList.busStops.sort { a, b in
                        a.description ?? "" > b.description ?? ""
                    }
                } else {
                    if !shouldSortAlphabeticalAscending &&
                        !shouldSortAlphabeticalDescending &&
                        !shouldSortDistanceClosest {
                        shouldSortAlphabeticalDescending = true
                    }
                }
            })
            .onChange(of: shouldSortDistanceClosest, perform: { newValue in
                if newValue {
                    shouldSortAlphabeticalAscending = false
                    shouldSortAlphabeticalDescending = false
                    let currentCoordinate = CLLocation(latitude: regionManager.region.wrappedValue.center.latitude,
                                                       longitude: regionManager.region.wrappedValue.center.longitude)
                    busStopList.busStops.sort { a, b in
                        return currentCoordinate.distanceTo(busStop: a) < currentCoordinate.distanceTo(busStop: b)
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
    
}

struct DirectoryView_Previews: PreviewProvider {
    
    @State static var updatedDate: String = ""
    @State static var updatedTime: String = ""
    
    static var previews: some View {
        DirectoryView(updatedDate: $updatedTime,
                      updatedTime: $updatedTime,
                      showToast: { _, _, _ in })
    }
}

