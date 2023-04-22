//
//  ListBusServiceRow.swift
//  Buses
//
//  Created by 堅書 on 13/4/23.
//

import SwiftUI

struct ListBusServiceRow: View {

    @Binding var bus: BusService

    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            BusNumberPlateView(carouselDisplayMode: .constant(.full),
                               serviceNo: bus.serviceNo)
            Divider()
            VStack(alignment: .leading, spacing: 2.0) {
                HStack(alignment: .center, spacing: 4.0) {
                    Text(bus.nextBus?.estimatedArrivalTimeAsDate()?.arrivalFormat() ??
                         localized("Shared.BusArrival.NotInService"))
                        .font(.body)
                    if bus.nextBus?.feature == .wheelchairAccessible {
                        Image(systemName: "figure.roll")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("")
                    }
                    switch bus.nextBus?.type {
                    case .doubleDeck:
                        Image(systemName: "bus.doubledecker")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    case .none:
                        Text("")
                    default:
                        Image(systemName: "bus")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                if let arrivalTime = bus.nextBus2?.estimatedArrivalTimeAsDate() {
                    Text(localized("Shared.BusArrival.Subsequent") + arrivalTime.arrivalFormat())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            return 0
        }
    }

}
