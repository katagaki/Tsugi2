//
//  DirectoryView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct DirectoryView: View {
    
    @State var busStops: [BusStop] = []
    @State var previousSearchTerm: String = ""
    @State var searchTerm: String = ""
    @State var searchResults: [BusStop] = []
    @State var isSearching: Bool = false
    @State var isBusStopListLoaded: Bool = true
    @State var isInitialLoad: Bool = true
    @EnvironmentObject var displayedCoordinates: DisplayedCoordinates
    
    var body: some View {
        NavigationView {
            List {
                if isSearching {
                    Section {
                        ForEach(searchResults, id: \.code) { stop in
                            NavigationLink {
                                BusStopDetailView(busStop: stop)
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
                        Text("Directory.BusStops")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .textCase(nil)
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
                        Text("Directory.UsefulResources")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .textCase(nil)
                    }
                    Section {
                        if !isBusStopListLoaded {
                            HStack(alignment: .center, spacing: 16.0) {
                                Spacer()
                                ProgressView {
                                    Text("Directory.BusStopsLoading")
                                        .font(.body)
                                }
                                .progressViewStyle(.circular)
                                Spacer()
                            }
                            .listRowBackground(Color.clear)
                        } else {
                            ForEach(busStops, id: \.code) { stop in
                                NavigationLink {
                                    BusStopDetailView(busStop: stop)
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
                        }
                    } header: {
                        Text("Directory.BusStops")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .textCase(nil)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                reloadBusStops()
            }
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchTerm) { _ in
                isSearching = (searchTerm != "" && searchTerm.count > 2)
                if isSearching {
                    if searchTerm.contains(previousSearchTerm) {
                        searchResults = searchResults.filter({ stop in
                            stop.description?.localizedCaseInsensitiveContains(searchTerm) ?? false || stop.roadName?.localizedCaseInsensitiveContains(searchTerm) ?? false || stop.code.localizedCaseInsensitiveContains(searchTerm)
                        })
                    } else {
                        searchResults = busStops.filter({ stop in
                            stop.description?.localizedCaseInsensitiveContains(searchTerm) ?? false || stop.roadName?.localizedCaseInsensitiveContains(searchTerm) ?? false || stop.code.localizedCaseInsensitiveContains(searchTerm)
                        })
                    }
                    previousSearchTerm = searchTerm
                }
            }
            .onAppear {
                displayedCoordinates.removeAll()
                // TODO: Display all bus stops in view area
            }
            .navigationTitle("ViewTitle.Directory")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if isInitialLoad {
                reloadBusStops(showsProgress: (true))
                isInitialLoad = false
            }
        }
    }
    
    func reloadBusStops(showsProgress: Bool = false) {
        Task {
            if showsProgress {
                isBusStopListLoaded = false
            }
            let busStopsFetched = try await fetchAllBusStops()
            busStops = busStopsFetched.sorted(by: { a, b in
                a.description ?? "" < b.description ?? ""
            })
            isBusStopListLoaded = true
        }
    }
}

struct DirectoryView_Previews: PreviewProvider {
    static var previews: some View {
        DirectoryView()
    }
}

