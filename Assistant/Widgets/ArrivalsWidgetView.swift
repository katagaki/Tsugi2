//
//  ArrivalsWidgetView.swift
//  Assistant
//
//  Created by 堅書 on 2026/10/14.
//

import AppIntents
import SwiftUI
import WidgetKit

struct ArrivalsWidgetView: View {

    @Environment(\.widgetFamily) var family

    var entry: ArrivalsEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            InlineArrivalsView(entry: entry)
        case .accessoryCircular:
            CircularArrivalView(entry: entry)
        case .accessoryRectangular:
            RectangularArrivalsView(entry: entry)
        default:
            SystemArrivalsView(entry: entry, maximumRows: maximumRows)
        }
    }

    var maximumRows: Int {
        switch family {
        case .systemLarge: return 7
        default: return 2
        }
    }

}

extension ServiceArrival {

    /// Buses that have already passed by the entry's date are replaced by the one after.
    func upcoming(at date: Date) -> Arrival? {
        arrivals.first { $0.date >= date.addingTimeInterval(-60) }
    }

    func label(at date: Date, style: DateComponentsFormatter.UnitsStyle = .short) -> String {
        upcoming(at: date)?.date.arrivalFormat(style: style, relativeTo: date) ??
            localized("Shared.BusArrival.NotInService")
    }

}

// MARK: - Home Screen

private struct SystemArrivalsView: View {

    @Environment(\.widgetFamily) var family

    var entry: ArrivalsEntry
    var maximumRows: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            TitleBar(title: entry.locationName, isCompact: family == .systemSmall,
                     locationID: entry.locationID, page: page, pageCount: pageCount)
            Group {
                switch entry.status {
                case .loaded where entry.services.isEmpty:
                    StatusMessage(text: "Shared.BusStop.BusServices.None")
                case .loaded:
                    ArrivalsGrid(services: Array(entry.services.dropFirst(page * pageSize).prefix(pageSize)),
                                 date: entry.date, isCompact: family == .systemSmall)
                case .noLocations:
                    StatusMessage(text: "Widget.NoLocations")
                case .failed:
                    StatusMessage(text: "Shared.Error.InternetConnection")
                }
            }
            .padding(.horizontal, 12.0)
            .padding(.vertical, 10.0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    var pageSize: Int {
        maximumRows * 2
    }

    var pageCount: Int {
        max(1, (entry.services.count + pageSize - 1) / pageSize)
    }

    var page: Int {
        min(entry.page, pageCount - 1)
    }

}

private struct TitleBar: View {

    var title: String
    var isCompact: Bool
    var locationID: UUID?
    var page: Int
    var pageCount: Int

    var body: some View {
        HStack(alignment: .center, spacing: 10.0) {
            Text(title)
                .font(Font.custom("LTA-Identity", size: isCompact ? 15.0 : 17.0))
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer(minLength: 0.0)
            if let locationID, pageCount > 1 {
                HStack(spacing: 8.0) {
                    pageButton("chevron.left", to: page - 1, isEnabled: page > 0, locationID: locationID)
                    pageButton("chevron.right", to: page + 1, isEnabled: page < pageCount - 1,
                               locationID: locationID)
                }
            }
            Button(intent: RefreshArrivalsIntent()) {
                TitleBarIcon(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(.white)
        .padding(.leading, 14.0)
        .padding(.trailing, 10.0)
        .padding(.vertical, 7.0)
        .background {
            // Lighter on top and deepening into the accent color, like the app icon
            LinearGradient(colors: [Color("AccentColor").mix(with: .orange, by: 0.45), Color("AccentColor")],
                           startPoint: .top, endPoint: .bottom)
        }
    }

    func pageButton(_ systemName: String, to page: Int, isEnabled: Bool, locationID: UUID) -> some View {
        Button(intent: ChangePageIntent(locationID: locationID, page: page)) {
            TitleBarIcon(systemName: systemName)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.4)
    }

}

private struct TitleBarIcon: View {

    var systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.footnote.weight(.bold))
            .frame(width: 30.0, height: 30.0)
            .background(.white.opacity(0.22), in: .circle)
    }

}

private struct ArrivalsGrid: View {

    var services: [ServiceArrival]
    var date: Date
    var isCompact: Bool

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 10.0, verticalSpacing: isCompact ? 8.0 : 10.0) {
            ForEach(Array(stride(from: 0, to: services.count, by: 2)), id: \.self) { index in
                GridRow {
                    cell(services[index])
                    if index + 1 < services.count {
                        cell(services[index + 1])
                    } else {
                        Color.clear
                            .gridCellUnsizedAxes([.horizontal, .vertical])
                    }
                }
            }
        }
    }

    @ViewBuilder func cell(_ service: ServiceArrival) -> some View {
        if isCompact {
            CompactArrivalCell(service: service, date: date)
        } else {
            ArrivalCell(service: service, date: date)
        }
    }

}

/// The number plate with the next bus beside it, and the bus's attributes underneath.
private struct ArrivalCell: View {

    var service: ServiceArrival
    var date: Date

    var body: some View {
        let arrival = service.upcoming(at: date)
        HStack(alignment: .center, spacing: 8.0) {
            ServiceNumberPlate(serviceNo: service.serviceNo)
            VStack(alignment: .leading, spacing: 2.0) {
                Text(service.label(at: date))
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                HStack(alignment: .center, spacing: 4.0) {
                    BusAttributeIcons(feature: arrival?.feature, type: arrival?.type, font: .caption2)
                    BusCrowdingLabel(load: arrival?.load)
                        .scaleEffect(0.85, anchor: .leading)
                }
            }
            Spacer(minLength: 0.0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

/// Fits small widgets: the number plate with the next bus underneath.
private struct CompactArrivalCell: View {

    var service: ServiceArrival
    var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 3.0) {
            ServiceNumberPlate(serviceNo: service.serviceNo)
            Text(service.label(at: date, style: .abbreviated))
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

private struct ServiceNumberPlate: View {

    var serviceNo: String

    var body: some View {
        BusNumberPlateView(carouselDisplayMode: .constant(.minimal), serviceNo: serviceNo)
            .frame(height: 24.0)
    }

}

private struct StatusMessage: View {

    var text: LocalizedStringKey

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
    }

}

// MARK: - Lock Screen

private struct RectangularArrivalsView: View {

    var entry: ArrivalsEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 1.0) {
            Text(entry.locationName)
                .font(.headline)
                .widgetAccentable()
                .lineLimit(1)
            switch entry.status {
            case .loaded where !entry.services.isEmpty:
                ForEach(entry.services.prefix(2)) { service in
                    HStack {
                        Text(service.serviceNo)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(service.label(at: entry.date))
                    }
                    .font(.caption)
                }
            case .noLocations:
                Text("Widget.NoLocations")
                    .font(.caption)
            case .failed:
                Text("Shared.Error.InternetConnection")
                    .font(.caption)
            default:
                Text("Shared.BusStop.BusServices.None")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

private struct CircularArrivalView: View {

    var entry: ArrivalsEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            if let service = entry.services.first {
                VStack(spacing: 0.0) {
                    Text(service.serviceNo)
                        .font(.system(size: 13.0, weight: .bold))
                        .widgetAccentable()
                        .minimumScaleFactor(0.6)
                    Text(service.label(at: entry.date, style: .abbreviated))
                        .font(.system(size: 11.0))
                        .minimumScaleFactor(0.6)
                }
                .padding(4.0)
            } else {
                Image(systemName: "bus")
            }
        }
    }

}

private struct InlineArrivalsView: View {

    var entry: ArrivalsEntry

    var body: some View {
        if let service = entry.services.first {
            Label("\(service.serviceNo) · \(service.label(at: entry.date))", systemImage: "bus")
        } else {
            Label("Widget.Title", systemImage: "bus")
        }
    }

}
