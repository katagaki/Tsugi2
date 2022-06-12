//
//  MainTabView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NearbyView()
                .tabItem {
                    Label("TabTitle.Nearby", image: "TabNearby")
                }
            FavoritesView()
                .tabItem {
                    Label("TabTitle.Favorites", image: "TabFavorites")
                }
            DirectoryView()
                .tabItem {
                    Label("TabTitle.Directory", image: "TabDirectory")
                }
            MoreView()
                .tabItem {
                    Label("TabTitle.More", image: "TabMore")
                }
        }
        .onAppear {
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
