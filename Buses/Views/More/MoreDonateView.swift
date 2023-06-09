//
//  MoreDonateView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/13.
//

import SwiftUI

struct MoreDonateView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 4.0) {
            Image(systemName: "questionmark.app.dashed")
                .font(.system(size: 32.0, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(16.0)
        .navigationTitle("ViewTitle.More.Donate")
    }
}
