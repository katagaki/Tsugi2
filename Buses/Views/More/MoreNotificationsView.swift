//
//  MoreNotificationsView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/12.
//

import SwiftUI

struct MoreNotificationsView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 4.0) {
            Image(systemName: "questionmark.app.dashed")
                .font(.system(size: 32.0, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(16.0)
        .navigationTitle("ViewTitle.More.Notifications")
    }
}

struct MoreNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        MoreNotificationsView()
    }
}
