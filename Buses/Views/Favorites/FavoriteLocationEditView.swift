//
//  FavoriteLocationEditView.swift
//  Buses
//
//  Created by 堅書 on 10/4/23.
//

import SwiftUI

struct FavoriteLocationEditView: View {
    
    @EnvironmentObject var favorites: FavoriteList
    
    @Binding var locationToEdit: FavoriteLocation?
    
    var body: some View {
        NavigationStack {
            if let locationToEdit = locationToEdit,
               let favoriteBusServices = (locationToEdit.busServices?.array as? [FavoriteBusService])?.sorted(by: { a, b in
                   a.viewIndex < b.viewIndex
               }) {
                List(favoriteBusServices, id: \.hashValue) { busService in
                    HStack(alignment: .center, spacing: 16.0) {
                        Text(busService.serviceNo ?? "")
                        Spacer()
                        Button {
                            Task {
                                await favorites.moveBusServiceUp(locationToEdit, busService: busService)
                            }
                        } label: {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 18.0))
                        }
                        .buttonStyle(.borderless)
                        .disabled(busService.viewIndex == 0)
                        Button {
                            Task {
                                await favorites.moveBusServiceDown(locationToEdit, busService: busService)
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 18.0))
                        }
                        .buttonStyle(.borderless)
                        .disabled(busService.viewIndex == (locationToEdit.busServices?.count ?? 0) - 1)
                        Button {
                            Task {
                                await favorites.deleteBusService(locationToEdit, busService: busService)
                            }
                        } label: {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 18.0))
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding([.top, .bottom], 4.0)
                }
                .listStyle(.insetGrouped)
                .navigationTitle(localized("Favorites.Edit.Title").replacingOccurrences(of: "%s", with: locationToEdit.nickname ?? localized("Shared.BusStop.Description.None")))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
