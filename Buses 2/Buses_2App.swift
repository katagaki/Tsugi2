//
//  Buses_2App.swift
//  Buses 2
//
//  Created by 堅書 on 2022/03/26.
//

import SwiftUI

@main
struct Buses_2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
