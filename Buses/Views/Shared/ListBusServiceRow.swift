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
            BusNumberPlateView(carouselDisplayMode: .constant(.Full),
                               serviceNo: bus.serviceNo)
            Divider()
            VStack(alignment: .leading, spacing: 2.0) {
                HStack(alignment: .center, spacing: 4.0) {
                    Text(bus.nextBus?.estimatedArrivalTime()?.arrivalFormat() ?? localized("Shared.BusArrival.NotInService"))
                        .font(.body)
                    switch bus.nextBus?.feature {
                    case .WheelchairAccessible:
                        Image(systemName: "figure.roll")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    default:
                        Text("")
                    }
                    switch bus.nextBus?.type {
                    case .DoubleDeck:
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
                if let arrivalTime = bus.nextBus2?.estimatedArrivalTime() {
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
