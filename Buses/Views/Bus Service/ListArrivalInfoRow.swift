//
//  ListArrivalInfoRow.swift
//  Buses
//
//  Created by 堅書 on 2022/06/15.
//

import SwiftUI

struct ListArrivalInfoRow: View {

    var busService: BusService
    var arrivalInfo: BusArrivalInfo
    @State var arrivalTime: String = ""

    var setNotification: (BusArrivalInfo) -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            VStack(alignment: .leading, spacing: 2.0) {
                Text(arrivalInfo.estimatedArrivalTimeAsDate()?.arrivalFormat() ??
                     localized("Shared.BusArrival.NotInService"))
                    .font(.system(size: 20.0, weight: .medium))
                if arrivalTime != "" {
                    Text(arrivalTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Shared.BusArrival.NotInService.Subtitle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            switch arrivalInfo.load {
            case .standingAvailable:
                Text("Shared.BusArrival.Crowded")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 3.0, leading: 6.0, bottom: 3.0, trailing: 6.0))
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 6.0))
            case .limitedStanding:
                Text("Shared.BusArrival.Crowded")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 3.0, leading: 6.0, bottom: 3.0, trailing: 6.0))
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 6.0))
            default:
                Text("")
            }
            if arrivalTime != "" {
                HStack(alignment: .center, spacing: 4.0) {
                    if arrivalInfo.feature == .wheelchairAccessible {
                        Image(systemName: "figure.roll")
                            .font(.body)
                            .foregroundColor(.secondary)
                    } else {
                        Text("")
                    }
                    switch arrivalInfo.type {
                    case .doubleDeck:
                        Image(systemName: "bus.doubledecker")
                            .font(.body)
                            .foregroundColor(.secondary)
                    case .none:
                        Text("")
                    default:
                        Image(systemName: "bus")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                if let date = arrivalInfo.estimatedArrivalTimeAsDate() {
                    Divider()
                    Button {
                        setNotification(arrivalInfo)
                    } label: {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 14.0, weight: .regular))
                    }
                    .buttonStyle(.bordered)
                    .mask {
                        Circle()
                    }
                    .disabled(date < (Date() + (2 * 60)))
                }
            }
        }
        .onAppear {
            if let estimatedArrivalTime = arrivalInfo.estimatedArrivalTimeAsDate() {
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .short
                arrivalTime = dateFormatter.string(from: estimatedArrivalTime)
            } else {
                arrivalTime = ""
            }
        }
    }

}
