//
//  NetworkMonitor.swift
//  Buses
//
//  Created by 堅書 on 1/4/23.
//

import Network
import SwiftUI

// From https://www.danijelavrzan.com/posts/2022/11/network-connection-alert-swiftui/
@Observable
class NetworkMonitor {
    @ObservationIgnored private let networkMonitor = NWPathMonitor()
    @ObservationIgnored private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false

    init() {
        networkMonitor.pathUpdateHandler = { path in
            let isConnected = path.status == .satisfied
            Task { @MainActor in
                self.isConnected = isConnected
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
