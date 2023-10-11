//
//  AssistantLiveActivity.swift
//  Assistant
//
//  Created by 堅書 on 27/2/23.
//

#if canImport(ActivityKit) && canImport(WidgetKit)

import ActivityKit
import WidgetKit
import SwiftUI

struct AssistantAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var busService: BusService
    }

    var serviceNo: String
    var currentDate: Date
}

struct ArrivalLiveActivity: Widget {

    @Environment(\.colorScheme) var colorScheme

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AssistantAttributes.self) { context in
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 16.0) {
                    BusNumberPlateView(carouselDisplayMode: .constant(.full),
                                       serviceNo: context.state.busService.serviceNo)
                        .background(Color("PlateColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        .frame(minWidth: 88.0, maxWidth: 88.0, minHeight: 40.0, maxHeight: 40.0, alignment: .center)
                    VStack(alignment: .leading) {
                        if let date = context.state.busService.nextBus?.estimatedArrivalTimeAsDate() {
                            Text("LiveActivity.EstimatedArrival")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(date, style: .time)
                                .font(.body)
                        }
                    }
                }
                Spacer()
                switch context.state.busService.nextBus?.feature {
                case .wheelchairAccessible:
                    Image(systemName: "figure.roll")
                        .font(.body)
                default:
                    Text("")
                }
                switch context.state.busService.nextBus?.type {
                case .doubleDeck:
                    Image(systemName: "bus.doubledecker")
                        .font(.body)
                case .none:
                    Text("")
                default:
                    Image(systemName: "bus")
                        .font(.body)
                }
            }
            .padding(16.0)
            .activityBackgroundTint(.black.opacity(0.3))
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    BusNumberPlateView(carouselDisplayMode: .constant(.full),
                                       serviceNo: context.state.busService.serviceNo)
                        .background(Color("PlateColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 16.0))
                        .frame(minWidth: 88.0, maxWidth: 88.0, minHeight: 40.0, maxHeight: 40.0, alignment: .leading)
                        .padding(8.0)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 8.0) {
                        HStack(alignment: .center, spacing: 4.0) {
                            if context.state.busService.nextBus?.feature == .wheelchairAccessible {
                                Image(systemName: "figure.roll")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                            if context.state.busService.nextBus?.type == .doubleDeck {
                                Image(systemName: "bus.doubledecker")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            } else {
                                Image(systemName: "bus")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .frame(minWidth: .zero, maxWidth: .infinity, minHeight: 40.0, maxHeight: 40.0, alignment: .trailing)
                    .padding(8.0)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("LiveActivity.EstimatedArrival")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(context.state.busService.nextBus?.estimatedArrivalTimeAsDate() ?? Date(), style: .time)
                        .font(.largeTitle)
                    // TODO: Implement ProgressView
//                    ProgressView(timerInterval:
//                                    Date()...(context.state.busService.nextBus?.estimatedArrivalTimeAsDate() ??
//                                              Date()))
//                        .tint(Color("AccentColor"))
//                        .font(.body)
//                        .foregroundColor(.white)
//                    .frame(height: 20.0)
                    .padding([.leading, .trailing], 16.0)
                }
            } compactLeading: {
                Text(context.attributes.serviceNo)
                    .font(Font.custom("LTA-Identity", size: 16.0))
                    .padding(EdgeInsets(top: 2.0, leading: 16.0, bottom: 3.0, trailing: 16.0))
                    .background(Color("PlateColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 16.0))
            } compactTrailing: {
                if let date = context.state.busService.nextBus?.estimatedArrivalTimeAsDate() {
                    ProgressView(timerInterval: Date()...date, countsDown: true, label: {
                        // No label implemented
                    }, currentValueLabel: {
                        if context.state.busService.nextBus?.type == .doubleDeck {
                            Image(systemName: "bus.doubledecker")
                                .font(.system(size: 10.0))
                                .foregroundColor(Color("AccentColor"))
                        } else {
                            Image(systemName: "bus")
                                .font(.system(size: 10.0))
                                .foregroundColor(Color("AccentColor"))
                        }
                    })
                        .tint(Color("AccentColor"))
                        .progressViewStyle(.circular)
                        .labelsHidden()
                } else {
                    Text("?")
                }
            } minimal: {
                if let date = context.state.busService.nextBus?.estimatedArrivalTimeAsDate() {
                    ProgressView(timerInterval: Date()...date, countsDown: true, label: {
                        // No label implemented
                    }, currentValueLabel: {
                        Text(context.state.busService.serviceNo)
                            .foregroundColor(Color("AccentColor"))
                    })
                        .tint(Color("AccentColor"))
                        .progressViewStyle(.circular)
                        .labelsHidden()
                } else {
                    Text("?")
                }
            }
            .keylineTint(Color("PlateColor"))
        }
    }
}

#endif
