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
    @Binding var isRenamePending: Bool
    @Binding var renameText: String
    @Binding var locationPendingRename: FavoriteLocation?

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
            .alert("Favorites.Rename.Title", isPresented: $isRenamePending) {
                TextField("", text: $renameText)
                    .textInputAutocapitalization(.words)
                Button(role: .cancel) {
                    locationPendingRename = nil
                    renameText = ""
                } label: {
                    Text("Alert.Cancel")
                }
                Button {
                    if let location = locationPendingRename {
                        Task {
                            await favorites.rename(location, to: renameText)
                        }
                    }
                } label: {
                    Text("Alert.Save")
                }
            }
    }

}
