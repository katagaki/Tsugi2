//
//  ArrivalLiveActivity.swift
//  Assistant
//
//  Created by 堅書 on 2023/02/27.
//

import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

struct ArrivalLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ArrivalAttributes.self) { context in
            LockScreenArrivalView(context: context)
                .activityBackgroundTint(.black.opacity(0.3))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ServicePlate(serviceNo: context.attributes.serviceNo, fontSize: 22.0)
                        .frame(height: 40.0)
                        .padding(.leading, 4.0)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    BusAttributesView(state: context.state)
                        .foregroundStyle(.secondary)
                        .frame(maxHeight: 40.0)
                        .padding(.trailing, 4.0)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.busStopName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 2.0) {
                            ArrivalCountdown(nextArrival: context.state.nextArrival)
                                .font(.system(size: 34.0, weight: .semibold))
                            FollowingArrivalView(state: context.state, isStale: context.isStale)
                        }
                        Spacer()
                        ActivityButtons(activityID: context.activityID)
                    }
                    .padding(.horizontal, 4.0)
                }
            } compactLeading: {
                ServicePlate(serviceNo: context.attributes.serviceNo, fontSize: 14.0)
            } compactTrailing: {
                ArrivalCountdown(nextArrival: context.state.nextArrival, isCompact: true)
                    .font(.system(size: 14.0, weight: .semibold))
                    .foregroundStyle(Color("AccentColor"))
                    .frame(maxWidth: 52.0)
            } minimal: {
                if let nextArrival = context.state.nextArrival, nextArrival > .now {
                    ProgressView(timerInterval: Date.now...nextArrival, countsDown: true) {
                        EmptyView()
                    } currentValueLabel: {
                        Text(context.attributes.serviceNo)
                            .font(.system(size: 9.0, weight: .bold))
                    }
                    .progressViewStyle(.circular)
                    .tint(Color("AccentColor"))
                } else {
                    Text(context.attributes.serviceNo)
                        .font(.system(size: 10.0, weight: .bold))
                }
            }
            .keylineTint(Color("PlateColor"))
        }
    }

}

private struct LockScreenArrivalView: View {

    var context: ActivityViewContext<ArrivalAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            HStack(alignment: .center, spacing: 8.0) {
                OutlinedServicePlate(serviceNo: context.attributes.serviceNo)
                Text(context.attributes.busStopName)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Spacer(minLength: 0.0)
                if let loadText = LoadBadge.text(for: context.state.load) {
                    Text(loadText)
                        .font(.caption.weight(.bold))
                }
                BusAttributesView(state: context.state, showsLoad: false)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16.0)
            .padding(.vertical, 10.0)
            // The bar takes the color of how crowded the bus is
            .background((LoadBadge.color(for: context.state.load) ?? Color("AccentColor")).opacity(0.45))
            HStack(alignment: .center, spacing: 16.0) {
                VStack(alignment: .leading, spacing: 4.0) {
                    ArrivalCountdown(nextArrival: context.state.nextArrival)
                        .font(.system(size: 36.0, weight: .semibold))
                    FollowingArrivalView(state: context.state, isStale: context.isStale)
                }
                Spacer(minLength: 0.0)
                ActivityButtons(activityID: context.activityID)
            }
            .padding(16.0)
        }
    }

}

/// Counts down to the next arrival without needing any updates.
private struct ArrivalCountdown: View {

    var nextArrival: Date?
    var isCompact: Bool = false

    var body: some View {
        if let nextArrival, nextArrival > .now {
            Text(timerInterval: Date.now...nextArrival, countsDown: true)
                .monospacedDigit()
                .multilineTextAlignment(isCompact ? .trailing : .leading)
        } else if nextArrival != nil {
            Text(isCompact ? "Shared.BusArrival.Arriving.Abbreviated" : "Shared.BusArrival.Arriving.Full")
        } else {
            Text("Shared.BusArrival.NotInService")
        }
    }

}

private struct FollowingArrivalView: View {

    var state: ArrivalAttributes.ContentState
    var isStale: Bool

    var body: some View {
        HStack(spacing: 6.0) {
            if isStale {
                Label("LiveActivity.Updating", systemImage: "arrow.trianglehead.2.clockwise")
            } else if let followingArrival = state.followingArrival {
                HStack(spacing: 0.0) {
                    Text("Shared.BusArrival.Subsequent")
                    Text(followingArrival, style: .time)
                }
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

}

private struct BusAttributesView: View {

    var state: ArrivalAttributes.ContentState
    var showsLoad: Bool = true

    var body: some View {
        HStack(alignment: .center, spacing: 6.0) {
            if showsLoad {
                LoadBadge(load: state.load)
            }
            if state.isWheelchairAccessible {
                Image(systemName: "figure.roll")
            }
            switch state.type {
            case .doubleDeck:
                Image(systemName: "bus.doubledecker")
            case .singleDeck, .bendy:
                Image(systemName: "bus")
            default:
                EmptyView()
            }
        }
        .font(.body)
    }

}

struct LoadBadge: View {

    var load: BusLoad?

    var body: some View {
        if let text = Self.text(for: load), let color = Self.color(for: load) {
            badge(text, color: color)
        }
    }

    static func text(for load: BusLoad?) -> LocalizedStringKey? {
        switch load {
        case .seatsAvailable: return "LiveActivity.Load.Seats"
        case .standingAvailable: return "LiveActivity.Load.Standing"
        case .limitedStanding: return "Shared.BusArrival.Crowded"
        default: return nil
        }
    }

    static func color(for load: BusLoad?) -> Color? {
        switch load {
        case .seatsAvailable: return .green
        case .standingAvailable: return .orange
        case .limitedStanding: return .red
        default: return nil
        }
    }

    func badge(_ text: LocalizedStringKey, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10.5, weight: .bold))
            .foregroundStyle(.white)
            .padding(EdgeInsets(top: 3.0, leading: 6.0, bottom: 3.0, trailing: 6.0))
            .background(color, in: RoundedRectangle(cornerRadius: 6.0))
    }

}

private struct ActivityButtons: View {

    var activityID: String

    var body: some View {
        HStack(spacing: 10.0) {
            Button(intent: RefreshArrivalActivityIntent(activityID: activityID)) {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 26.0, height: 26.0)
            }
            Button(intent: EndArrivalActivityIntent(activityID: activityID)) {
                Image(systemName: "xmark")
                    .frame(width: 26.0, height: 26.0)
            }
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .tint(Color("AccentColor"))
        .font(.body.weight(.bold))
    }

}

/// The service number in an outline, for use on colored backgrounds.
private struct OutlinedServicePlate: View {

    var serviceNo: String

    var body: some View {
        Text(serviceNo)
            .font(Font.custom("LTA-Identity", fixedSize: 18.0))
            .lineLimit(1)
            .padding(.horizontal, 8.0)
            .padding(.bottom, 1.0)
            .frame(minWidth: 45.0, minHeight: 28.0)
            .overlay {
                RoundedRectangle(cornerRadius: 6.0)
                    .strokeBorder(lineWidth: 1.5)
            }
    }

}

struct ServicePlate: View {

    var serviceNo: String
    var fontSize: CGFloat

    var body: some View {
        Text(serviceNo)
            .font(Font.custom("LTA-Identity", fixedSize: fontSize))
            .foregroundStyle(.white)
            .lineLimit(1)
            .padding(.horizontal, 8.0)
            .padding(.bottom, 1.0)
            .frame(minWidth: fontSize * 2.5)
            .background(Color("PlateColor"), in: RoundedRectangle(cornerRadius: fontSize / 3.0))
    }

}
