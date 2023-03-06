//
//  NotificationsView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/24.
//

import SwiftUI

struct NotificationsView: View {
    
    @State var notificationRequests: [UNNotificationRequest] = []
    
    var showToast: (String, ToastType) async -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if notificationRequests.count == 0 {
                        VStack(alignment: .center, spacing: 4.0) {
                            Image(systemName: "questionmark.circle.fill")
                                .symbolRenderingMode(.multicolor)
                                .font(.system(size: 32.0, weight: .regular))
                                .foregroundColor(.secondary)
                            Text("Notifications.ArrivalAlerts.Hint")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(16.0)
                    } else {
                        ForEach(notificationRequests, id: \.identifier) { request in
                            if let busService = request.content.userInfo["busService"] as? String,
                               let stopCode = request.content.userInfo["stopCode"] as? String,
                               let stopDescription = request.content.userInfo["stopDescription"] as? String {
                                NavigationLink {
                                    ArrivalInfoDetailView(busStop: BusStop(code: stopCode, description: stopDescription), busService: BusService(serviceNo: busService, operator: .Unknown), showToast: self.showToast)
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
                    }
                } header: {
                    Text("Notifications.ArrivalAlerts")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .textCase(nil)
                }
            }
            .listStyle(.insetGrouped)
            .onAppear {
                reloadNotificationRequests()
            }
            .refreshable {
                reloadNotificationRequests()
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
    
    static func showToast(message: String, type: ToastType = .None) async { }
    
}
