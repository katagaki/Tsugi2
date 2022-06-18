//
//  FavoritesView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct FavoritesView: View {
    
    @State var isEditing: Bool = false
    @EnvironmentObject var favorites: FavoriteList
    
    var body: some View {
        NavigationView {
            List {
                ForEach(favorites.favoriteLocations, id: \.busStopCode) { stop in
                    Section {
                        FavoriteLocationCarouselView(favoriteLocation: stop)
                        .listRowInsets(EdgeInsets(top: 16.0, leading: 0.0, bottom: 16.0, trailing: 0.0))
                    } header: {
                        Text((stop.nickname ?? stop.busStopCode!)) // TODO: Get bus stop name using API
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .textCase(nil)
                    }
                }
                .onMove(perform: move)
                .onDelete(perform: delete)
            }
            .listStyle(.insetGrouped)
            .refreshable {
                favorites.reloadData()
            }
            .navigationTitle("ViewTitle.Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ViewTitle.Favorites")
                        .font(.system(size: 24.0, weight: .bold))
                }
                ToolbarItem(placement: .principal) {
                    Spacer()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(alignment: .center, spacing: 8.0) {
                        EditButton()
                        Button {
                            // TODO: Show add location alert
                        } label: {
                            Image(systemName: "rectangle.stack.fill.badge.plus")
                                .font(.system(size: 14.0, weight: .regular))
                        }
                        .buttonStyle(.bordered)
                        .mask {
                            Circle()
                        }
                    }
                }
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        // TODO: Reorder favorites
    }
    
    func delete(at offsets: IndexSet) {
        favorites.deleteLocation(at: offsets)
        Task {
            await favorites.saveChanges()
        }
    }
    
}

struct FavoritesView_Previews: PreviewProvider {
    
    static var previews: some View {
        FavoritesView()
    }
    
}
