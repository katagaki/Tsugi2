//
//  MainTabView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import CoreLocation
import MapKit
import SwiftUI

struct MainTabView: View {
    
    @State var defaultTab: Int = 0
    
    @EnvironmentObject var busStopList: BusStopList
    @State var isBusStopListLoaded: Bool = true
    @State var isInitialLoad: Bool = true
    @State var updatedDate: String
    @State var updatedTime: String
    
    @State var nearbyBusStops: [BusStop] = []
    
    @State var isToastShowing: Bool = false
    @State var toastMessage: String = ""
    @State var toastType: ToastType = .None
    
    
    @EnvironmentObject var favorites: FavoriteList
    
    var body: some View {
        TabView(selection: $defaultTab) {
            NearbyView(nearbyBusStops: $nearbyBusStops,
                       showToast: self.showToast)
                .tabItem {
                    Label("TabTitle.Nearby", systemImage: "location.circle.fill")
                }
                .tag(0)
            FavoritesView(showToast: self.showToast)
                .tabItem {
                    Label("TabTitle.Favorites", systemImage: "rectangle.stack.fill")
                }
                .tag(1)
            NotificationsView(showToast: self.showToast)
                .tabItem {
                    Label("TabTitle.Notifications", systemImage: "bell.fill")
                }
                .tag(2)
            DirectoryView(updatedDate: $updatedDate,
                          updatedTime: $updatedTime,
                          showToast: self.showToast)
                .tabItem {
                    Label("TabTitle.Directory", systemImage: "magnifyingglass")
                }
                .tag(3)
            MoreView()
                .tabItem {
                    Label("TabTitle.More", systemImage: "ellipsis")
                }
                .tag(4)
        }
        .onAppear {
            if isInitialLoad {
                defaultTab = defaults.integer(forKey: "StartupTab")
                reloadBusStops(showsProgress: (true))
                isInitialLoad = false
            }
        }
        .overlay {
            ZStack(alignment: .top) {
                if !isBusStopListLoaded {
                    ToastView(message: localized("Directory.BusStopsLoading"), toastType: .Spinner)
                }
                Color.clear
            }
            .padding(EdgeInsets(top: 52.0, leading: 8.0, bottom: 0.0, trailing: 8.0))
            .animation(.default, value: isBusStopListLoaded)
        }
        .overlay {
            ZStack(alignment: .top) {
                if isToastShowing {
                    ToastView(message: toastMessage, toastType: toastType)
                }
                Color.clear
            }
            .padding(EdgeInsets(top: 52.0, leading: 8.0, bottom: 0.0, trailing: 8.0))
            .animation(.default, value: isToastShowing)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func showToast(message: String, type: ToastType = .None) async {
        toastMessage = message
        toastType = type
        isToastShowing = true
        try! await Task.sleep(nanoseconds: UInt64(3 * Double(NSEC_PER_SEC)))
        isToastShowing = false
    }
    
    func reloadBusStops(showsProgress: Bool = false) {
        Task {
            if showsProgress {
                isBusStopListLoaded = false
            }
            let dateFormatter = DateFormatter()
            let timeFormatter = DateFormatter()
            let busStopsFetched = try await fetchAllBusStops()
            busStopList.busStops = busStopsFetched.sorted(by: { a, b in
                a.description?.lowercased() ?? "" < b.description?.lowercased() ?? ""
            })
            dateFormatter.dateStyle = .medium
            timeFormatter.timeStyle = .medium
            updatedDate = dateFormatter.string(from: Date.now)
            updatedTime = timeFormatter.string(from: Date.now)
            isBusStopListLoaded = true
            log("Reloaded bus stop data.")
        }
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(updatedDate: "", updatedTime: "")
            .environmentObject(CoordinateList())
    }
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}
