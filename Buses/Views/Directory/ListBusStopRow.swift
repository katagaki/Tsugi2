//
//  ListBusStopRow.swift
//  Buses
//
//  Created by 堅書 on 13/4/23.
//

import SwiftUI

struct ListBusStopRow: View {

    @Binding var busStop: BusStop

    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            Image(.listIconBusStop)
            VStack(alignment: .leading, spacing: 2.0) {
                Text(busStop.name())
                    .font(.body)
                Text(busStop.roadName ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

}
