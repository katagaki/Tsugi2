//
//  DirectoryView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct DirectoryView: View {
    
    @State var busStops: [BusStop] = []
    @State var searchTerm: String = ""
    @State var searchResults: [BusStop] = []
    @State var isSearching: Bool = false
    @State var isBusStopListLoaded: Bool = true
    @State var isInitialLoad: Bool = true
    
    var body: some View {
        NavigationView {
            List {
                if isSearching {
                    Section(header: Text("Directory.BusStops")) {
                        ForEach(searchResults, id: \.code) { stop in
                            NavigationLink {
                                BusStopDetailView(busStop: stop)
                            } label: {
                                HStack(alignment: .center, spacing: 16.0) {
                                    Image("CellBusStop")
                                    VStack(alignment: .leading, spacing: 2.0) {
                                        Text(verbatim: stop.description ?? "Shared.BusStop.Description.None")
                                            .font(.body)
                                            .fontWeight(.regular)
                                        Text(verbatim: stop.roadName ?? "")
                                            .font(.caption)
                                            .fontWeight(.regular)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .textCase(nil)
                } else {
                    Section(header: Text("Directory.UsefulResources")) {
                        NavigationLink {
                            DirectoryMRTMapView()
                        } label: {
                            HStack(alignment: .center, spacing: 16.0) {
                                Image("CellTrainMap")
                                Text("Directory.MRTMap")
                                    .font(.body)
                                    .fontWeight(.regular)
                            }
                        }
                    }
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .textCase(nil)
                    Section(header: Text("Directory.BusStops")) {
                        if !isBusStopListLoaded {
                            HStack(alignment: .center, spacing: 16.0) {
                                Spacer()
                                ProgressView {
                                    Text("Directory.BusStopsLoading")
                                        .font(.body)
                                        .fontWeight(.regular)
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
                                        Image("CellBusStop")
                                        VStack(alignment: .leading, spacing: 2.0) {
                                            Text(verbatim: stop.description ?? "Shared.BusStop.Description.None")
                                                .font(.body)
                                                .fontWeight(.regular)
                                            Text(verbatim: stop.roadName ?? "")
                                                .font(.caption)
                                                .fontWeight(.regular)
                                                .foregroundColor(.secondary)
                                        }
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
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchTerm) { _ in
                isSearching = (searchTerm != "")
                if isSearching {
                    searchResults = busStops.filter({ stop in
                        stop.description?.localizedCaseInsensitiveContains(searchTerm) ?? false || stop.roadName?.localizedCaseInsensitiveContains(searchTerm) ?? false || stop.code?.localizedCaseInsensitiveContains(searchTerm) ?? false
                    })
                }
            }
            .refreshable {
                reloadBusStops()
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

