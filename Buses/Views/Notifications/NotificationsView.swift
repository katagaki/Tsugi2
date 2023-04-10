//
//  NotificationsView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/24.
//

import SwiftUI

struct NotificationsView: View {
    
    @State var notificationRequests: [UNNotificationRequest] = []
    
    var showToast: (String, ToastType, Bool) async -> Void
    
    var body: some View {
        NavigationStack {
            List {
                if notificationRequests.count > 0 {
                    Section {
                        ForEach(notificationRequests, id: \.identifier) { request in
                            if let busService = request.content.userInfo["busService"] as? String,
                               let stopCode = request.content.userInfo["stopCode"] as? String,
                               let stopDescription = request.content.userInfo["stopDescription"] as? String {
                                NavigationLink {
                                    ArrivalInfoDetailView(mode: .NotificationItem,
                                                          busService: BusService(serviceNo: busService, operator: .Unknown),
                                                          busStop: BusStop(code: stopCode, description: stopDescription),
                                                          showsAddToLocationButton: false,
                                                          showToast: self.showToast)
                                } label: {
                                    HStack(alignment: .center, spacing: 16.0) {
                                        Image("ListIcon.Bus")
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
                    } header: {
                        ListSectionHeader(text: "Notifications.ArrivalAlerts")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .onAppear {
                reloadNotificationRequests()
            }
            .refreshable {
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
        NotificationsView(showToast: self.showToast)
    }
    
    static func showToast(message: String, type: ToastType = .None, hideAutomatically: Bool = true) async { }

}
