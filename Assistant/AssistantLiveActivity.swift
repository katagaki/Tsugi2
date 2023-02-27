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
            VStack(alignment: .center, spacing: 16.0) {
                HStack(alignment: .center) {
                    BusNumberPlateView(serviceNo: context.state.busService.serviceNo)
                        .background(Color("PlateColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        .frame(minWidth: 88.0, maxWidth: 88.0, minHeight: 40.0, maxHeight: 40.0, alignment: .center)
                    Text(context.state.busService.nextBus?.estimatedArrivalTime() ?? Date(), style: .relative)
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                    switch context.state.busService.nextBus?.feature {
                    case .WheelchairAccessible:
                        Image(systemName: "figure.roll")
                            .font(.body)
                            .foregroundColor(.primary)
                    default:
                        Text("")
                    }
                    switch context.state.busService.nextBus?.type {
                    case .DoubleDeck:
                        Image(systemName: "bus.doubledecker")
                            .font(.body)
                            .foregroundColor(.primary)
                    case .none:
                        Text("")
                    default:
                        Image(systemName: "bus")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(16.0)
            .activityBackgroundTint(.black.opacity(0.5))
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    BusNumberPlateView(serviceNo: context.state.busService.serviceNo)
                        .background(Color("PlateColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 16.0))
                        .frame(minWidth: 88.0, maxWidth: 88.0, minHeight: 40.0, maxHeight: 40.0, alignment: .center)
                        .padding(8.0)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 8.0) {
                        HStack(alignment: .center, spacing: 4.0) {
                            switch context.state.busService.nextBus?.feature {
                            case .WheelchairAccessible:
                                Image(systemName: "figure.roll")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            default:
                                Text("")
                            }
                            switch context.state.busService.nextBus?.type {
                            case .DoubleDeck:
                                Image(systemName: "bus.doubledecker")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            case .none:
                                Text("")
                            default:
                                Image(systemName: "bus")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(8.0)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(timerInterval: Date()...(context.state.busService.nextBus?.estimatedArrivalTime() ?? Date()))
                        .tint(Color("AccentColor"))
                        .font(.body)
                        .foregroundColor(.white)
                    .frame(height: 20.0)
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
                        // Hide default label
                    }, currentValueLabel: {
                        Image(systemName: "bus")
                            .font(.system(size: 10.0))
                            .foregroundColor(Color("AccentColor"))
                    })
                        .tint(Color("AccentColor"))
                        .progressViewStyle(.circular)
                        .labelsHidden()
                } else {
                    Text("?")
                }
            } minimal: {
                if let date = context.state.busService.nextBus?.estimatedArrivalTime() {
                    Text(date, style: .relative)
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
