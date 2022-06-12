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
                    Label("TabTitle.Nearby", systemImage: "map.fill")
                }
            FavoritesView()
                .tabItem {
                    Label("TabTitle.Favorites", systemImage: "star.fill")
                }
            DirectoryView()
                .tabItem {
                    Label("TabTitle.Directory", systemImage: "book.closed.fill")
                }
            MoreView()
                .tabItem {
                    Label("TabTitle.More", systemImage: "ellipsis")
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
