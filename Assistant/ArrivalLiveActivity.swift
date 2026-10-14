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
                .padding(16.0)
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
        HStack(alignment: .center, spacing: 16.0) {
            VStack(alignment: .leading, spacing: 6.0) {
                HStack(alignment: .center, spacing: 8.0) {
                    ServicePlate(serviceNo: context.attributes.serviceNo, fontSize: 18.0)
                        .frame(height: 30.0)
                    Text(context.attributes.busStopName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                ArrivalCountdown(nextArrival: context.state.nextArrival)
                    .font(.system(size: 36.0, weight: .semibold))
                FollowingArrivalView(state: context.state, isStale: context.isStale)
            }
            Spacer(minLength: 0.0)
            VStack(alignment: .trailing, spacing: 12.0) {
                BusAttributesView(state: context.state)
                ActivityButtons(activityID: context.activityID)
            }
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
                Text("Shared.BusArrival.Subsequent") + Text(followingArrival, style: .time)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

}

private struct BusAttributesView: View {

    var state: ArrivalAttributes.ContentState

    var body: some View {
        HStack(alignment: .center, spacing: 6.0) {
            LoadBadge(load: state.load)
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
        .foregroundStyle(.secondary)
    }

}

struct LoadBadge: View {

    var load: BusLoad?

    var body: some View {
        switch load {
        case .seatsAvailable:
            badge("LiveActivity.Load.Seats", color: .green)
        case .standingAvailable:
            badge("LiveActivity.Load.Standing", color: .orange)
        case .limitedStanding:
            badge("Shared.BusArrival.Crowded", color: .red)
        default:
            EmptyView()
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
        HStack(spacing: 8.0) {
            Button(intent: RefreshArrivalActivityIntent(activityID: activityID)) {
                Image(systemName: "arrow.clockwise")
            }
            Button(intent: EndArrivalActivityIntent(activityID: activityID)) {
                Image(systemName: "xmark")
            }
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .tint(Color("AccentColor"))
        .font(.caption.weight(.semibold))
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
