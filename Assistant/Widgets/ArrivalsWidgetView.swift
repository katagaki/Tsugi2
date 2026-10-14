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
        case .systemSmall: return 3
        case .systemLarge: return 9
        default: return 4
        }
    }

}

extension ServiceArrival {

    /// Arrivals that have already passed by the entry's date are replaced by the following bus.
    func upcoming(at date: Date) -> (next: Date?, following: Date?) {
        if let nextArrival, nextArrival < date.addingTimeInterval(-60) {
            return (followingArrival, nil)
        }
        return (nextArrival, followingArrival)
    }

    func label(at date: Date, style: DateComponentsFormatter.UnitsStyle = .short) -> String {
        upcoming(at: date).next?.arrivalFormat(style: style, relativeTo: date) ??
            localized("Shared.BusArrival.NotInService")
    }

}

// MARK: - Home Screen

private struct SystemArrivalsView: View {

    @Environment(\.widgetFamily) var family

    var entry: ArrivalsEntry
    var maximumRows: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack(alignment: .center) {
                Text(entry.locationName)
                    .font(Font.custom("LTA-Identity", size: family == .systemSmall ? 15.0 : 17.0))
                    .lineLimit(1)
                Spacer(minLength: 4.0)
                Button(intent: RefreshArrivalsIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color("AccentColor"))
            }
            switch entry.status {
            case .loaded where entry.services.isEmpty:
                StatusMessage(text: "Shared.BusStop.BusServices.None")
            case .loaded:
                VStack(spacing: family == .systemSmall ? 6.0 : 8.0) {
                    ForEach(entry.services.prefix(maximumRows)) { service in
                        ArrivalRow(service: service, date: entry.date, showsFollowing: family != .systemSmall)
                    }
                }
                Spacer(minLength: 0.0)
            case .noLocations:
                StatusMessage(text: "Widget.NoLocations")
            case .failed:
                StatusMessage(text: "Shared.Error.InternetConnection")
            }
        }
    }

}

private struct ArrivalRow: View {

    var service: ServiceArrival
    var date: Date
    var showsFollowing: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            ServicePlate(serviceNo: service.serviceNo, fontSize: 15.0)
                .frame(width: 56.0, height: 24.0)
            if showsFollowing {
                LoadIndicator(load: service.load)
            }
            Spacer(minLength: 0.0)
            Text(service.label(at: date))
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
            if showsFollowing {
                Text(service.upcoming(at: date).following?.arrivalFormat(relativeTo: date) ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(width: 52.0, alignment: .trailing)
            }
        }
    }

}

private struct LoadIndicator: View {

    var load: BusLoad?

    var body: some View {
        switch load {
        case .seatsAvailable:
            Circle().fill(.green).frame(width: 6.0, height: 6.0)
        case .standingAvailable:
            Circle().fill(.orange).frame(width: 6.0, height: 6.0)
        case .limitedStanding:
            Circle().fill(.red).frame(width: 6.0, height: 6.0)
        default:
            EmptyView()
        }
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
