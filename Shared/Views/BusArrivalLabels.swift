//
//  BusArrivalLabels.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import SwiftUI

/// Marks buses that are crowded. Nothing is shown when seats are available.
struct BusCrowdingLabel: View {

    var load: BusLoad?

    var body: some View {
        switch load {
        case .standingAvailable:
            label(color: .orange)
        case .limitedStanding:
            label(color: .red)
        default:
            EmptyView()
        }
    }

    func label(color: Color) -> some View {
        Text("Shared.BusArrival.Crowded")
            .font(.system(size: 10.5, weight: .bold))
            .foregroundColor(.white)
            .padding(EdgeInsets(top: 3.0, leading: 6.0, bottom: 3.0, trailing: 6.0))
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 6.0))
    }

}

/// Shows whether a bus is wheelchair accessible, and whether it is a single or double decker.
struct BusAttributeIcons: View {

    var feature: BusFeature?
    var type: BusType?
    var font: Font = .caption

    var body: some View {
        HStack(alignment: .center, spacing: 4.0) {
            if feature == .wheelchairAccessible {
                Image(systemName: "figure.roll")
            }
            switch type {
            case .doubleDeck:
                Image(systemName: "bus.doubledecker")
            case nil:
                EmptyView()
            default:
                Image(systemName: "bus")
            }
        }
        .font(font)
        .foregroundColor(.secondary)
    }

}
