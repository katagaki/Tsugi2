//
//  NotificationsView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/24.
//

import SwiftUI

struct NotificationsView: View {

    @State var notificationRequests: [UNNotificationRequest] = []

    var body: some View {
        NavigationStack {
            List(notificationRequests, id: \.identifier) { request in
                if let busService = request.content.userInfo["busService"] as? String,
                   let stopCode = request.content.userInfo["stopCode"] as? String,
                   let stopDescription = request.content.userInfo["stopDescription"] as? String {
                    NavigationLink {
                        BusServiceView(mode: .notificationItem,
                                       busService: BusService(serviceNo: busService,
                                                              operator: .unknown),
                                       busStop: .constant(BusStop(code: stopCode,
                                                                  description: stopDescription)),
                                       showsAddToLocationButton: false)
                    } label: {
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
            .refreshable {
                reloadNotificationRequests()
            }
            .onAppear {
                reloadNotificationRequests()
            }
            .overlay {
                if notificationRequests.count == 0 {
                    ListHintOverlay(image: "info.circle.fill", text: "Notifications.ArrivalAlerts.Hint")
                }
            }
            .navigationTitle("ViewTitle.Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ViewTitle.Notifications")
                        .font(.system(size: 24.0, weight: .bold))
                }
                ToolbarItem(placement: .principal) {
                    Spacer()
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

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
