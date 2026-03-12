//
//  MainTabView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

#if canImport(CoreLocationUI)
import CoreLocationUI
#endif
import CoreLocation
import MapKit
import SwiftUI

struct MainTabView: View {

    @Environment(\.scenePhase) var scenePhase

    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var regionManager: RegionManager
    @EnvironmentObject var coordinateManager: CoordinateManager
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var toaster: Toaster

    @State var isInitialLoad: Bool = true
    @State var isNotificationsSheetPresented: Bool = false
    @State var isMoreSheetPresented: Bool = false

    // Search
    @State var searchTerm: String = ""
    @State var previousSearchTerm: String = ""
    @State var searchResults: [BusStop] = []

    // Nearby
    @State var isNearbyBusStopsDetermined: Bool = false
    @State var nearbyBusStops: [BusStop] = []

    // Favorites editing
    @State var isEditing: Bool = false
    @State var favoriteLocationPendingEdit: FavoriteLocation?
    @State var isEditPending: Bool = false
    @State var isNewPending: Bool = false
    @State var favoriteLocationNewNickname: String = ""
    @State var isNicknameEditPending: Bool = false
    @State var favoriteLocationPendingEditNewNickname: String = ""
    @State var isDeletionPending: Bool = false

    var body: some View {
        NavigationStack(path: $navigationManager.mainPath) {
            List {
                if searchTerm.trimmingCharacters(in: .whitespaces).count > 1 {
                    searchResultsSection
                } else {
                    locationsSection
                    nearbySection
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(0)
            .navigationDestination(for: ViewPath.self) { viewPath in
                switch viewPath {
                case .busService(let bus, let locationName, let busStopCode):
                    BusServiceView(busService: bus,
                                   locationName: locationName,
                                   busStopCode: busStopCode,
                                   showsAddToLocationButton: true)
                case .busServiceNamed(let serviceNumber, let locationName, let busStopCode):
                    BusServiceView(busService: BusService(serviceNo: serviceNumber,
                                                          operator: .unknown),
                                   locationName: locationName,
                                   busStopCode: busStopCode,
                                   showsAddToLocationButton: false)
                case .busStop(let busStop):
                    BusStopView(busStop: busStop)
                case .mrtMap:
                    WebView(url: URL(string: "https://www.lta.gov.sg/content/ltagov/en/map/train.html")!)
                        .navigationTitle("ViewTitle.MRTMap")
                case .fareCalculator:
                    WebView(url: URL(string: "https://www.lta.gov.sg/content/ltagov/en/map/fare-calculator.html")!)
                        .navigationTitle("ViewTitle.FareCalculator")
                case .moreLicenses:
                    MoreLicensesView()
                }
            }
            .refreshable {
                log("Reloading data per the request of the user.")
                favorites.updateViewFlag.toggle()
                reloadNearbyBusStops()
            }
            .searchable(text: $searchTerm,
                         placement: .toolbar)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        isNotificationsSheetPresented = true
                    } label: {
                        Image(systemName: "bell.fill")
                    }
                    ToolbarSpacer(.fixed)
                    Button {
                        isMoreSheetPresented = true
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button {
                        navigationManager.push(ViewPath.mrtMap)
                    } label: {
                        Image(systemName: "tram.fill")
                    }
                    Button {
                        navigationManager.push(ViewPath.fareCalculator)
                    } label: {
                        Image(systemName: "dollarsign.circle")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isNotificationsSheetPresented) {
                NotificationsView()
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isMoreSheetPresented) {
                MoreView()
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isEditPending) {
                FavoriteLocationEditView(locationToEdit: $favoriteLocationPendingEdit)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
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
        .task {
            if isInitialLoad {
                await reloadBusStopList()
                isInitialLoad = false
            }
        }
        .onAppear {
            log("Main view appeared.")
            if !locationManager.isInUsableState() {
                locationManager.requestWhenInUseAuthorization()
            } else {
                reloadNearbyBusStops()
            }
        }
        .onChange(of: isEditing) { _, newValue in
            if !newValue {
                favorites.updateViewFlag.toggle()
            }
        }
        .onChange(of: searchTerm) { _, _ in
            let searchTermTrimmed = searchTerm.trimmingCharacters(in: .whitespaces)
            if searchTerm.trimmingCharacters(in: .whitespaces).count > 1 {
                if searchTermTrimmed.contains(previousSearchTerm) {
                    searchResults = searchResults.filter { stop in
                        stop.name().similarTo(searchTermTrimmed)
                    }
                } else {
                    searchResults = dataManager.busStops.filter { stop in
                        stop.name().similarTo(searchTermTrimmed)
                    }
                }
                previousSearchTerm = searchTermTrimmed
            }
        }
        .onChange(of: locationManager.authorizationStatus) { _, newValue in
            switch newValue {
            case .authorizedWhenInUse:
                log("Location Services authorization changed to When In Use.")
                locationManager.shared.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.updateLocation(usingOnlySignificantChanges: false)
            case .notDetermined:
                log("Location Services authorization not determined yet.")
                locationManager.requestWhenInUseAuthorization()
            default:
                log("Location Services authorization possibly changed to Don't Allow.")
                nearbyBusStops.removeAll()
                coordinateManager.removeAll()
            }
        }
        .onChange(of: dataManager.busStops) { _, _ in
            if dataManager.busStops.count > 0 {
                log("Bus stop list changed.")
                locationManager.completion = self.reloadNearbyBusStops
                locationManager.updateLocation(usingOnlySignificantChanges: false)
            }
        }
        .onChange(of: dataManager.shouldReloadBusStopList) { _, newValue in
            if newValue {
                Task {
                    await reloadBusStopList(forceServer: true)
                }
            }
        }
        .onChange(of: networkMonitor.isConnected) { _, isConnected in
            if isConnected {
                log("Network connection reappeared!")
                toaster.hideToast()
                Task {
                    log("Retrying fetch of bus stop data.")
                    await reloadBusStopList()
                    toaster.hideToast()
                }
            } else {
                log("Network connection disappeared!")
                toaster.showToast(localized("Shared.Error.InternetConnection"),
                                  type: .persistentError,
                                  hidesAutomatically: false)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .inactive:
                log("Scene became inactive.")
            case .active:
                log("Scene became active.")
                if locationManager.shouldUpdateLocationAsSoonAsPossible {
                    locationManager.updateLocation(usingOnlySignificantChanges: false)
                    locationManager.shouldUpdateLocationAsSoonAsPossible = false
                }
            case .background:
                log("Scene went into the background.")
                locationManager.shouldUpdateLocationAsSoonAsPossible = true
            @unknown default:
                log("Scene change detected, but we don't know what the change was!")
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder var searchResultsSection: some View {
        Section {
            ForEach(searchResults, id: \.code) { stop in
                NavigationLink(value: ViewPath.busStop(stop)) {
                    ListBusStopRow(busStop: .constant(stop))
                }
            }
        } header: {
            Text("Directory.SearchResults")
        }
    }

    @ViewBuilder var locationsSection: some View {
        Section {
            if favorites.favoriteLocations.isEmpty {
                ContentUnavailableView {
                    Label("Favorites.Hint.NoLocations.Title",
                          systemImage: "info.circle.fill")
                } description: {
                    Text("Favorites.Hint.NoLocations")
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            } else {
                ForEach($favorites.favoriteLocations, id: \.hashValue) { $location in
                    if !location.isFault && !location.isDeleted {
                        locationRow(location: $location)
                    }
                }
            }
        } header: {
            HStack(alignment: .center, spacing: 16.0) {
                Text("TabTitle.Favorites")
                Spacer()
                if !favorites.favoriteLocations.isEmpty {
                    Toggle(isOn: $isEditing) {
                        Image(systemName: "pencil")
                            .font(.body)
                    }
                    .toggleStyle(.button)
                    .labelsHidden()
                }
                Button {
                    isNewPending = true
                } label: {
                    Image(systemName: "plus")
                        .font(.body)
                }
            }
        }
    }

    @ViewBuilder func locationRow(location: Binding<FavoriteLocation>) -> some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack(alignment: .center, spacing: 6.0) {
                Text(location.wrappedValue.nickname ?? location.wrappedValue.busStopCode ?? "")
                    .font(Font.custom("LTA-Identity", size: 16.0))
                if isEditing {
                    Button {
                        favoriteLocationPendingEdit = location.wrappedValue
                        favoriteLocationPendingEditNewNickname = location.wrappedValue.nickname ?? location.wrappedValue.busStopCode!
                        isNicknameEditPending = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.body)
                    }
                    Spacer()
                    locationEditingControls(location: location)
                }
            }
            BusServicesCarousel(
                dataDisplayMode: location.wrappedValue.usesLiveBusStopData
                    ? .favoriteLocationLiveData
                    : .favoriteLocationCustomData,
                locationName: location.wrappedValue.nickname ?? "",
                busStopCode: location.wrappedValue.usesLiveBusStopData
                    ? location.wrappedValue.busStopCode
                    : nil,
                favoriteLocation: location
            )
            .opacity(isEditing ? 0.5 : 1.0)
            .disabled(isEditing)
        }
        .listRowInsets(EdgeInsets(top: 16.0, leading: 16.0, bottom: 16.0, trailing: 0.0))
    }

    @ViewBuilder func locationEditingControls(location: Binding<FavoriteLocation>) -> some View {
        HStack(alignment: .center, spacing: 16.0) {
            if !location.wrappedValue.usesLiveBusStopData && (location.wrappedValue.busServices ?? []).count != 0 {
                Button {
                    favoriteLocationPendingEdit = location.wrappedValue
                    isEditPending = true
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 14.0))
                }
            }
            Button {
                Task {
                    await favorites.moveUp(location.wrappedValue)
                }
            } label: {
                Image(systemName: "chevron.up")
                    .font(.system(size: 14.0))
            }
            .disabled(location.wrappedValue.viewIndex == 0)
            Button {
                Task {
                    await favorites.moveDown(location.wrappedValue)
                }
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 14.0))
            }
            .disabled(location.wrappedValue.viewIndex == favorites.favoriteLocations.count - 1)
            Button {
                favoriteLocationPendingEdit = location.wrappedValue
                isDeletionPending = true
            } label: {
                Image(systemName: "minus.circle")
                    .font(.system(size: 14.0))
                    .foregroundColor(.red)
            }
        }
    }

    @ViewBuilder var nearbySection: some View {
        Section {
            if dataManager.busStops.count == 0 {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            } else if !locationManager.isInUsableState() {
                ContentUnavailableView {
                    Label("Nearby.Hint.NoLocation.Title",
                          systemImage: "exclamationmark.triangle.fill")
                } description: {
                    Text("Nearby.Hint.NoLocation")
                } actions: {
#if !os(visionOS)
                    LocationButton {
                        locationManager.updateLocation(usingOnlySignificantChanges: false)
                    }
                    .symbolVariant(.fill)
                    .labelStyle(.titleAndIcon)
                    .foregroundColor(.white)
                    .cornerRadius(100.0)
#endif
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            } else if isNearbyBusStopsDetermined && nearbyBusStops.isEmpty {
                ContentUnavailableView {
                    Label("Nearby.Hint.NoBusStops.Title",
                          systemImage: "exclamationmark.triangle.fill")
                } description: {
                    Text("Nearby.Hint.NoBusStops")
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            } else {
                ForEach($nearbyBusStops, id: \.hashValue) { $stop in
                    nearbyStopRow(stop: $stop)
                }
            }
        } header: {
            Text("TabTitle.Nearby")
        }
    }

    @ViewBuilder func nearbyStopRow(stop: Binding<BusStop>) -> some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack(alignment: .center, spacing: 0.0) {
                Text(stop.wrappedValue.name())
                    .font(Font.custom("LTA-Identity", size: 16.0))
                Spacer()
                if !favorites.favoriteLocations.contains(where: { location in
                    location.busStopCode == stop.wrappedValue.code && location.usesLiveBusStopData
                }) {
                    Button {
                        Task {
                            await favorites.addFavoriteLocation(
                                busStop: stop.wrappedValue,
                                usesLiveBusStopData: true
                            )
                            toaster.showToast(
                                localized("Shared.BusStop.Toast.Favorited",
                                          replacing: stop.wrappedValue.name()),
                                type: .checkmark,
                                hidesAutomatically: true
                            )
                        }
                    } label: {
                        Image(systemName: "rectangle.stack.badge.plus")
                            .font(.system(size: 14.0))
                    }
                }
            }
            BusServicesCarousel(
                dataDisplayMode: .busStop,
                locationName: stop.wrappedValue.name(),
                busStopCode: stop.wrappedValue.code,
                favoriteLocation: nil
            )
        }
        .listRowInsets(EdgeInsets(top: 16.0, leading: 16.0, bottom: 16.0, trailing: 0.0))
    }

    // MARK: - Data Loading

    func reloadBusStopList(forceServer: Bool = false) async {
        toaster.showToast(localized("Directory.BusStopsLoading"),
                          type: .spinner,
                          hidesAutomatically: false)
        do {
            if dataManager.storedBusStopList() == nil || forceServer {
                try await dataManager.reloadBusStopListFromServer()
                log("Reloaded bus stop data from server.")
            } else {
                if let storedBusStopList = dataManager.storedBusStopList(),
                   let storedBusStopListUpdatedDate = dataManager.storedBusStopListUpdatedDate() {
                    try await dataManager.reloadBusStopListFromStoredMemory(
                        storedBusStopList,
                        updatedAt: storedBusStopListUpdatedDate
                    )
                    log("Reloaded bus stop data from memory.")
                }
            }
            toaster.hideToast()
        } catch {
            log(error.localizedDescription)
            log("WARNING×WARNING×WARNING\nNetwork does not look like it's working, bus stop data may be incomplete!")
            toaster.showToast(localized("Shared.Error.InternetConnection"),
                              type: .persistentError,
                              hidesAutomatically: false)
        }
    }

    func reloadNearbyBusStops() {
        Task {
            let currentCoordinate = CLLocation(
                latitude: locationManager.region.center.latitude,
                longitude: locationManager.region.center.longitude
            )
            var busStopListSortedByDistance: [BusStop] = dataManager.busStops
            busStopListSortedByDistance = busStopListSortedByDistance.filter { busStop in
                currentCoordinate.distanceTo(busStop: busStop) < 500.0
            }
            busStopListSortedByDistance.sort { lhs, rhs in
                currentCoordinate.distanceTo(busStop: lhs) < currentCoordinate.distanceTo(busStop: rhs)
            }
            nearbyBusStops.removeAll()
            nearbyBusStops.append(contentsOf: busStopListSortedByDistance)
            log("Reloaded nearby bus stop data.")
            regionManager.updateRegion(newRegion: locationManager.region)
            log("Updated Map region.")
            coordinateManager.removeAll()
            coordinateManager.replaceWithCoordinates(from: nearbyBusStops)
            coordinateManager.updateCameraFlag.toggle()
            log("Updated displayed coordinates.")
            isNearbyBusStopsDetermined = true
        }
    }

}
