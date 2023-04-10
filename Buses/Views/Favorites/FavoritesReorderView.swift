//
//  FavoritesReorderView.swift
//  Buses
//
//  Created by 堅書 on 10/4/23.
//

import SwiftUI

struct FavoritesReorderView: View {
    
    @EnvironmentObject var favorites: FavoriteList
    
    @Binding var locationToReorder: FavoriteLocation?
    
    var body: some View {
        NavigationStack {
            List {
                if let locationToReorder = locationToReorder,
                   var favoriteBusServices = locationToReorder.busServices?.array as? [FavoriteBusService] {
                        ForEach(favoriteBusServices, id: \.hashValue) { busService in
                            Text(busService.serviceNo ?? "")
                        }
                        .onMove { rows, newIndex in
                            // TODO: Fix reordering
                            Task {
                                favoriteBusServices.move(fromOffsets: rows, toOffset: newIndex)
                                for i in 0..<favoriteBusServices.count {
                                    favoriteBusServices[i].viewIndex = Int16(i)
                                }
                                await favorites.saveChanges()
                            }
                        }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(locationToReorder?.nickname ?? "")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
