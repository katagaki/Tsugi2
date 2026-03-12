//
//  FavoriteAlertsModifier.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import SwiftUI

struct FavoriteAlertsModifier: ViewModifier {

    @Binding var isNewPending: Bool
    @Binding var favoriteLocationNewNickname: String
    @Binding var isNicknameEditPending: Bool
    @Binding var favoriteLocationPendingEdit: FavoriteLocation?
    @Binding var favoriteLocationPendingEditNewNickname: String
    @Binding var isDeletionPending: Bool
    @Binding var isEditing: Bool

    var favorites: FavoritesManager

    func body(content: Content) -> some View {
        content
            .alert("Favorites.New.Title", isPresented: $isNewPending) {
                TextField("", text: $favoriteLocationNewNickname)
                    .textInputAutocapitalization(.words)
                Button(role: .cancel) {
                    favoriteLocationNewNickname = ""
                } label: {
                    Text("Alert.Cancel")
                }
                Button {
                    Task {
                        await favorites.createNewFavoriteLocation(nickname: favoriteLocationNewNickname)
                        favoriteLocationNewNickname = ""
                    }
                } label: {
                    Text("Alert.Create")
                }
            }
            .alert("Favorites.Rename.Title", isPresented: $isNicknameEditPending) {
                TextField("", text: $favoriteLocationPendingEditNewNickname)
                    .textInputAutocapitalization(.words)
                Button(role: .cancel) {
                    favoriteLocationPendingEdit = nil
                    favoriteLocationPendingEditNewNickname = ""
                } label: {
                    Text("Alert.Cancel")
                }
                Button {
                    Task {
                        if let favoriteLocationPendingEdit = favoriteLocationPendingEdit {
                            await favorites.rename(favoriteLocationPendingEdit,
                                                   to: favoriteLocationPendingEditNewNickname)
                        }
                    }
                } label: {
                    Text("Alert.Save")
                }
            }
            .alert("Favorites.Delete.Confirm.Title", isPresented: $isDeletionPending) {
                Button(role: .cancel) {
                    favoriteLocationPendingEdit = nil
                } label: {
                    Text("Alert.No")
                }
                Button(role: .destructive) {
                    Task {
                        if let favoriteLocationPendingEdit = favoriteLocationPendingEdit {
                            await favorites.deleteLocation(favoriteLocationPendingEdit)
                            if favorites.favoriteLocations.count == 0 {
                                isEditing = false
                            }
                        }
                    }
                } label: {
                    Text("Alert.Yes")
                }
            } message: {
                Text(localized("Favorites.Delete.Confirm.Message",
                               replacing: favoriteLocationPendingEdit?.nickname ??
                               localized("Favorites.Delete.Confirm.GenericLocationText")))
            }
    }

}
