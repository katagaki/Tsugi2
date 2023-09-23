//
//  FavoritesView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/11.
//

import SwiftUI

struct FavoritesView: View {

    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var coordinateManager: CoordinateManager

    @State var isEditing: Bool = false
    @State var favoriteLocationPendingEdit: FavoriteLocation?

    @State var isEditPending: Bool = false

    @State var isNewPending: Bool = false
    @State var favoriteLocationNewNickname: String = ""

    @State var isNicknameEditPending: Bool = false
    @State var favoriteLocationPendingEditNewNickname: String = ""

    @State var isDeletionPending: Bool = false

    var body: some View {
        NavigationStack(path: $navigationManager.favoritesTabPath) {
            List($favorites.favoriteLocations, id: \.hashValue) { $location in
                Section {
                    if !location.isFault && !location.isDeleted {
                        BusServicesCarousel(dataDisplayMode:
                                                (location.usesLiveBusStopData ?
                                                    .favoriteLocationLiveData : .favoriteLocationCustomData),
                                            locationName: location.nickname ?? "",
                                            busStopCode: (location.usesLiveBusStopData ?
                                                          location.busStopCode : nil),
                                            favoriteLocation: $location)
                        .listRowInsets(EdgeInsets(top: 16.0, leading: 0.0, bottom: 16.0, trailing: 0.0))
                        .opacity(isEditing ? 0.5 : 1.0)
                        .disabled(isEditing)
                    }
                } header: {
                    HStack(alignment: .center, spacing: 6.0) {
                        ListSectionHeader(text: (location.nickname ?? location.busStopCode ?? ""))
                            .font(Font.custom("LTA-Identity", size: 16.0))
                        if isEditing {
                            Button {
                                favoriteLocationPendingEdit = location
                                favoriteLocationPendingEditNewNickname = location.nickname ?? location.busStopCode!
                                isNicknameEditPending = true
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.body)
                            }
                            Spacer()
                            HStack(alignment: .center, spacing: 16.0) {
                                if !location.usesLiveBusStopData && (location.busServices ?? []).count != 0 {
                                    Button {
                                        favoriteLocationPendingEdit = location
                                        isEditPending = true
                                    } label: {
                                        Image(systemName: "arrow.left.arrow.right")
                                            .font(.system(size: 14.0))
                                    }
                                }
                                Button {
                                    Task {
                                        await favorites.moveUp(location)
                                    }
                                } label: {
                                    Image(systemName: "chevron.up")
                                        .font(.system(size: 14.0))
                                }
                                .disabled(location.viewIndex == 0)
                                Button {
                                    Task {
                                        await favorites.moveDown(location)
                                    }
                                } label: {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14.0))
                                }
                                .disabled(location.viewIndex == favorites.favoriteLocations.count - 1)
                                Button {
                                    favoriteLocationPendingEdit = location
                                    isDeletionPending = true
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .font(.system(size: 14.0))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await updateMapDisplay()
                }
            }
            .onChange(of: isEditing, { _, newValue in
                if !newValue {
                    favorites.updateViewFlag.toggle()
                }
            })
            .listStyle(.insetGrouped)
            .listSectionSpacing(0)
            .navigationDestination(for: ViewPath.self, destination: { viewPath in
                switch viewPath {
                case .busService(let bus, let locationName, let busStopCode):
                    BusServiceView(busService: bus,
                                   locationName: locationName,
                                   busStopCode: busStopCode,
                                   showsAddToLocationButton: false)
                case .busStop(let busStop):
                    BusStopView(busStop: busStop)
                default:
                    Color.clear
                }
            })
            .refreshable {
                favorites.updateViewFlag.toggle()
            }
            .overlay {
                if favorites.favoriteLocations.count == 0 {
                    ListHintOverlay(image: "info.circle.fill", text: "Favorites.Hint.NoLocations")
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
                    HStack(alignment: .center, spacing: 16.0) {
                        Toggle(isOn: $isEditing) {
                            Image(systemName: "pencil")
                                .font(.body)
                        }
                        .disabled(favorites.favoriteLocations.count == 0)
                        Button {
                            isNewPending = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.body)
                        }
                    }
                }
            }
            .sheet(isPresented: $isEditPending, content: {
                FavoriteLocationEditView(locationToEdit: $favoriteLocationPendingEdit)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            })
        }
        .alert("Favorites.New.Title", isPresented: $isNewPending, actions: {
            TextField("", text: $favoriteLocationNewNickname)
                .textInputAutocapitalization(.words)
            Button(role: .cancel, action: {
                favoriteLocationNewNickname = ""
            }, label: {
                Text("Alert.Cancel")
            })
            Button(action: {
                Task {
                    await favorites.createNewFavoriteLocation(nickname: favoriteLocationNewNickname)
                    favoriteLocationNewNickname = ""
                }
            }, label: {
                Text("Alert.Create")
            })
        })
        .alert("Favorites.Rename.Title", isPresented: $isNicknameEditPending, actions: {
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
                favoriteLocationPendingEdit = nil
            }, label: {
                Text("Alert.No")
            })
            Button(role: .destructive, action: {
                Task {
                    if let favoriteLocationPendingEdit = favoriteLocationPendingEdit {
                        await favorites.deleteLocation(favoriteLocationPendingEdit)
                        if favorites.favoriteLocations.count == 0 {
                            isEditing = false
                        }
                    }
                }
            }, label: {
                Text("Alert.Yes")
            })
        }, message: {
            Text(localized("Favorites.Delete.Confirm.Message",
                           replacing: favoriteLocationPendingEdit?.nickname ??
                           localized("Favorites.Delete.Confirm.GenericLocationText")))
        })
    }

    func updateMapDisplay() async {
        coordinateManager.removeAll()
        var busStops: [BusStop] = []
        for location in favorites.favoriteLocations where location.usesLiveBusStopData {
            if let busStopCode = location.busStopCode,
               let busStop = dataManager.busStops.first(where: { storedBusStop in
                   storedBusStop.code == busStopCode
               }) {
                busStops.append(busStop)
            }
        }
        coordinateManager.replaceWithCoordinates(from: busStops)
        coordinateManager.updateCameraFlag.toggle()
        log("Favorites view updated displayed coordinates.")
    }

}
