//
//  AssistantLiveActivity.swift
//  Assistant
//
//  Created by 堅書 on 27/2/23.
//

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

struct AssistantLiveActivity: Widget {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AssistantAttributes.self) { context in
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 16.0) {
                    BusNumberPlateView(serviceNo: context.state.busService.serviceNo)
                        .background(Color("PlateColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        .frame(minWidth: 88.0, maxWidth: 88.0, minHeight: 40.0, maxHeight: 40.0, alignment: .center)
                    VStack(alignment: .leading) {
                        if let date = context.state.busService.nextBus?.estimatedArrivalTime() {
                            Text("LiveActivity.EstimatedArrival")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(date, style: .time)
                                .font(.body)
//                            Text(localized("LiveActivity.ArrivingAt").replacingOccurrences(of: "%1", with: date.formatted(date: .omitted, time: .standard)))
//                                .font(.caption)
//                                .foregroundColor(.secondary)
                        }
                    }
                }
                Spacer()
                switch context.state.busService.nextBus?.feature {
                case .WheelchairAccessible:
                    Image(systemName: "figure.roll")
                        .font(.body)
                default:
                    Text("")
                }
                switch context.state.busService.nextBus?.type {
                case .DoubleDeck:
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
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    BusNumberPlateView(serviceNo: context.state.busService.serviceNo)
                        .background(Color("PlateColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 16.0))
                        .frame(minWidth: 88.0, maxWidth: 88.0, minHeight: 40.0, maxHeight: 40.0, alignment: .leading)
                        .padding(8.0)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 8.0) {
                        HStack(alignment: .center, spacing: 4.0) {
                            if context.state.busService.nextBus?.feature == .WheelchairAccessible {
                                Image(systemName: "figure.roll")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                            if context.state.busService.nextBus?.type == .DoubleDeck {
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
                    Text(context.state.busService.nextBus?.estimatedArrivalTime() ?? Date(), style: .time)
                        .font(.largeTitle)
//                    ProgressView(timerInterval: Date()...(context.state.busService.nextBus?.estimatedArrivalTime() ?? Date()))
//                        .tint(Color("AccentColor"))
//                        .font(.body)
//                        .foregroundColor(.white)
//                    .frame(height: 20.0)
                    .padding([.leading, .trailing], 16.0)
                }
            } compactLeading: {
                Text(context.attributes.serviceNo)
                    .font(Font.custom("OceanSansStd-Bold", size: 16.0))
                    .padding(EdgeInsets(top: 6.0, leading: 16.0, bottom: 2.0, trailing: 16.0))
                    .background(Color("PlateColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 16.0))
            } compactTrailing: {
                if let date = context.state.busService.nextBus?.estimatedArrivalTime() {
                    ProgressView(timerInterval: Date()...date, countsDown: true, label: {
                        // No label implemented
                    }, currentValueLabel: {
                        if context.state.busService.nextBus?.type == .DoubleDeck {
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
                if let date = context.state.busService.nextBus?.estimatedArrivalTime() {
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

struct AssistantLiveActivity_Previews: PreviewProvider {
    static let attributes = AssistantAttributes(serviceNo: "999A", currentDate: Date())
    static let contentState = AssistantAttributes.ContentState(busService: getSampleBusService())

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
    
    static func getSampleBusService() -> BusService {
        if let busService: BusService = decode(from: Bundle.main.path(forResource: "BusArrivalv2-1", ofType: "json")!) {
            return busService
        } else {
            return BusService(serviceNo: "", operator: .SBSTransit)
        }
    }
}
