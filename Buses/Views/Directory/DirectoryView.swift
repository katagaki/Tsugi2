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
    
    @State var previousSearchTerm: String = ""
    @State var searchTerm: String = ""
    @State var searchResults: [BusStop] = []
    @State var isSearching: Bool = false
    @Binding var updatedDate: String
    @Binding var updatedTime: String
    
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
                        Text("Directory.SearchResults")
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
                        Text("Directory.BusStops")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .textCase(nil)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchTerm) { _ in
                let searchTermTrimmed = searchTerm.trimmingCharacters(in: .whitespaces)
                isSearching = (searchTermTrimmed != "" && searchTermTrimmed.count > 2)
                if isSearching {
                    if searchTermTrimmed.contains(previousSearchTerm) {
                        searchResults = searchResults.filter({ stop in
                            stop.description?.localizedCaseInsensitiveContains(searchTermTrimmed) ?? false || stop.roadName?.localizedCaseInsensitiveContains(searchTermTrimmed) ?? false || stop.code.localizedCaseInsensitiveContains(searchTermTrimmed)
                        })
                    } else {
                        searchResults = busStopList.busStops.filter({ stop in
                            stop.description?.localizedCaseInsensitiveContains(searchTermTrimmed) ?? false || stop.roadName?.localizedCaseInsensitiveContains(searchTermTrimmed) ?? false || stop.code.localizedCaseInsensitiveContains(searchTermTrimmed)
                        })
                    }
                    previousSearchTerm = searchTermTrimmed
                }
            }
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

