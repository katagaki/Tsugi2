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
        NavigationView {
            List {
                ForEach(notificationRequests, id: \.identifier) { request in
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("ListIcon.Bus")
                        VStack(alignment: .leading) {
                            Text(request.content.title)
                                .font(.body)
                            Text(request.content.subtitle)
                                .font(.caption)
                            Text(request.identifier)
                                .font(.system(size: 8.0))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            }
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
        NotificationsView()
    }
}
