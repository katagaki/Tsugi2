//
//  ArrivalInfoDetailView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/15.
//

import ActivityKit
import SwiftUI

struct ArrivalInfoDetailView: View {
    
    @EnvironmentObject var busStopList: BusStopList
    
    @State var liveActivityID: String = ""
    
    @State var busStop: BusStop
    @State var busService: BusService
    @State var isInitialDataLoading: Bool = true
    @State var usesNickname: Bool = false
    let timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    
    var showToast: (String, ToastType) async -> Void
    
    var body: some View {
        List {
            Section {
                if let nextBus = busService.nextBus {
                    ArrivalInfoCardView(busService: busService,
                                        arrivalInfo: nextBus,
                                        setNotification: self.setNotification)
                }
                if let nextBus = busService.nextBus2, nextBus.estimatedArrivalTime() != nil {
                    ArrivalInfoCardView(busService: busService,
                                        arrivalInfo: nextBus,
                                        setNotification: self.setNotification)
                }
                if let nextBus = busService.nextBus3, nextBus.estimatedArrivalTime() != nil {
                    ArrivalInfoCardView(busService: busService,
                                        arrivalInfo: nextBus,
                                        setNotification: self.setNotification)
                }
            }
        }
        .listStyle(.insetGrouped)
        .onAppear {
            Task {
                await reloadArrivalTimes()
                startLiveActivity()
            }
        }
        .onDisappear {
            Task {
                if let liveActivity = Activity<AssistantAttributes>.activities.first(where: {$0.id == liveActivityID}) {
                    await liveActivity.end(nil, dismissalPolicy: .default)
                    log("Live Activity \(liveActivityID) ended.")
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
            }
        })
        .navigationTitle(busService.serviceNo)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(busService.serviceNo)
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
            let busService = busStop.arrivals?.first(where: { busService in
                busService.serviceNo == self.busService.serviceNo
            }) ?? BusService(serviceNo: busService.serviceNo, operator: busService.operator)
            self.busStop = busStop
            self.busService = busService
            log("Arrival time data updated.")
            isInitialDataLoading = false
        } catch {
            log(error.localizedDescription)
        }
    }
    
    func setNotification(for arrivalInfo: BusArrivalInfo) {
        if let date = arrivalInfo.estimatedArrivalTime() {
            center.requestAuthorization(options: [.alert, .sound]) { granted, error in
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
                    content.title = localized("Notification.Arriving.Title").replacingOccurrences(of: "%1", with: busStop.description ?? localized("Shared.BusStop.Description.None"))
                    content.body = localized("Notification.Arriving.Description").replacingOccurrences(of: "%s1", with: busService.serviceNo).replacingOccurrences(of: "%s2", with: date.formatted(date: .omitted, time: .shortened))
                    content.userInfo = ["busService": busService.serviceNo, "stopCode": busStop.code, "stopDescription": busStop.description ?? localized("Shared.BusStop.Description.None")]
                    content.interruptionLevel = .timeSensitive
                    center.add(UNNotificationRequest(identifier: "\(busStop.code).\(busService.serviceNo).\(date.formatted(date: .numeric, time: .shortened))",
                                                     content: content,
                                                     trigger: trigger)) { (error) in
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
    
    func startLiveActivity() {
        let initialContentState = AssistantAttributes.ContentState(busService: busService)
        let activityAttributes = AssistantAttributes(serviceNo: busService.serviceNo, currentDate: Date())
        let activityContent = ActivityContent(state: initialContentState,
                                              staleDate: Calendar.current.date(byAdding: .second,
                                                                               value: 15,
                                                                               to: Date()))
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            do {
                var liveActivity: Activity<AssistantAttributes>?
                liveActivity = try Activity.request(attributes: activityAttributes, content: activityContent)
                liveActivityID = liveActivity?.id ?? ""
                log("Live Activity requested with id \(liveActivityID).")
            } catch {
                log(error.localizedDescription)
            }
        }
    }
    
}

struct ArrivalInfoDetailView_Previews: PreviewProvider {
    
    static var sampleBusStop: BusStop? = loadPreviewData()
    
    static var previews: some View {
        ArrivalInfoDetailView(busStop: sampleBusStop!,
                              busService: sampleBusStop!.arrivals!.randomElement()!,
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
