//
//  NotificationsView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/24.
//

import SwiftUI

struct NotificationsView: View {

    @Environment(\.dismiss) var dismiss

    @State var notificationRequests: [UNNotificationRequest] = []

    var body: some View {
        NavigationStack {
            List(notificationRequests, id: \.identifier) { request in
                if let busService = request.content.userInfo["busService"] as? String,
                   let stopCode = request.content.userInfo["stopCode"] as? String,
                   let stopDescription = request.content.userInfo["stopDescription"] as? String {
                    HStack(alignment: .center, spacing: 16.0) {
                        Image(.listIconBus)
                        VStack(alignment: .leading) {
                            Text(request.content.title)
                                .font(.body)
                                .fontWeight(.bold)
                            Text(request.content.body)
                                .font(.body)
                        }
                    }
                    .swipeActions {
                        Button("Swipe.Cancel") {
                            center.removePendingNotificationRequests(withIdentifiers: [request.identifier])
                            reloadNotificationRequests()
                        }
                        .tint(.red)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(0)
            .refreshable {
                reloadNotificationRequests()
            }
            .onAppear {
                reloadNotificationRequests()
            }
            .overlay {
                if notificationRequests.count == 0 {
                    ContentUnavailableView {
                        Label("Notifications.ArrivalAlerts",
                              systemImage: "info.circle.fill")
                    } description: {
                        Text("Notifications.ArrivalAlerts.Hint")
                    }
                }
            }
            .navigationTitle("ViewTitle.Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    func reloadNotificationRequests() {
        center.getPendingNotificationRequests { requests in
            notificationRequests = requests
        }
    }
}
