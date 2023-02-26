//
//  ArrivalInfoCardView.swift
//  Buses
//
//  Created by 堅書 on 2022/06/15.
//

import SwiftUI

struct ArrivalInfoCardView: View {
    
    var busService: BusService
    var arrivalInfo: BusArrivalInfo
    @State var arrivalTime: String = ""
    
    var showToast: (String, Bool) async -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            VStack(alignment: .leading, spacing: 2.0) {
                Text(arrivalTimeTo(date: arrivalInfo.estimatedArrivalTime()))
                    .font(.system(size: 20.0, weight: .medium))
                if arrivalTime != "" {
                    Text(arrivalTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Shared.BusArrival.NotInService.Subtitle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            switch arrivalInfo.load {
            case .StandingAvailable:
                Text("Shared.BusArrival.Crowded")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 3.0, leading: 6.0, bottom: 3.0, trailing: 6.0))
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 6.0))
            case .LimitedStanding:
                Text("Shared.BusArrival.Crowded")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 3.0, leading: 6.0, bottom: 3.0, trailing: 6.0))
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 6.0))
            default:
                Text("")
            }
            if arrivalTime != "" {
                HStack(alignment: .center, spacing: 4.0) {
                    switch arrivalInfo.feature {
                    case .WheelchairAccessible:
                        Image(systemName: "figure.roll")
                            .font(.body)
                            .foregroundColor(.secondary)
                    default:
                        Text("")
                    }
                    switch arrivalInfo.type {
                    case .DoubleDeck:
                        Image(systemName: "bus.doubledecker")
                            .font(.body)
                            .foregroundColor(.secondary)
                    case .none:
                        Text("")
                    default:
                        Image(systemName: "bus")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                if let date = arrivalInfo.estimatedArrivalTime() {
                    Divider()
                    Button {
                        setNotification()
                    } label: {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 14.0, weight: .regular))
                    }
                    .buttonStyle(.bordered)
                    .mask {
                        Circle()
                    }
                    .disabled(date < (Date() + (2 * 60)))
                }
            }
        }
        .onAppear {
            if let estimatedArrivalTime = arrivalInfo.estimatedArrivalTime() {
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .short
                arrivalTime = dateFormatter.string(from: estimatedArrivalTime)
            } else {
                arrivalTime = ""
            }
        }
    }
    
    func setNotification() {
        if let date = arrivalInfo.estimatedArrivalTime() {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    log("Error occurred while reqesting for notification permissions: \(error.localizedDescription)")
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
                    content.body = localized("Notification.Arriving.Description").replacingOccurrences(of: "%s1", with: busService.serviceNo).replacingOccurrences(of: "%s2", with: date.formatted(date: .omitted, time: .standard))
                    content.interruptionLevel = .timeSensitive
                    notificationCenter.add(request) { (error) in
                       if let error = error {
                           log("Error occurred while setting notifications: \(error.localizedDescription)")
                       } else {
                           log("Notification set with content: \(content.body), and will appear at \((date - (2 * 60)).formatted(date: .complete, time: .complete)).")
                           Task {
                               await showToast(localized("Notification.Set"), true)
                           }
                       }
                    }
                }
            }
        }
    }
    
}

struct ArrivalInfoCardView_Previews: PreviewProvider {
    
    static var sampleBusStop: BusStop? = loadPreviewData()
    
    static var previews: some View {
        ArrivalInfoDetailView(busStop: sampleBusStop!,
                              bus: sampleBusStop!.arrivals!.randomElement()!,
                              showToast: self.showToast)
    }
    
    static func showToast(message: String, showsCheckmark: Bool = false) async { }
    
    static private func loadPreviewData() -> BusStop? {
        if let sampleDataPath = Bundle.main.path(forResource: "BusArrivalv2-1", ofType: "json") {
            let sampleBusStop: BusStop? = decode(from: sampleDataPath)
            return sampleBusStop!
        } else {
            return nil
        }
    }
    
}
