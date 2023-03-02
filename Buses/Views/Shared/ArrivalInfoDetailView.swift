//
//  ArrivalInfoDetailView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/15.
//

import ActivityKit
import SwiftUI

struct ArrivalInfoDetailView: View {
    
    @State var busStop: BusStop
    @State var bus: BusService
    @State var isInitialDataLoading: Bool = true
    @State var usesNickname: Bool = false
    @EnvironmentObject var busStopList: BusStopList
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var showToast: (String, ToastType) async -> Void
    
    var body: some View {
        List {
            Section {
                if let nextBus = bus.nextBus {
                    ArrivalInfoCardView(busService: bus,
                                        arrivalInfo: nextBus,
                                        showToast: self.showToast)
                }
                if let nextBus = bus.nextBus2, nextBus.estimatedArrivalTime() != nil {
                    ArrivalInfoCardView(busService: bus,
                                        arrivalInfo: nextBus,
                                        showToast: self.showToast)
                }
                if let nextBus = bus.nextBus3, nextBus.estimatedArrivalTime() != nil {
                    ArrivalInfoCardView(busService: bus,
                                        arrivalInfo: nextBus,
                                        showToast: self.showToast)
                }
            }
        }
        .listStyle(.grouped)
        .onAppear {
            if !isInitialDataLoading {
                Task {
                    await reloadArrivalTimes()
                }
            }
            if ActivityAuthorizationInfo().areActivitiesEnabled {
                do {
                    liveActivity = try Activity.request(attributes: getLiveActivityConfiguration().0, content: getLiveActivityConfiguration().1)
                    log("Live Activity requested.")
                } catch {
                    log(error.localizedDescription)
                }
            }
        }
        .onDisappear {
            for activity in Activity<AssistantAttributes>.activities {
                Task {
                    await activity.end(nil, dismissalPolicy: .default)
                    log("Live Activity ended.")
                }
            }
        }
        .refreshable {
            Task {
                await reloadArrivalTimes()
            }
        }
        .onReceive(timer, perform: { _ in
            Task {
                await reloadArrivalTimes()
                await liveActivity?.update(getLiveActivityConfiguration().1)
                log("Live Activity updated.")
            }
        })
        .navigationTitle(bus.serviceNo)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(bus.serviceNo)
                        .font(.system(size: 16.0, weight: .bold))
                    Text(busStop.description ?? localized("Shared.BusStop.Description.None"))
                        .font(.system(size: 12.0, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                HStack(alignment: .center, spacing: 0.0) {
                    Button {
                        // TODO: Add to favorites
                    } label: {
                        Image(systemName: "rectangle.stack.badge.plus")
                            .font(.body)
                    }
                    .disabled(true) // TODO: To implement
                }
            }
        }
    }
    
    func reloadArrivalTimes() async {
        do {
            let busStop = try await fetchBusArrivals(for: busStop.code)
            if usesNickname {
                busStop.description = self.busStop.description
            } else {
                busStop.description = busStopList.busStops.first(where: { busStopInBusStopList in
                    busStopInBusStopList.code == busStop.code
                })?.description ?? nil
            }
            let bus = busStop.arrivals?.first(where: { bus in
                bus.serviceNo == self.bus.serviceNo
            }) ?? BusService(serviceNo: bus.serviceNo, operator: bus.operator)
            self.busStop = busStop
            self.bus = bus
            isInitialDataLoading = false
        } catch {
            log(error.localizedDescription)
        }
    }
    
    func getLiveActivityConfiguration() -> (AssistantAttributes, ActivityContent<AssistantAttributes.ContentState>) {
        let initialContentState = AssistantAttributes.ContentState(busService: bus)
        let activityAttributes = AssistantAttributes(serviceNo: bus.serviceNo, currentDate: Date())
        let activityContent = ActivityContent(state: initialContentState,
                                              staleDate: Calendar.current.date(byAdding: .second,
                                                                               value: 15,
                                                                               to: Date()))
        return (activityAttributes, activityContent)
    }
    
}

struct ArrivalInfoDetailView_Previews: PreviewProvider {
    
    static var sampleBusStop: BusStop? = loadPreviewData()
    
    static var previews: some View {
        ArrivalInfoDetailView(busStop: sampleBusStop!,
                              bus: sampleBusStop!.arrivals!.randomElement()!,
                              showToast: self.showToast)
    }
    
    static func showToast(message: String, type: ToastType = .None) async { }
    
    static private func loadPreviewData() -> BusStop? {
        if let sampleDataPath = Bundle.main.path(forResource: "BusArrivalv2-1", ofType: "json") {
            let sampleBusStop: BusStop? = decode(from: sampleDataPath)
            return sampleBusStop!
        } else {
            return nil
        }
    }
    
}
