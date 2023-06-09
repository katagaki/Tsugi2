//
//  BusServicesCarouselItem.swift
//  Buses
//
//  Created by 堅書 on 2023/06/03.
//

import SwiftUI

struct BusServicesCarouselItem: View {

    @EnvironmentObject var settings: SettingsManager

    @State var serviceNo: String
    @State var arrivalTime1: String
    @State var arrivalTime2: String

    var body: some View {
        VStack(alignment: .center, spacing: 2.0) {
            BusNumberPlateView(carouselDisplayMode: $settings.carouselDisplayMode,
                               serviceNo: serviceNo)
            .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: -8.0, trailing: 0.0))
            switch settings.carouselDisplayMode {
            case .full:
                Text(arrivalTime1)
                .font(.system(size: 16.0))
                .foregroundColor(.primary)
                .lineLimit(1)
                Text(arrivalTime2)
                    .font(.system(size: 16.0))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            case .small:
                Text(arrivalTime1)
                .font(.system(size: 14.0))
                .foregroundColor(.primary)
                .lineLimit(1)
                Text(arrivalTime2)
                .font(.system(size: 14.0))
                .foregroundColor(.secondary)
                .lineLimit(1)
            case .minimal:
                Text(arrivalTime1)
                .font(.system(size: 12.0))
                .foregroundColor(.primary)
                .lineLimit(1)
            }
        }
        .frame(minWidth: settings.carouselDisplayMode.width(),
               maxWidth: settings.carouselDisplayMode.width(),
               minHeight: 0,
               maxHeight: .infinity,
               alignment: .center)
        .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 8.0, trailing: 0.0))
    }
}
