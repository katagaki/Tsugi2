//
//  FavoriteLocationEditView.swift
//  Buses
//
//  Created by 堅書 on 10/4/23.
//

import SwiftUI

struct FavoriteLocationEditView: View {

    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var favorites: FavoritesManager

    @Binding var locationToEdit: FavoriteLocation?

    @State var editableBusServices: [FavoriteBusService] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(editableBusServices, id: \.objectID) { busService in
                    Text(busService.serviceNo ?? "")
                        .font(Font.custom("LTA-Identity", size: 18.0))
                }
                .onMove(perform: moveBusServices)
                .onDelete(perform: deleteBusServices)
            }
            .listStyle(.insetGrouped)
            .environment(\.editMode, .constant(.active))
            .navigationTitle(localized("Favorites.Edit.Title",
                                       replacing: locationToEdit?.nickname ??
                                       localized("Shared.BusStop.Description.None")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadBusServices()
            }
        }
    }

    func loadBusServices() {
        if let locationToEdit = locationToEdit,
           let services = locationToEdit.busServices?.array as? [FavoriteBusService] {
            editableBusServices = services.sorted { $0.viewIndex < $1.viewIndex }
        }
    }

    func moveBusServices(from source: IndexSet, to destination: Int) {
        editableBusServices.move(fromOffsets: source, toOffset: destination)
        if let locationToEdit = locationToEdit {
            Task {
                await favorites.reorderBusServices(
                    locationToEdit,
                    orderedServices: editableBusServices
                )
            }
        }
    }

    func deleteBusServices(at offsets: IndexSet) {
        let servicesToDelete = offsets.map { editableBusServices[$0] }
        editableBusServices.remove(atOffsets: offsets)
        if let locationToEdit = locationToEdit {
            for service in servicesToDelete {
                Task {
                    await favorites.deleteBusService(locationToEdit, busService: service)
                }
            }
        }
    }

}
