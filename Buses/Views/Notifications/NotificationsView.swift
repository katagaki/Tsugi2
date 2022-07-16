//
//  NotificationsView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/24.
//

import SwiftUI

struct NotificationsView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 4.0) {
            Image(systemName: "questionmark.app.dashed")
                .font(.system(size: 32.0, weight: .regular))
                .foregroundColor(.secondary)
            Text("Shared.General.ComingSoon")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(16.0)
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
