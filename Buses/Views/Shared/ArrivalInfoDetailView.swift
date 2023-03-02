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
    let timer = Timer.publish(every: 30.0, on: .main, in: .common).autoconnect()
    
    var showToast: (String, ToastType) async -> Void
    
    var body: some View {
        List {
            Section {
                if let nextBus = bus.nextBus {
                    ArrivalInfoCardView(busService: bus,
                                        arrivalInfo: nextBus,
                                        setNotification: self.setNotification)
                }
                if let nextBus = bus.nextBus2, nextBus.estimatedArrivalTime() != nil {
                    ArrivalInfoCardView(busService: bus,
                                        arrivalInfo: nextBus,
                                        setNotification: self.setNotification)
                }
                if let nextBus = bus.nextBus3, nextBus.estimatedArrivalTime() != nil {
                    ArrivalInfoCardView(busService: bus,
                                        arrivalInfo: nextBus,
                                        setNotification: self.setNotification)
                }
            }
        }
        .listStyle(.insetGrouped)
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
    
    func setNotification(for arrivalInfo: BusArrivalInfo) {
        if let date = arrivalInfo.estimatedArrivalTime() {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    log("Error occurred while reqesting for notification permissions: \(error.localizedDescription)")
                    Task {
                        await showToast(localized("Notification.Error"), .Exclamation)
                    }
                } else if granted == false {
                    log("Permissions for notifications was not granted, not setting notifications.")
                    Task {
                        await showToast(localized("Notification.NoPermissions"), .Exclamation)
                    }
                } else {
                    let content = UNMutableNotificationContent()
                    let trigger = UNCalendarNotificationTrigger(
                             dateMatching: Calendar.current.dateComponents([.weekday, .hour, .minute, .second],
                                                                           from: date - (2 * 60)), repeats: false)
                    let uuidString = UUID().uuidString
                    let request = UNNotificationRequest(identifier: uuidString,
                                                        content: content,
                                                        trigger: trigger)
                    content.title = localized("Notification.Arriving.Title")
                    content.body = localized("Notification.Arriving.Description").replacingOccurrences(of: "%s1", with: bus.serviceNo).replacingOccurrences(of: "%s2", with: date.formatted(date: .omitted, time: .standard))
                    content.interruptionLevel = .timeSensitive
                    notificationCenter.add(request) { (error) in
                       if let error = error {
                           log("Error occurred while setting notifications: \(error.localizedDescription)")
                           Task {
                               await showToast(localized("Notification.Error"), .Exclamation)
                           }
                       } else {
                           log("Notification set with content: \(content.body), and will appear at \((date - (2 * 60)).formatted(date: .complete, time: .complete)).")
                           Task {
                               await showToast(localized("Notification.Set"), .Checkmark)
                           }
                       }
                    }
                }
            }
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
