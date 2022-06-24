//
//  FavoritesView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct FavoritesView: View {
    
    @State var listInset: Double = 0.0
    @EnvironmentObject var favorites: FavoriteList
    
    var body: some View {
        NavigationView {
            List {
                ForEach(favorites.favoriteLocations, id: \.busStopCode) { location in
                    Section {
                        FavoriteLocationCarouselView(favoriteLocation: location)
                            .listRowInsets(EdgeInsets(top: 16.0, leading: 0.0, bottom: 16.0, trailing: 0.0))
                    } header: {
                        HStack(alignment: .center, spacing: 6.0) {
                            Text((location.nickname ?? location.busStopCode!)) // TODO: Get bus stop name using API
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .textCase(nil)
                            Button {
                                // TODO: Edit
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.body)
                            }
                            .disabled(true)
                            Spacer()
                            HStack(alignment: .center, spacing: 16.0) {
                                Button {
                                    Task {
                                        await favorites.moveUp(location)
                                    }
                                } label: {
                                    Image(systemName: "chevron.up")
                                        .font(.body)
                                }
                                .disabled(location.viewIndex == 0)
                                Button {
                                    Task {
                                        await favorites.moveDown(location)
                                    }
                                } label: {
                                    Image(systemName: "chevron.down")
                                        .font(.body)
                                }
                                .disabled(location.viewIndex == favorites.favoriteLocations.count - 1)
                                Button {
                                    Task {
                                        await favorites.deleteLocation(location)
                                    }
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .font(.body)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                favorites.reloadData()
            }
            .overlay {
                if favorites.favoriteLocations.count == 0 {
                    VStack(alignment: .center, spacing: 4.0) {
                        Image(systemName: "questionmark.app.dashed")
                            .font(.system(size: 32.0, weight: .regular))
                            .foregroundColor(.secondary)
                        Text("Favorites.Hint")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(16.0)
                }
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
                        Button {
                            // TODO: Show add location alert
                        } label: {
                            Image(systemName: "rectangle.stack.badge.plus")
                                .font(.system(size: 12.5, weight: .regular))
                        }
                        .buttonStyle(.bordered)
                        .mask {
                            Circle()
                        }
                        .disabled(true) // TODO: To implement
                    }
                }
            }
        }
    }
    
}

struct FavoritesView_Previews: PreviewProvider {
    
    static var previews: some View {
        FavoritesView()
    }
    
}
