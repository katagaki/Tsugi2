//
//  ArrivalIntents.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import AppIntents
import SwiftUI

/// Tells the user when the next buses arrive at a bus stop, optionally for a single service.
struct GetBusArrivalsIntent: AppIntent {

    static let title: LocalizedStringResource = "Intents.GetArrivals.Title"
    static let description = IntentDescription("Intents.GetArrivals.Description")

    @Parameter(title: "Intents.BusStop")
    var busStop: BusStopEntity

    @Parameter(title: "Intents.Service")
    var serviceNo: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Get bus arrivals at \(\.$busStop)") {
            \.$serviceNo
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog & ShowsSnippetView {
        var services: [ServiceArrival]
        do {
            services = try await ArrivalsLoader.arrivals(atBusStop: busStop.id)
        } catch {
            throw IntentError.arrivalsUnavailable
        }
        if let serviceNo = serviceNo?.trimmingCharacters(in: .whitespaces), !serviceNo.isEmpty {
            services = services.filter { $0.serviceNo.caseInsensitiveCompare(serviceNo) == .orderedSame }
        }
        let summary = ArrivalSummary.spoken(services, at: busStop.name, serviceNo: serviceNo)
        return .result(value: summary, dialog: IntentDialog("\(summary)")) {
            ArrivalsSnippetView(title: busStop.name, services: services)
        }
    }

}

/// Tells the user when the next buses arrive at one of their favorite locations.
struct GetLocationArrivalsIntent: AppIntent {

    static let title: LocalizedStringResource = "Intents.GetLocationArrivals.Title"
    static let description = IntentDescription("Intents.GetLocationArrivals.Description")

    @Parameter(title: "Widget.Location")
    var location: LocationEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Get bus arrivals at \(\.$location)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog & ShowsSnippetView {
        guard let favoriteLocation = await ArrivalsLoader.location(for: location),
              favoriteLocation.id == location.id else {
            throw IntentError.arrivalsUnavailable
        }
        let services: [ServiceArrival]
        do {
            services = try await ArrivalsLoader.arrivals(for: favoriteLocation)
        } catch {
            throw IntentError.arrivalsUnavailable
        }
        let summary = ArrivalSummary.spoken(services, at: favoriteLocation.name, serviceNo: nil)
        return .result(value: summary, dialog: IntentDialog("\(summary)")) {
            ArrivalsSnippetView(title: favoriteLocation.name, services: services)
        }
    }

}

/// Arrivals in a sentence that Siri can read out.
enum ArrivalSummary {

    /// Siri reads out only the soonest few services, and the snippet shows the rest.
    static let spokenServiceLimit = 5

    static func spoken(_ services: [ServiceArrival], at placeName: String, serviceNo: String?) -> String {
        let arriving = services
            .filter { !$0.arrivals.isEmpty }
            .sorted { ($0.arrivals.first?.date ?? .distantFuture) < ($1.arrivals.first?.date ?? .distantFuture) }
        guard !arriving.isEmpty else {
            if let serviceNo, !serviceNo.isEmpty {
                return localized("Intents.Dialog.ServiceNotArriving", replacing: serviceNo, placeName)
            }
            return localized("Intents.Dialog.NoArrivals", replacing: placeName)
        }
        let phrases = arriving.prefix(spokenServiceLimit).compactMap { service in
            service.arrivals.first.map { phrase(for: service.serviceNo, arrivingAt: $0.date) }
        }
        return localized("Intents.Dialog.Arrivals", replacing: placeName,
                         ListFormatter.localizedString(byJoining: phrases))
    }

    private static func phrase(for serviceNo: String, arrivingAt date: Date) -> String {
        let minutes = Int(date.timeIntervalSinceNow / 60)
        if minutes < 1 {
            return localized("Intents.Dialog.ServiceArrivingNow", replacing: serviceNo)
        }
        return localized("Intents.Dialog.ServiceArriving", replacing: serviceNo, String(minutes))
    }

}

/// Shows arrivals in Siri and Shortcuts, styled after the app's bus number plates.
struct ArrivalsSnippetView: View {

    let title: String
    let services: [ServiceArrival]

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text(title)
                .font(.headline)
            if services.isEmpty {
                Text("Shared.BusStop.BusServices.None")
                    .foregroundStyle(.secondary)
            }
            ForEach(services) { service in
                HStack(spacing: 12.0) {
                    Text(service.serviceNo)
                        .font(.custom("LTA-Identity", size: 18.0))
                        .foregroundStyle(.white)
                        .frame(minWidth: 52.0)
                        .padding(.vertical, 4.0)
                        .background(Color("PlateColor"), in: .rect(cornerRadius: 6.0))
                    if let arrival = service.arrivals.first {
                        Text(arrival.date.arrivalFormat())
                            .font(.body.weight(.medium))
                        Spacer()
                        BusCrowdingLabel(load: arrival.load)
                    } else {
                        Text("Shared.BusArrival.NotInService")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }

}
