//
//  MainTabView+Sections.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

#if canImport(CoreLocationUI)
import CoreLocationUI
#endif
import SwiftUI

extension UnifiedView {

    // MARK: - List Content

    @ViewBuilder var listContent: some View {
        List {
            if searchTerm.trimmingCharacters(in: .whitespaces).count > 1 {
                searchResultsSection
            } else {
                locationsSection
                nearbySection
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationDestination(for: ViewPath.self) { viewPath in
            navigationDestinationView(for: viewPath)
        }
        .refreshable {
            log("Reloading data per the request of the user.")
            favorites.updateViewFlag.toggle()
            reloadNearbyBusStops()
        }
        .searchable(text: $searchTerm)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    isNotificationsSheetPresented = true
                } label: {
                    Image(systemName: "bell.fill")
                }
            }
            ToolbarSpacer(.fixed, placement: .navigationBarTrailing)
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    isMoreSheetPresented = true
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(.fixed, placement: .bottomBar)
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    navigationManager.push(ViewPath.mrtMap)
                } label: {
                    Image(systemName: "tram.fill")
                }
            }
            ToolbarSpacer(.fixed, placement: .bottomBar)
            ToolbarItemGroup(placement: .bottomBar) {
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
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isMoreSheetPresented) {
            MoreView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isEditPending) {
            FavoriteLocationEditView(locationToEdit: $favoriteLocationPendingEdit)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder func navigationDestinationView(for viewPath: ViewPath) -> some View {
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
            LoadingWebView(url: URL(string: "https://www.lta.gov.sg/content/ltagov/en/map/train.html")!)
                .navigationTitle("ViewTitle.MRTMap")
        case .fareCalculator:
            LoadingWebView(url: URL(string: "https://www.lta.gov.sg/content/ltagov/en/map/fare-calculator.html")!)
                .navigationTitle("ViewTitle.FareCalculator")
        case .moreLicenses:
            MoreLicensesView()
        }
    }

    // MARK: - Search Results

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

    // MARK: - Locations

    @ViewBuilder var locationsSection: some View {
        Section {
            if favorites.favoriteLocations.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text(localized("Favorites.Hint.NoLocations.Title"))
                    } icon: {
                        Image(systemName: "info.circle.fill")
                    }
                } description: {
                    Text(localized("Favorites.Hint.NoLocations"))
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
                            .font(.title3)
                    }
                    .toggleStyle(.button)
                    .labelsHidden()
                }
                Button {
                    isNewPending = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                }
            }
        }
    }

    @ViewBuilder func locationRow(location: Binding<FavoriteLocation>) -> some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack(alignment: .center, spacing: 6.0) {
                Text(location.wrappedValue.nickname ?? location.wrappedValue.busStopCode ?? "")
                    .font(Font.custom("LTA-Identity", size: 20.0))
                if isEditing {
                    Button {
                        favoriteLocationPendingEdit = location.wrappedValue
                        favoriteLocationPendingEditNewNickname = location.wrappedValue.nickname ?? location.wrappedValue.busStopCode!
                        isNicknameEditPending = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.body)
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                    locationEditingControls(location: location)
                }
            }
            .padding(.horizontal)
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
        .listRowInsets(EdgeInsets(top: 16.0, leading: 0.0, bottom: 16.0, trailing: 0.0))
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
                .buttonStyle(.borderless)
            }
            Button {
                Task {
                    await favorites.moveUp(location.wrappedValue)
                }
            } label: {
                Image(systemName: "chevron.up")
                    .font(.system(size: 14.0))
            }
            .buttonStyle(.borderless)
            .disabled(location.wrappedValue.viewIndex == 0)
            Button {
                Task {
                    await favorites.moveDown(location.wrappedValue)
                }
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 14.0))
            }
            .buttonStyle(.borderless)
            .disabled(location.wrappedValue.viewIndex == favorites.favoriteLocations.count - 1)
            Button {
                favoriteLocationPendingEdit = location.wrappedValue
                isDeletionPending = true
            } label: {
                Image(systemName: "minus.circle")
                    .font(.system(size: 14.0))
                    .foregroundColor(.red)
            }
            .buttonStyle(.borderless)
        }
    }

    // MARK: - Nearby

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
                    Label {
                        Text(localized("Nearby.Hint.NoLocation.Title"))
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                } description: {
                    Text(localized("Nearby.Hint.NoLocation"))
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
                    Label {
                        Text(localized("Nearby.Hint.NoBusStops.Title"))
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                } description: {
                    Text(localized("Nearby.Hint.NoBusStops"))
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
                    .font(Font.custom("LTA-Identity", size: 20.0))
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
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal)
            BusServicesCarousel(
                dataDisplayMode: .busStop,
                locationName: stop.wrappedValue.name(),
                busStopCode: stop.wrappedValue.code,
                favoriteLocation: nil
            )
        }
        .listRowInsets(EdgeInsets(top: 16.0, leading: 0.0, bottom: 16.0, trailing: 0.0))
    }

}
