//
//  NotificationsView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/24.
//

import SwiftUI

struct NotificationsView: View {

    @EnvironmentObject var navigationManager: NavigationManager

    @State var notificationRequests: [UNNotificationRequest] = []

    var body: some View {
        NavigationStack(path: $navigationManager.notificationsTabPath) {
            List(notificationRequests, id: \.identifier) { request in
                if let busService = request.content.userInfo["busService"] as? String,
                   let stopCode = request.content.userInfo["stopCode"] as? String,
                   let stopDescription = request.content.userInfo["stopDescription"] as? String {
                    NavigationLink(value: ViewPath.busServiceNamed(busService,
                                                                   atLocation: stopDescription,
                                                                   forBusStopCode: stopCode)) {
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
            .navigationDestination(for: ViewPath.self, destination: { viewPath in
                switch viewPath {
                case .busServiceNamed(let serviceNumber, let locationName, let busStopCode):
                    BusServiceView(busService: BusService(serviceNo: serviceNumber,
                                                          operator: .unknown),
                                   locationName: locationName,
                                   busStopCode: busStopCode,
                                   showsAddToLocationButton: false)
                default:
                    Color.clear
                }
            })
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
