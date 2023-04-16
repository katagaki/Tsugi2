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
            Image("ListIcon.BusStop")
            VStack(alignment: .leading, spacing: 2.0) {
                Text(verbatim: busStop.name())
                    .font(.body)
                Text(verbatim: busStop.roadName ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

}
