//
//  FavoritesView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct FavoritesView: View {
    
    @EnvironmentObject var displayedCoordinates: CoordinateList
    @EnvironmentObject var favorites: FavoriteList
    
    @State var listInset: Double = 0.0
    @State var isDeletionPending: Bool = false
    @State var favoriteLocationPendingDeletion: FavoriteLocation? = nil
    @State var isEditPending: Bool = false
    @State var isEditing: Bool = false
    @State var favoriteLocationPendingEdit: FavoriteLocation? = nil
    @State var favoriteLocationPendingEditNewNickname: String = ""
    
    var showToast: (String, ToastType) async -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(favorites.favoriteLocations, id: \.busStopCode) { location in
                    Section {
                        BusStopCarouselView(mode: .FavoriteLocationLiveData,
                                            favoriteLocation: location,
                                            showToast: self.showToast)
                            .listRowInsets(EdgeInsets(top: 16.0, leading: 0.0, bottom: 16.0, trailing: 0.0))
                            .opacity((isEditing ? 0.5 : 1.0))
                            .disabled(isEditing)
                    } header: {
                        HStack(alignment: .center, spacing: 6.0) {
                            Text((location.nickname ?? location.busStopCode ?? "")) // TODO: Get bus stop name using API
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .textCase(nil)
                            if isEditing {
                                Button {
                                    favoriteLocationPendingEdit = location
                                    favoriteLocationPendingEditNewNickname = location.nickname ?? location.busStopCode!
                                    isEditPending = true
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.body)
                                }
                            }
                            Spacer()
                            if isEditing {
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
                                        favoriteLocationPendingDeletion = location
                                        isDeletionPending = true
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
            }
            .listStyle(.insetGrouped)
            .refreshable {
                favorites.reloadData()
            }
            .onAppear {
                displayedCoordinates.removeAll()
                // TODO: Display favorite locations on Map view
                log("Updated displayed coordinates to favorite locations.")
            }
            .overlay {
                if favorites.favoriteLocations.count == 0 {
                    VStack(alignment: .center, spacing: 4.0) {
                        Image(systemName: "questionmark.circle.fill")
                            .symbolRenderingMode(.multicolor)
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
                        Toggle(isOn: $isEditing) {
                            Image(systemName: "pencil")
                                .font(.body)
                        }
                    }
                }
            }
        }
        .alert("Favorites.Edit.Title", isPresented: $isEditPending, actions: {
            TextField("", text: $favoriteLocationPendingEditNewNickname)
                .textInputAutocapitalization(.words)
            Button(role: .cancel, action: {
                favoriteLocationPendingEdit = nil
                favoriteLocationPendingEditNewNickname = ""
            }, label: {
                Text("Alert.Cancel")
            })
            Button(action: {
                Task {
                    if let favoriteLocationPendingEdit = favoriteLocationPendingEdit {
                        await favorites.rename(favoriteLocationPendingEdit, to: favoriteLocationPendingEditNewNickname)
                    }
                }
            }, label: {
                Text("Alert.Save")
            })
        })
        .alert("Favorites.Delete.Confirm.Title", isPresented: $isDeletionPending, actions: {
            Button(role: .cancel, action: {
                favoriteLocationPendingDeletion = nil
            }, label: {
                Text("Alert.No")
            })
            Button(role: .destructive, action: {
                Task {
                    if let favoriteLocationPendingDeletion = favoriteLocationPendingDeletion {
                        await favorites.deleteLocation(favoriteLocationPendingDeletion)
                    }
                }
            }, label: {
                Text("Alert.Yes")
            })
        }, message: {
            Text(localized("Favorites.Delete.Confirm.Message").replacingOccurrences(of: "%LOCATION%", with: favoriteLocationPendingDeletion?.nickname ?? localized("Favorites.Delete.Confirm.GenericLocationText")))
        })
    }
    
}

struct FavoritesView_Previews: PreviewProvider {
    
    static var previews: some View {
        FavoritesView(showToast: self.showToast)
    }
    
    static func showToast(message: String, type: ToastType = .None) async { }
    
}
