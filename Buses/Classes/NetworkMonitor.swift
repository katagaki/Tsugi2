//
//  NetworkMonitor.swift
//  Buses
//
//  Created by 堅書 on 1/4/23.
//

import Network
import SwiftUI

// From https://www.danijelavrzan.com/posts/2022/11/network-connection-alert-swiftui/
class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false

    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            Task {
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
