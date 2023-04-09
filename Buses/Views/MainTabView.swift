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
    
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var busStopList: BusStopList
    @EnvironmentObject var favorites: FavoriteList
    @EnvironmentObject var shouldReloadBusStopList: BoolState
    
    @State var defaultTab: Int = 0
    
    @State var isInitialLoad: Bool = true
    @State var updatedDate: String
    @State var updatedTime: String
    
    @State var nearbyBusStops: [BusStop] = []
    
    @State var isToastShowing: Bool = false
    @State var toastMessage: String = ""
    @State var toastType: ToastType = .None
    
    
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
                reloadBusStopList()
                isInitialLoad = false
            }
        }
        .onChange(of: shouldReloadBusStopList.state, perform: { newValue in
            if newValue {
                reloadBusStopList(forceServer: true)
            }
        })
        .onChange(of: networkMonitor.isConnected) { isConnected in
            if isConnected {
                log("Network connection reappeared!")
                isToastShowing = false
                log("Retrying fetch of bus stop data.")
                reloadBusStopList()
            } else {
                log("Network connection disappeared!")
                Task {
                    await showToast(message: localized("Shared.Error.InternetConnection"), type: .PersistentError, hideAutomatically: false)
                }
            }
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
    
    func showToast(message: String, type: ToastType = .None, hideAutomatically: Bool = true) async {
        toastMessage = message
        toastType = type
        isToastShowing = true
        if hideAutomatically {
            try! await Task.sleep(nanoseconds: UInt64(3 * Double(NSEC_PER_SEC)))
            isToastShowing = false
        }
    }
    
    func reloadBusStopList(forceServer: Bool = false) {
        Task {
            await showToast(message: localized("Directory.BusStopsLoading"), type: .Spinner, hideAutomatically: false)
            if defaults.object(forKey: "StoredBusStopList") == nil || forceServer {
                await reloadBusStopListFromServer()
                log("Reloaded bus stop data from server.")
            } else {
                reloadBusStopListFromStoredMemory()
                log("Reloaded bus stop data from memory.")
            }
            shouldReloadBusStopList.state = false
            isToastShowing = false
        }
    }
    
    func reloadBusStopListFromServer() async {
        do {
            let busStopsFetched = try await fetchAllBusStops()
            busStopList.busStops = busStopsFetched.sorted(by: { a, b in
                a.description?.lowercased() ?? "" < b.description?.lowercased() ?? ""
            })
            if defaults.bool(forKey: "UseProperText") {
                busStopList.busStops.forEach { busStop in
                    busStop.description = properName(for: busStop.description ?? localized("Shared.BusStop.Description.None"))
                    busStop.roadName = properName(for: busStop.roadName ?? localized("Shared.BusStop.Description.None"))
                }
            }
            defaults.set(encode(busStopList), forKey: "StoredBusStopList")
            defaults.set(Date.now, forKey: "StoredBusStopListUpdatedDate")
            setLastUpdatedTimeForBusStopData()
        } catch {
            log("WARNING×WARNING×WARNING\nNetwork does not look like it's working, bus stop data may be incomplete!")
            await showToast(message: localized("Shared.Error.InternetConnection"), type: .PersistentError, hideAutomatically: false)
        }
    }
    
    func reloadBusStopListFromStoredMemory() {
        if let storedBusStopListJSON = defaults.string(forKey: "StoredBusStopList"),
           let storedUpdatedDate = defaults.object(forKey: "StoredBusStopListUpdatedDate") as? Date,
           let storedBusStopList: BusStopList = decode(fromData: storedBusStopListJSON.data(using: .utf8) ?? Data()) {
            log("Fetched bus stop data from memory with \(busStopList.busStops.count) bus stop(s).")
            busStopList.metadata = storedBusStopList.metadata
            busStopList.busStops = storedBusStopList.busStops
            setLastUpdatedTimeForBusStopData(storedUpdatedDate)
            return
        }
        log("Could not decode stored data successfully, re-fetching bus stop data from server...", level: .error)
        reloadBusStopListFromStoredMemory()
    }
    
    func setLastUpdatedTimeForBusStopData(_ date: Date = Date.now) {
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        timeFormatter.timeStyle = .medium
        updatedDate = dateFormatter.string(from: date)
        updatedTime = timeFormatter.string(from: date)
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(updatedDate: "", updatedTime: "")
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
